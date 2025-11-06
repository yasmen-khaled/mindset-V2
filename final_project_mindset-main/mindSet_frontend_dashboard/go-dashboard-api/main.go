package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

var db *sql.DB

func main() {
	// Database credentials
	dbHost := "127.0.0.1"
	dbPort := "3306"
	dbUser := "root"
	dbPass := ""
	dbName := "laravel"

	// Construct the database connection string
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", dbUser, dbPass, dbHost, dbPort, dbName)

	// Connect to the database
	var err error
	db, err = sql.Open("mysql", dsn)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Test the connection
	err = db.Ping()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Connected to the database!")

	r := mux.NewRouter()

	// Enable CORS for Flutter app
	corsMiddleware := handlers.CORS(
		handlers.AllowedOrigins([]string{"*"}),
		handlers.AllowedMethods([]string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}),
		handlers.AllowedHeaders([]string{"Content-Type", "Authorization"}),
	)
	r.Use(corsMiddleware)

	// Dashboard API Routes
	r.HandleFunc("/api/dashboard/stats", getDashboardStats).Methods("GET")
	
	// Categories API
	r.HandleFunc("/api/categories", getCategories).Methods("GET")
	r.HandleFunc("/api/categories", addCategory).Methods("POST")
	r.HandleFunc("/api/categories/{id}", getCategory).Methods("GET")
	r.HandleFunc("/api/categories/{id}", updateCategory).Methods("PUT")
	r.HandleFunc("/api/categories/{id}", deleteCategory).Methods("DELETE")
	
	// Tasks API
	r.HandleFunc("/api/tasks", getTasks).Methods("GET")
	r.HandleFunc("/api/tasks", addTask).Methods("POST")
	r.HandleFunc("/api/tasks/{id}", getTask).Methods("GET")
	r.HandleFunc("/api/tasks/{id}", updateTask).Methods("PUT")
	r.HandleFunc("/api/tasks/{id}", deleteTask).Methods("DELETE")
	r.HandleFunc("/api/tasks/{id}/toggle", toggleTaskStatus).Methods("PATCH")
	
	// Category Tasks API
	r.HandleFunc("/api/categories/{categoryId}/tasks", getCategoryTasks).Methods("GET")
	
	// Users API
	r.HandleFunc("/api/users", getUsers).Methods("GET")
	r.HandleFunc("/api/users/{id}", getUser).Methods("GET")

	// Start the server
	fmt.Println("Dashboard API Server listening on port 8002")
	log.Fatal(http.ListenAndServe(":8002", r))
}

// Data Models
type Category struct {
	ID        int                    `json:"id"`
	Name      string                 `json:"name"`
	Image     *string                `json:"image,omitempty"`
	Level     int                    `json:"level"`
	Options   map[string]interface{} `json:"options,omitempty"`
	Status    bool                   `json:"status"`
	CreatedAt time.Time              `json:"created_at"`
	UpdatedAt time.Time              `json:"updated_at"`
}

type Task struct {
	ID          int       `json:"id"`
	CategoryID  int       `json:"category_id"`
	Title       string    `json:"title"`
	Description *string   `json:"description,omitempty"`
	Priority    string    `json:"priority"`
	Completed   bool      `json:"completed"`
	VideoURL    *string   `json:"video_url,omitempty"`
	Image       *string   `json:"image,omitempty"`
	Avatar      *string   `json:"avatar,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type User struct {
	ID        int       `json:"id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type DashboardStats struct {
	TotalCategories int `json:"total_categories"`
	TotalTasks      int `json:"total_tasks"`
	CompletedTasks  int `json:"completed_tasks"`
	TotalUsers      int `json:"total_users"`
	CategoriesByLevel map[int]int `json:"categories_by_level"`
}

