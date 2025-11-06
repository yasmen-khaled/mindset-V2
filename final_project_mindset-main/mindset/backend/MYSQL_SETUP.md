# 🛠️ MySQL Setup Guide for Mindset Backend

## 🚨 **CURRENT ISSUE**: Database Error
Your backend is getting "Database error" because MySQL is not properly connected. Here's how to fix it:

---

## 🎯 **Option 1: Fix MySQL (Recommended)**

### **Step 1: Install/Setup MySQL**

#### **If you're using XAMPP:**
1. **Open XAMPP Control Panel as Administrator**
2. **Stop MySQL** if it's running (click Stop)
3. **Fix MySQL data folder:**
   ```bash
   # Navigate to XAMPP folder (usually C:\xampp)
   # Rename: mysql\data → mysql\data_backup
   # Copy: mysql\backup → mysql\data
   ```
4. **Start MySQL** (click Start button)
5. **Verify it's running**: Look for green "Running" status

#### **If you're using standalone MySQL:**
1. **Start MySQL service**:
   ```cmd
   net start mysql
   ```
2. **Or use MySQL Workbench/phpMyAdmin**

### **Step 2: Create Database**
1. **Open MySQL command line** or **phpMyAdmin**
2. **Run the setup script**:
   ```bash
   mysql -u root -p < backend/setup_database.sql
   ```
   
   **OR copy-paste this into phpMyAdmin:**
   ```sql
   -- Copy the entire content from backend/setup_database.sql
   ```

### **Step 3: Test Connection**
```bash
# Test if MySQL is accessible
mysql -u root -p -e "SHOW DATABASES;"
```

### **Step 4: Update Backend Config (if needed)**
Edit `backend/simple_server.go` if your MySQL credentials are different:
```go
const (
    DB_USER     = "root"         // Your MySQL username
    DB_PASSWORD = ""             // Your MySQL password (empty for XAMPP)
    DB_HOST     = "localhost"    // Usually localhost
    DB_PORT     = "3306"         // Usually 3306
    DB_NAME     = "mindset_db"   // Database name
)
```

### **Step 5: Restart Backend**
```bash
cd backend
go run simple_server.go
```

---

## 🎯 **Option 2: Use SQLite (Simpler)**

If MySQL keeps giving problems, switch to SQLite:

1. **Update `go.mod`**:
   ```bash
   cd backend
   go get github.com/mattn/go-sqlite3
   ```

2. **Create SQLite version** (I can help with this)

---

## 🧪 **Testing Your Setup**

### **Test 1: Check if MySQL is running**
```cmd
netstat -an | findstr :3306
```
**Expected**: Should show `LISTENING` on port 3306

### **Test 2: Test database connection**
```bash
mysql -u root -p -e "USE mindset_db; SELECT COUNT(*) FROM users;"
```
**Expected**: Should show `4` (test users)

### **Test 3: Test backend API**
```bash
curl -X POST http://localhost:8005/webstudent/login \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"+12345678901","password":"password123"}'
```
**Expected**: Should return login success with token

---

## 🔧 **Common Issues & Solutions**

### **Issue**: "Database error" in backend
**Solution**: 
- Verify MySQL is running on port 3306
- Check credentials in `simple_server.go`
- Ensure `mindset_db` database exists

### **Issue**: "Access denied for user 'root'"
**Solution**: 
- Reset MySQL root password
- Or use different MySQL user
- Update `DB_PASSWORD` in backend config

### **Issue**: "Can't connect to MySQL server"
**Solution**: 
- Start MySQL service: `net start mysql`
- Check if port 3306 is free: `netstat -an | findstr :3306`
- Restart XAMPP MySQL

### **Issue**: MySQL won't start in XAMPP
**Solution**: 
1. **Stop any MySQL services**:
   ```cmd
   net stop mysql
   taskkill /f /im mysqld.exe
   ```
2. **Reset XAMPP MySQL data**:
   - Rename `C:\xampp\mysql\data` to `data_backup`
   - Copy `C:\xampp\mysql\backup` to `C:\xampp\mysql\data`
3. **Start MySQL in XAMPP**

---

## 📋 **Test Users (After Setup)**

Once MySQL is working, you can login with these test accounts:

| Phone Number | Password | Username |
|-------------|----------|----------|
| +12345678901 | password123 | john_doe |
| +12345678902 | password123 | sarah_chen |
| +12345678903 | password123 | demo_user |
| +12345678999 | password123 | test_user |

---

## 🚀 **Quick Commands**

**Start everything:**
```bash
# Start MySQL (XAMPP or service)
# Then start backend:
cd backend
go run simple_server.go

# In another terminal, test:
curl -X POST http://localhost:8005/webstudent/login -H "Content-Type: application/json" -d '{"phone_number":"+12345678901","password":"password123"}'
```

**Expected response:**
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "john_doe",
  "country": "US/Canada"
}
```

---

## ❓ **Need Help?**

If you're still getting database errors after following this guide:

1. **Share the exact error message** from the backend logs
2. **Check if MySQL is running**: `netstat -an | findstr :3306`
3. **Try the SQLite option** if MySQL keeps failing

Your backend should work perfectly once MySQL is properly connected! 🎉 