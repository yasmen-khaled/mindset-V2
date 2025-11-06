package main

import (
	"database/sql"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type LoginRequest struct {
	PhoneNumber string `json:"phone_number" binding:"required"`
	Password    string `json:"password" binding:"required"`
}

type RegisterRequest struct {
	Username    string `json:"username" binding:"required"`
	PhoneNumber string `json:"phone_number" binding:"required"`
	Password    string `json:"password" binding:"required,min=6"`
	Gender      string `json:"gender,omitempty"`
}

type SendSMSRequest struct {
	PhoneNumber string `json:"phone_number" binding:"required"`
}

type VerifySMSRequest struct {
	PhoneNumber      string `json:"phone_number" binding:"required"`
	VerificationCode string `json:"verification_code" binding:"required"`
	NewPassword      string `json:"new_password" binding:"required,min=6"`
}

type ResetPasswordRequest struct {
	PhoneNumber string `json:"phone_number" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

var jwtSecret = []byte("your-secret-key")
var db *sql.DB
var dbDash *sql.DB

// Task struct for dashboard data
type Task struct {
	ID          int    `json:"id"`
	CategoryID  int    `json:"category_id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Completed   bool   `json:"completed"`
	VideoURL    *string `json:"video_url"`
}

// Option struct for quiz questions
type Option struct {
	ID        int    `json:"id"`
	Text      string `json:"text"`
	IsCorrect bool   `json:"is_correct"`
}

// Question struct for quizzes
type Question struct {
	ID         int      `json:"id"`
	CategoryID int      `json:"category_id"`
	Text       string   `json:"text"`
	Options    []Option `json:"options"`
}


// Category struct for dashboard data
type Category struct {
	ID       int     `json:"id"`
	Name     string  `json:"name"`
	Level    int     `json:"level"`
	Progress float64 `json:"progress"`
	Stars    int     `json:"stars"`
}

// In-memory storage for when database is not available
type User struct {
	ID           int       `json:"id"`
	Username     string    `json:"username"`
	PhoneNumber  string    `json:"phone_number"`
	PasswordHash string    `json:"-"`
	Gender       string    `json:"gender"`
	CreatedAt    time.Time `json:"created_at"`
}

type SMSCode struct {
	PhoneNumber string    `json:"phone_number"`
	Code        string    `json:"code"`
	ExpiresAt   time.Time `json:"expires_at"`
	Used        bool      `json:"used"`
}

var (
	inMemoryUsers    = make(map[string]*User)    // phone_number -> User
	inMemorySMSCodes = make(map[string]*SMSCode) // phone_number -> SMSCode
	userIDCounter    = 1
)

// Database configuration - UPDATE THESE WITH YOUR MySQL CREDENTIALS
const (
	DB_USER     = "root"          // Your MySQL username
	DB_PASSWORD = ""              // Your MySQL password (often empty for localhost)
	DB_HOST     = "localhost"     // Usually localhost
	DB_PORT     = "3306"          // Usually 3306
	DB_NAME     = "mindset_db" // The database for login
	DB_DASH_NAME = "mindsetdash_db" // The new database for dashboard data
)

func initDatabase() error {
	// MySQL connection string
	dsn := DB_USER + ":" + DB_PASSWORD + "@unix(/Applications/XAMPP/xamppfiles/var/mysql/mysql.sock)/" + DB_NAME + "?parseTime=true"

	var err error
	db, err = sql.Open("mysql", dsn)
	if err != nil {
		log.Printf("⚠️  Database connection failed, using in-memory storage: %v", err)
		db = nil // Set to nil for proper fallback
		return err
	}

	// Test the connection
	if err = db.Ping(); err != nil {
		log.Printf("⚠️  Database connection failed, using in-memory storage: %v", err)
		db = nil // Set to nil for proper fallback
		return err
	}

	log.Printf("✅ Connected to MySQL database successfully!")

	// Create SMS verification codes table if it doesn't exist
	createSMSTable := `
	CREATE TABLE IF NOT EXISTS sms_verification_codes (
		id INT AUTO_INCREMENT PRIMARY KEY,
		phone_number VARCHAR(20) NOT NULL,
		verification_code VARCHAR(10) NOT NULL,
		code_type ENUM('password_reset', 'phone_verification') DEFAULT 'password_reset',
		expires_at TIMESTAMP NOT NULL,
		used_at TIMESTAMP NULL,
		is_used BOOLEAN DEFAULT FALSE,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		
		INDEX idx_phone_code (phone_number, verification_code),
		INDEX idx_expires_at (expires_at),
		INDEX idx_code_type (code_type)
	)`

	if _, err := db.Exec(createSMSTable); err != nil {
		log.Printf("⚠️  Failed to create SMS table: %v", err)
	} else {
		log.Printf("✅ SMS verification codes table ready")
	}

	// Update test user passwords with proper bcrypt hash for 'password123'
	// Generate a fresh hash for password123
	correctHash, err := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	if err != nil {
		log.Printf("⚠️  Failed to generate hash: %v", err)
		return nil
	}

	updateTestUsers := fmt.Sprintf(`
	UPDATE users SET password_hash = '%s' 
	WHERE username IN ('john_doe', 'sarah_chen', 'alex_kumar', 'maria_garcia', 'ahmed_libya', 'fatima_libya', 'demo_user')
	`, string(correctHash))

	if _, err := db.Exec(updateTestUsers); err != nil {
		log.Printf("⚠️  Failed to update test user passwords: %v", err)
	} else {
		log.Printf("✅ Test user passwords updated")
	}

	return nil
}

func initDashDatabase() error {
	// MySQL connection string for the dashboard database
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true", DB_USER, DB_PASSWORD, DB_HOST, DB_PORT, DB_DASH_NAME)

	var err error
	dbDash, err = sql.Open("mysql", dsn)
	if err != nil {
		log.Printf("⚠️  Dashboard database connection failed: %v", err)
		dbDash = nil
		return err
	}

	if err = dbDash.Ping(); err != nil {
		log.Printf("⚠️  Dashboard database connection failed: %v", err)
		dbDash = nil
		return err
	}

	log.Printf("✅ Connected to MySQL dashboard database successfully!")
	return nil
}


// New handler to get all tasks for a specific category from the dashboard database
func handleGetTasks(c *gin.Context) {
	if dbDash == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Dashboard database not connected"})
		return
	}

	categoryID := c.Query("category_id")
	if categoryID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "category_id is required"})
		return
	}

	rows, err := dbDash.Query("SELECT id, category_id, title, description, completed, video_url FROM tasks WHERE category_id = ?", categoryID)
	if err != nil {
		log.Printf("Error querying tasks from dashboard db: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tasks"})
		return
	}
	defer rows.Close()

	tasks := []Task{}
	for rows.Next() {
		var task Task
		if err := rows.Scan(&task.ID, &task.CategoryID, &task.Title, &task.Description, &task.Completed, &task.VideoURL); err != nil {
			log.Printf("Error scanning task row from dashboard db: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process tasks"})
			return
		}
		tasks = append(tasks, task)
	}

	c.JSON(http.StatusOK, tasks)
}