// Dashboard Stats
func getDashboardStats(w http.ResponseWriter, r *http.Request) {
	var stats DashboardStats
	
	// Get total categories
	err := db.QueryRow("SELECT COUNT(*) FROM categories").Scan(&stats.TotalCategories)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	
	// Get total tasks
	err = db.QueryRow("SELECT COUNT(*) FROM tasks").Scan(&stats.TotalTasks)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	
	// Get completed tasks
	err = db.QueryRow("SELECT COUNT(*) FROM tasks WHERE completed = true").Scan(&stats.CompletedTasks)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	
	// Get total users
	err = db.QueryRow("SELECT COUNT(*) FROM users").Scan(&stats.TotalUsers)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	
	// Get categories by level
	rows, err := db.Query("SELECT level, COUNT(*) FROM categories GROUP BY level")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()
	
	stats.CategoriesByLevel = make(map[int]int)
	for rows.Next() {
		var level, count int
		err = rows.Scan(&level, &count)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		stats.CategoriesByLevel[level] = count
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(stats)
}

// Categories API
func getCategories(w http.ResponseWriter, r *http.Request) {
	level := r.URL.Query().Get("level")
	
	var query string
	var args []interface{}
	
	if level != "" {
		query = "SELECT id, name, image, level, options, status, created_at, updated_at FROM categories WHERE level = ?"
		args = append(args, level)
	} else {
		query = "SELECT id, name, image, level, options, status, created_at, updated_at FROM categories"
	}
	
	rows, err := db.Query(query, args...)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()
	
	var categories []Category
	for rows.Next() {
		var category Category
		var optionsJSON []byte
		err = rows.Scan(&category.ID, &category.Name, &category.Image, &category.Level, &optionsJSON, &category.Status, &category.CreatedAt, &category.UpdatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		
		if len(optionsJSON) > 0 {
			err = json.Unmarshal(optionsJSON, &category.Options)
			if err != nil {
				http.Error(w, "Failed to unmarshal options", http.StatusInternalServerError)
				return
			}
		}
		
		categories = append(categories, category)
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(categories)
}

func getCategory(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	var category Category
	var optionsJSON []byte
	
	err := db.QueryRow("SELECT id, name, image, level, options, status, created_at, updated_at FROM categories WHERE id = ?", id).
		Scan(&category.ID, &category.Name, &category.Image, &category.Level, &optionsJSON, &category.Status, &category.CreatedAt, &category.UpdatedAt)
	
	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "Category not found", http.StatusNotFound)
		} else {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		return
	}
	
	if len(optionsJSON) > 0 {
		err = json.Unmarshal(optionsJSON, &category.Options)
		if err != nil {
			http.Error(w, "Failed to unmarshal options", http.StatusInternalServerError)
			return
		}
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(category)
}

func addCategory(w http.ResponseWriter, r *http.Request) {
	var category Category
	err := json.NewDecoder(r.Body).Decode(&category)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	optionsJSON, err := json.Marshal(category.Options)
	if err != nil {
		http.Error(w, "Failed to marshal options", http.StatusBadRequest)
		return
	}

	result, err := db.Exec("INSERT INTO categories (name, image, level, options, status) VALUES (?, ?, ?, ?, ?)", 
		category.Name, category.Image, category.Level, optionsJSON, category.Status)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	id, _ := result.LastInsertId()
	category.ID = int(id)
	
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(category)
}

func updateCategory(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	var category Category
	err := json.NewDecoder(r.Body).Decode(&category)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	
	optionsJSON, err := json.Marshal(category.Options)
	if err != nil {
		http.Error(w, "Failed to marshal options", http.StatusBadRequest)
		return
	}
	
	_, err = db.Exec("UPDATE categories SET name = ?, image = ?, level = ?, options = ?, status = ? WHERE id = ?",
		category.Name, category.Image, category.Level, optionsJSON, category.Status, id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Category updated successfully"})
}

func deleteCategory(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	_, err := db.Exec("DELETE FROM categories WHERE id = ?", id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Category deleted successfully"})
}

// Tasks API
func getTasks(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT id, category_id, title, description, priority, completed, video_url, image, avatar, created_at, updated_at FROM tasks")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var tasks []Task
	for rows.Next() {
		var task Task
		err = rows.Scan(&task.ID, &task.CategoryID, &task.Title, &task.Description, &task.Priority, &task.Completed, &task.VideoURL, &task.Image, &task.Avatar, &task.CreatedAt, &task.UpdatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		tasks = append(tasks, task)
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(tasks)
}

func getCategoryTasks(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	categoryId := vars["categoryId"]
	
	rows, err := db.Query("SELECT id, category_id, title, description, priority, completed, video_url, image, avatar, created_at, updated_at FROM tasks WHERE category_id = ?", categoryId)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()
	
	var tasks []Task
	for rows.Next() {
		var task Task
		err = rows.Scan(&task.ID, &task.CategoryID, &task.Title, &task.Description, &task.Priority, &task.Completed, &task.VideoURL, &task.Image, &task.Avatar, &task.CreatedAt, &task.UpdatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		tasks = append(tasks, task)
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(tasks)
}

func addTask(w http.ResponseWriter, r *http.Request) {
	var task Task
	err := json.NewDecoder(r.Body).Decode(&task)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	
	result, err := db.Exec("INSERT INTO tasks (category_id, title, description, priority, completed, video_url, image, avatar) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
		task.CategoryID, task.Title, task.Description, task.Priority, task.Completed, task.VideoURL, task.Image, task.Avatar)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	
	id, _ := result.LastInsertId()
	task.ID = int(id)
	
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(task)
}

func toggleTaskStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	var request struct {
		Completed bool `json:"completed"`
	}
	
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	
	_, err = db.Exec("UPDATE tasks SET completed = ? WHERE id = ?", request.Completed, id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Task status updated successfully"})
}

func getTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	var task Task
	err := db.QueryRow("SELECT id, category_id, title, description, priority, completed, video_url, image, avatar, created_at, updated_at FROM tasks WHERE id = ?", id).
		Scan(&task.ID, &task.CategoryID, &task.Title, &task.Description, &task.Priority, &task.Completed, &task.VideoURL, &task.Image, &task.Avatar, &task.CreatedAt, &task.UpdatedAt)
	
	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "Task not found", http.StatusNotFound)
		} else {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		return
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(task)
}

func updateTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	var task Task
	err := json.NewDecoder(r.Body).Decode(&task)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

	_, err = db.Exec("UPDATE tasks SET category_id = ?, title = ?, description = ?, priority = ?, completed = ?, video_url = ?, image = ?, avatar = ? WHERE id = ?",
		task.CategoryID, task.Title, task.Description, task.Priority, task.Completed, task.VideoURL, task.Image, task.Avatar, id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Task updated successfully"})
}

func deleteTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	_, err := db.Exec("DELETE FROM tasks WHERE id = ?", id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Task deleted successfully"})
}

// Users API
func getUsers(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT id, name, email, created_at, updated_at FROM users")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()
	
	var users []User
	for rows.Next() {
		var user User
		err = rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		users = append(users, user)
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(users)
}

func getUser(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	var user User
	err := db.QueryRow("SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?", id).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	
	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "User not found", http.StatusNotFound)
		} else {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		return
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(user)
}

// Legacy functions for backward compatibility
func getData(w http.ResponseWriter, r *http.Request) {
	getCategories(w, r)
}