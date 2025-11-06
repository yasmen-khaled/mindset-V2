# 🚀 Mindset Backend Setup Guide

## ✅ Current Status: Backend vs Flutter Matching

### Your Flutter App Has:
- **Login Page** (`login.dart`) ✅ - Now connected to API
- **SignUp Page** (`SignUp.dart`) ✅ - Now connected to API  
- **Password Reset** (`Repassword.dart`) ✅ - Now connected to API
- **API Service** (`lib/services/api_service.dart`) ✅ - NEW: HTTP calls to backend

### Your Go Backend Provides:
- `POST /webstudent/login` ✅
- `POST /webstudent/register` ✅
- `POST /webstudent/update_password` ✅
- `POST /webstudent/get_profile` ✅
- `POST /webstudent/upload_file` ✅

## 🎯 **Perfect Match!** Your backend endpoints exactly match what Flutter needs.

---

## 🚀 Quick Test Your Setup

### 1. Start Backend Server
```bash
cd backend
go run simple_server.go
```

### 2. Test Flutter App
```bash
cd .. # Go back to root
flutter run
```

### 3. Try the Login Flow:
1. Click "Create Account" → Register with email/password
2. Go back → Login with same credentials
3. Success! 🎉

---

## 💾 Database Setup (Optional)

Currently using **in-memory storage** (perfect for development). To add persistent database:

### Option A: MySQL Setup

1. **Install MySQL** and create database:
```sql
CREATE DATABASE mindset_db;
USE mindset_db;
```

2. **Run the schema** (use `database_schema.sql`):
```sql
source backend/database_schema.sql
```

3. **Update Go dependencies** for MySQL:
```bash
cd backend
go get github.com/go-sql-driver/mysql
```

4. **Enable database in code** - Modify `simple_server.go`:
```go
// Change these constants:
const (
    USE_DATABASE = true  // Set to true
    DB_TYPE      = "mysql"
    MYSQL_DSN    = "your_username:your_password@tcp(localhost:3306)/mindset_db?parseTime=true"
)

// Add import:
import _ "github.com/go-sql-driver/mysql"
```

### Option B: PostgreSQL Setup

1. **Install PostgreSQL** and create database:
```sql
CREATE DATABASE mindset_db;
```

2. **Use PostgreSQL section** from `database_schema.sql`

3. **Update Go dependencies**:
```bash
go get github.com/lib/pq
```

4. **Enable PostgreSQL**:
```go
const (
    USE_DATABASE = true
    DB_TYPE      = "postgres" 
    POSTGRES_DSN = "host=localhost port=5432 user=username password=password dbname=mindset_db sslmode=disable"
)

// Add import:
import _ "github.com/lib/pq"
```

---

## 🧪 Testing Your API

### Test Registration:
```bash
curl -X POST http://localhost:8005/webstudent/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com", 
    "password": "password123",
    "gender": "male"
  }'
```

### Test Login:
```bash
curl -X POST http://localhost:8005/webstudent/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Test Password Update:
```bash
curl -X POST http://localhost:8005/webstudent/update_password \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "old_password": "password123",
    "new_password": "newpassword456"
  }'
```

---

## 🔧 Advanced Configuration

### Environment Variables (Recommended for Production)
Create `.env` file in backend/:
```env
JWT_SECRET=your-super-secret-jwt-key-here
DB_HOST=localhost
DB_PORT=3306
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=mindset_db
```

### Security Headers
Your backend already includes:
- ✅ CORS configuration
- ✅ JWT token authentication
- ✅ Password hashing (bcrypt)
- ✅ Input validation

### Production Checklist
- [ ] Change JWT secret key
- [ ] Use environment variables for DB credentials
- [ ] Add rate limiting
- [ ] Add request logging
- [ ] Set up HTTPS
- [ ] Configure database connection pooling

---

## 🐛 Troubleshooting

### "Connection refused" error:
- Make sure Go server is running on port 8005
- Check if Flutter app is using correct URL (`http://localhost:8005`)

### "Invalid credentials" error:
- Register a new user first
- Check email/password combination
- Verify password is at least 6 characters

### Database connection errors:
- Verify database is running
- Check connection string in code
- Ensure database exists and schema is created

### Flutter HTTP errors:
- Add `http: ^1.2.0` to `pubspec.yaml` (already done ✅)
- Run `flutter pub get`
- Check network permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## 📁 File Structure
```
mindset/
├── backend/
│   ├── simple_server.go        # ✅ Main server (in-memory)
│   ├── database_schema.sql     # ✅ Database schema
│   ├── SETUP_GUIDE.md         # ✅ This guide
│   ├── README.md              # ✅ Quick start
│   └── go.mod                 # ✅ Dependencies
├── lib/
│   ├── services/
│   │   └── api_service.dart   # ✅ NEW: API calls
│   └── pages/
│       ├── login.dart         # ✅ Updated with API
│       ├── SignUp.dart        # ✅ Updated with API
│       └── Repassword.dart    # ✅ Updated with API
└── pubspec.yaml               # ✅ Has http dependency
```

## 🎉 Congratulations!

Your Flutter app is now **perfectly connected** to your Go backend! 

**Current Status:** Ready for development and testing! 🚀 