// New handler to get all questions for a specific category from the dashboard database
func handleGetQuestions(c *gin.Context) {
	if dbDash == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Dashboard database not connected"})
		return
	}

	categoryID := c.Query("category_id")
	if categoryID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "category_id is required"})
		return
	}

	// Fetch questions
	rows, err := dbDash.Query("SELECT id, category_id, text FROM questions WHERE category_id = ?", categoryID)
	if err != nil {
		log.Printf("Error querying questions from dashboard db: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch questions"})
		return
	}
	defer rows.Close()

	questions := []Question{}
	for rows.Next() {
		var question Question
		if err := rows.Scan(&question.ID, &question.CategoryID, &question.Text); err != nil {
			log.Printf("Error scanning question row from dashboard db: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process questions"})
			return
		}

		// Fetch options for each question
		optionRows, err := dbDash.Query("SELECT id, text, is_correct FROM options WHERE question_id = ?", question.ID)
		if err != nil {
			log.Printf("Error querying options from dashboard db: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch options"})
			return
		}
		defer optionRows.Close()

		options := []Option{}
		for optionRows.Next() {
			var option Option
			var isCorrectInt int
			if err := optionRows.Scan(&option.ID, &option.Text, &isCorrectInt); err != nil {
				log.Printf("Error scanning option row from dashboard db: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process options"})
				return
			}
			option.IsCorrect = (isCorrectInt == 1)
			options = append(options, option)
		}
		question.Options = options
		questions = append(questions, question)
	}

	c.JSON(http.StatusOK, questions)
}


// New handler to get all categories from the dashboard database
func handleGetCategories(c *gin.Context) {
	if dbDash == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Dashboard database not connected"})
		return
	}

	level := c.Query("level")
	var rows *sql.Rows
	var err error

	if level != "" {
		query := `
			SELECT
				c.id,
				c.name,
				c.level,
				COALESCE(
					(SELECT SUM(t.completed) * 100.0 / COUNT(t.id) FROM tasks t WHERE t.category_id = c.id),
					0
				) as progress
			FROM
				categories c
			WHERE
				c.status = 1 AND c.level = ?
			ORDER BY
				c.id;
		`
		rows, err = dbDash.Query(query, level)
	} else {
		query := `
			SELECT
				c.id,
				c.name,
				c.level,
				COALESCE(
					(SELECT SUM(t.completed) * 100.0 / COUNT(t.id) FROM tasks t WHERE t.category_id = c.id),
					0
				) as progress
			FROM
				categories c
			WHERE
				c.status = 1
			ORDER BY
				c.level, c.id;
		`
		rows, err = dbDash.Query(query)
	}


	if err != nil {
		log.Printf("Error querying categories from dashboard db: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch categories"})
		return
	}
	defer rows.Close()

	categories := []Category{}
	for rows.Next() {
		var category Category
		if err := rows.Scan(&category.ID, &category.Name, &category.Level, &category.Progress); err != nil {
			log.Printf("Error scanning category row from dashboard db: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process categories"})
			return
		}
		// Placeholder for stars
		category.Stars = 100 
		categories = append(categories, category)
	}

	c.JSON(http.StatusOK, categories)
}


func initInMemoryStorage() {
	// Add test users to in-memory storage
	testUsers := []struct {
		username, phone, password, gender string
	}{
		{"john_doe", "+12345678901", "password123", "male"},
		{"sarah_chen", "+12345678902", "password123", "female"},
		{"demo_user", "+12345678903", "password123", "male"},
		{"test_user", "+12345678999", "password123", "male"},
	}

	for _, user := range testUsers {
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(user.password), bcrypt.DefaultCost)
		inMemoryUsers[user.phone] = &User{
			ID:           userIDCounter,
			Username:     user.username,
			PhoneNumber:  user.phone,
			PasswordHash: string(hashedPassword),
			Gender:       user.gender,
			CreatedAt:    time.Now(),
		}
		userIDCounter++
	}
	log.Printf("✅ In-memory storage initialized with %d test users", len(inMemoryUsers))
}

func generateToken(phoneNumber string) (string, error) {
	claims := jwt.MapClaims{
		"phone_number": phoneNumber,
		"exp":          time.Now().Add(time.Hour * 24).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

// Generate 6-digit SMS verification code
func generateSMSCode() string {
	return fmt.Sprintf("%06d", rand.Intn(1000000))
}

// Validate phone number format (enhanced international support)
func isValidPhoneNumber(phone string) bool {
	// Enhanced phone validation for international numbers
	// Supports various country codes including Libya (+218)
	// Format: +[1-9][0-9]{0,3}[0-9]{7,14} (country code 1-4 digits + 7-14 digit number)
	match, _ := regexp.MatchString(`^\+[1-9]\d{0,3}\d{7,14}$`, phone)
	return match && len(phone) >= 10 && len(phone) <= 18
}

// Format phone number for different countries
func formatPhoneNumber(phone string) string {
	// Remove any non-digit characters except +
	cleaned := regexp.MustCompile(`[^\d+]`).ReplaceAllString(phone, "")

	// Handle different input formats
	if strings.HasPrefix(cleaned, "00") {
		// Convert 00218 format to +218
		cleaned = "+" + cleaned[2:]
	} else if !strings.HasPrefix(cleaned, "+") && len(cleaned) >= 7 {
		// If no country code, assume it needs one
		// For demo, we'll require explicit country code
		return cleaned // Return as-is, let validation catch it
	}

	return cleaned
}

// Get country info from phone number
func getCountryFromPhone(phone string) string {
	countryMap := map[string]string{
		"+1":   "US/Canada",
		"+44":  "UK",
		"+218": "Libya",
		"+20":  "Egypt",
		"+966": "Saudi Arabia",
		"+971": "UAE",
		"+33":  "France",
		"+49":  "Germany",
		"+86":  "China",
		"+91":  "India",
		"+81":  "Japan",
		"+82":  "South Korea",
		"+212": "Morocco",
		"+213": "Algeria",
		"+216": "Tunisia",
	}

	for code, country := range countryMap {
		if strings.HasPrefix(phone, code) {
			return country
		}
	}
	return "Unknown"
}

// Send SMS function (placeholder - integrate with Twilio/AWS SNS)
func sendSMS(phoneNumber, message string) error {
	// TODO: Integrate with SMS service (Twilio, AWS SNS, etc.)
	log.Printf("📱 SMS to %s: %s", phoneNumber, message)

	// For demo purposes, we'll just log the SMS
	// In production, implement actual SMS sending:
	/*
		// Example Twilio integration:
		client := twilio.NewRestClient(accountSid, authToken)
		params := &api.CreateMessageParams{}
		params.SetTo(phoneNumber)
		params.SetFrom(twilioPhoneNumber)
		params.SetBody(message)
		_, err := client.Api.CreateMessage(params)
		return err
	*/

	return nil
}

func main() {
	// Try to connect to database
	if err := initDatabase(); err != nil {
		log.Printf("⚠️  Database connection failed, using in-memory storage")
		db = nil // Ensure db is nil for proper fallback
		initInMemoryStorage()
	}
	if err := initDashDatabase(); err != nil {
		log.Printf("Dashboard database not connected.")
	}

	router := gin.Default()

	// Configure CORS for Flutter app
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"*"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Authorization"}
	router.Use(cors.New(config))

	// Routes for Flutter app
	router.POST("/login", handleLogin)
	router.POST("/register", handleRegister)
	router.POST("/reset-password-request", handleSendSMSReset)
	router.POST("/verify-sms-reset", handleVerifySMSReset)
	router.POST("/reset-password", handleResetPassword)
	router.POST("/upload", handleFileUpload)
	router.GET("/categories", handleGetCategories)
	router.GET("/tasks", handleGetTasks)
	router.GET("/questions", handleGetQuestions)

	// Web student routes - only if DB is connected
	if db != nil {
		webstudent := router.Group("/webstudent")
		{
			webstudent.POST("/login", handleLogin)
			webstudent.POST("/register", handleRegister)
			webstudent.POST("/reset_password_request", handleSendSMSReset)
			webstudent.POST("/reset_password_verify", handleVerifySMSReset)
			webstudent.POST("/get_profile", handleGetProfile)
			webstudent.POST("/upload_file", handleFileUpload)
		}
	}

	// Start the server
	port := "8005"
	log.Printf("🚀 Server starting on port %s...", port)
	if db != nil {
		log.Printf("📊 Database: MySQL connected (%s)", DB_NAME)
	} else {
		log.Printf("📊 Database: Using in-memory storage")
	}
	log.Printf("📱 SMS-enabled endpoints:")
	log.Printf("  POST http://127.0.0.1:%s/login", port)
	log.Printf("  POST http://127.0.0.1:%s/register", port)
	log.Printf("  POST http://127.0.0.1:%s/reset-password-request", port)
	log.Printf("  POST http://127.0.0.1:%s/verify-sms-reset", port)
	log.Printf("  POST http://127.0.0.1:%s/reset-password", port)
	log.Printf("  POST http://127.0.0.1:%s/upload", port)
	log.Printf("  GET  http://127.0.0.1:%s/categories", port)
	log.Printf("  GET  http://127.0.0.1:%s/tasks", port)
	log.Printf("  GET  http://127.0.0.1:%s/questions", port)

	if err := router.Run("0.0.0.0:" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func handleLogin(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Format and validate phone number
	formattedPhone := formatPhoneNumber(req.PhoneNumber)
	if !isValidPhoneNumber(formattedPhone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid phone number format. Use international format like +218912345678"})
		return
	}

	country := getCountryFromPhone(formattedPhone)
	log.Printf("🌍 Login attempt from %s (%s)", formattedPhone, country)

	if db != nil {
		log.Printf("📊 Using MySQL database for login")
		// Database login
		var passwordHash string
		var username string

		query := "SELECT username, password_hash FROM users WHERE phone_number = ? AND is_active = TRUE"
		err := db.QueryRow(query, formattedPhone).Scan(&username, &passwordHash)

		if err == sql.ErrNoRows {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
			return
		} else if err != nil {
			log.Printf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		if err := bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(req.Password)); err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
			return
		}

		// Update last login
		_, err = db.Exec("UPDATE users SET last_login = NOW() WHERE phone_number = ?", formattedPhone)
		if err != nil {
			log.Printf("Failed to update last login: %v", err)
		}

		token, err := generateToken(formattedPhone)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
			return
		}

		log.Printf("✅ Login successful for: %s (%s)", formattedPhone, country)

		c.JSON(http.StatusOK, gin.H{
			"message":  "Login successful",
			"token":    token,
			"username": username,
			"country":  country,
		})
	} else {
		log.Printf("📊 Using in-memory storage for login")
		// In-memory storage login
		user, exists := inMemoryUsers[formattedPhone]
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
			return
		}

		if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
			return
		}

		token, err := generateToken(formattedPhone)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
			return
		}

		log.Printf("✅ Login successful (in-memory) for: %s (%s)", formattedPhone, country)

		c.JSON(http.StatusOK, gin.H{
			"message":  "Login successful",
			"token":    token,
			"username": user.Username,
			"country":  country,
		})
	}
}

func handleRegister(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Format and validate phone number
	formattedPhone := formatPhoneNumber(req.PhoneNumber)
	if !isValidPhoneNumber(formattedPhone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid phone number format. Use international format like +218912345678"})
		return
	}

	country := getCountryFromPhone(formattedPhone)
	log.Printf("🌍 Registration attempt from %s (%s)", formattedPhone, country)

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process password"})
		return
	}

	if db != nil {
		log.Printf("📊 Using MySQL database for registration")
		// Check if phone number already exists
		var count int
		err := db.QueryRow("SELECT COUNT(*) FROM users WHERE phone_number = ?", formattedPhone).Scan(&count)
		if err != nil {
			log.Printf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		if count > 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Phone number already registered"})
			return
		}

		// Insert new user into database
		query := "INSERT INTO users (username, phone_number, password_hash, gender) VALUES (?, ?, ?, ?)"
		result, err := db.Exec(query, req.Username, formattedPhone, string(hashedPassword), req.Gender)
		if err != nil {
			log.Printf("Failed to create user: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
			return
		}

		userID, _ := result.LastInsertId()
		log.Printf("✅ New user registered: %s (%s) - ID: %d", formattedPhone, country, userID)

		// Generate JWT token for automatic login
		token, err := generateToken(formattedPhone)
		if err != nil {
			log.Printf("Failed to generate token: %v", err)
			// Return without token - user can still login manually
			c.JSON(http.StatusOK, gin.H{
				"message":  "Registration successful",
				"user_id":  userID,
				"username": req.Username,
				"country":  country,
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message":  "Registration successful",
			"user_id":  userID,
			"username": req.Username,
			"token":    token,
			"country":  country,
		})
	} else {
		log.Printf("📊 Using in-memory storage for registration")
		// In-memory storage registration
		if _, exists := inMemoryUsers[formattedPhone]; exists {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Phone number already registered"})
			return
		}

		// Create new user in memory
		inMemoryUsers[formattedPhone] = &User{
			ID:           userIDCounter,
			Username:     req.Username,
			PhoneNumber:  formattedPhone,
			PasswordHash: string(hashedPassword),
			Gender:       req.Gender,
			CreatedAt:    time.Now(),
		}
		userID := userIDCounter
		userIDCounter++

		log.Printf("✅ New user registered (in-memory): %s (%s) - ID: %d", formattedPhone, country, userID)

		// Generate JWT token for automatic login
		token, err := generateToken(formattedPhone)
		if err != nil {
			log.Printf("Failed to generate token: %v", err)
			c.JSON(http.StatusOK, gin.H{
				"message":  "Registration successful",
				"user_id":  userID,
				"username": req.Username,
				"country":  country,
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message":  "Registration successful",
			"user_id":  userID,
			"username": req.Username,
			"token":    token,
			"country":  country,
		})
	}
}

func handleSendSMSReset(c *gin.Context) {
	var req SendSMSRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Format and validate phone number
	formattedPhone := formatPhoneNumber(req.PhoneNumber)
	if !isValidPhoneNumber(formattedPhone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid phone number format. Use international format like +218912345678"})
		return
	}

	country := getCountryFromPhone(formattedPhone)
	log.Printf("🌍 SMS reset request from %s (%s)", formattedPhone, country)

	if db != nil {
		// Check if phone number exists
		var count int
		err := db.QueryRow("SELECT COUNT(*) FROM users WHERE phone_number = ? AND is_active = TRUE", formattedPhone).Scan(&count)
		if err != nil {
			log.Printf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		if count == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "Phone number not found"})
			return
		}

		// Generate verification code
		verificationCode := generateSMSCode()
		expiresAt := time.Now().Add(10 * time.Minute) // Code expires in 10 minutes

		// Store verification code in database
		query := `INSERT INTO sms_verification_codes 
				  (phone_number, verification_code, code_type, expires_at) 
				  VALUES (?, ?, 'password_reset', ?)`

		_, err = db.Exec(query, formattedPhone, verificationCode, expiresAt)
		if err != nil {
			log.Printf("Failed to store verification code: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate verification code"})
			return
		}

		// Send SMS with country-specific message
		var message string
		if country == "Libya" {
			message = fmt.Sprintf("كود إعادة تعيين كلمة المرور لتطبيق Mindset: %s. صالح لمدة 10 دقائق.", verificationCode)
		} else {
			message = fmt.Sprintf("Your Mindset password reset code is: %s. Valid for 10 minutes.", verificationCode)
		}

		err = sendSMS(formattedPhone, message)
		if err != nil {
			log.Printf("Failed to send SMS: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send SMS"})
			return
		}

		log.Printf("📱 SMS reset code sent to: %s (%s)", formattedPhone, country)

		c.JSON(http.StatusOK, gin.H{
			"message":            "Verification code sent via SMS",
			"expires_in_minutes": 10,
			"country":            country,
		})
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not connected"})
	}
}

func handleVerifySMSReset(c *gin.Context) {
	var req VerifySMSRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Format phone number
	formattedPhone := formatPhoneNumber(req.PhoneNumber)
	country := getCountryFromPhone(formattedPhone)
	log.Printf("🌍 SMS verification from %s (%s)", formattedPhone, country)

	if db != nil {
		// Verify SMS code
		var codeID int
		var attempts int
		query := `SELECT id, attempts FROM sms_verification_codes 
				  WHERE phone_number = ? AND verification_code = ? 
				  AND code_type = 'password_reset' AND is_used = FALSE 
				  AND expires_at > NOW()`

		err := db.QueryRow(query, formattedPhone, req.VerificationCode).Scan(&codeID, &attempts)
		if err == sql.ErrNoRows {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or expired verification code"})
			return
		} else if err != nil {
			log.Printf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		// Mark code as used
		_, err = db.Exec("UPDATE sms_verification_codes SET is_used = TRUE WHERE id = ?", codeID)
		if err != nil {
			log.Printf("Failed to mark code as used: %v", err)
		}

		// Hash new password
		newPasswordHash, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process password"})
			return
		}

		// Update password in database
		_, err = db.Exec("UPDATE users SET password_hash = ?, updated_at = NOW() WHERE phone_number = ?",
			string(newPasswordHash), formattedPhone)
		if err != nil {
			log.Printf("Failed to update password: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
			return
		}

		log.Printf("✅ Password reset successful for: %s (%s)", formattedPhone, country)

		c.JSON(http.StatusOK, gin.H{
			"message": "Password reset successful",
			"country": country,
		})
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not connected"})
	}
}

func handleResetPassword(c *gin.Context) {
	var req ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Format and validate phone number
	formattedPhone := formatPhoneNumber(req.PhoneNumber)
	if !isValidPhoneNumber(formattedPhone) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid phone number format. Use international format like +218912345678"})
		return
	}

	country := getCountryFromPhone(formattedPhone)
	log.Printf("🌍 Password reset request from %s (%s)", formattedPhone, country)

	if db != nil {
		// Check if phone number exists
		var count int
		err := db.QueryRow("SELECT COUNT(*) FROM users WHERE phone_number = ? AND is_active = TRUE", formattedPhone).Scan(&count)
		if err != nil {
			log.Printf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		}

		if count == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "Phone number not found"})
			return
		}

		// Hash new password
		newPasswordHash, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process password"})
			return
		}

		// Update password in database
		_, err = db.Exec("UPDATE users SET password_hash = ?, updated_at = NOW() WHERE phone_number = ?",
			string(newPasswordHash), formattedPhone)
		if err != nil {
			log.Printf("Failed to update password: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
			return
		}

		log.Printf("✅ Password reset successful for: %s (%s)", formattedPhone, country)

		c.JSON(http.StatusOK, gin.H{
			"message": "Password reset successful",
			"country": country,
		})
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database not connected"})
	}
}

func handleGetProfile(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"id":           1,
		"phone_number": "1234567890",
		"created_at":   time.Now(),
	})
}

func handleFileUpload(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":  "File upload endpoint ready",
		"filename": file.Filename,
	})
}
