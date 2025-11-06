# Mindset Backend Server

Simple Go backend server for the Mindset Flutter application.

## Quick Start

```bash
# Navigate to backend directory
cd backend

# Run the server
go run simple_server.go
```

The server will start on port 8005 with the following endpoints:

## Endpoints

### Authentication
- `POST /webstudent/login` - User login
- `POST /webstudent/register` - User registration
- `POST /webstudent/update_password` - Update user password

### User Management
- `POST /webstudent/get_profile` - Get user profile
- `POST /webstudent/upload_file` - File upload

## Example Usage

### Register a new user:
```json
POST http://localhost:8005/webstudent/register
{
  "email": "test@example.com",
  "password": "password123"
}
```

### Login:
```json
POST http://localhost:8005/webstudent/login
{
  "email": "test@example.com",
  "password": "password123"
}
```

## Project Structure
```
backend/
├── simple_server.go    # Main server file
├── go.mod              # Go module definition
├── go.sum              # Dependency checksums
├── README.md           # This file
├── uploads/            # File upload directory
└── .gitignore          # Git ignore file
```

## Features
- ✅ CORS enabled for Flutter app
- ✅ JWT token authentication
- ✅ Password hashing with bcrypt
- ✅ In-memory user storage (for development)
- ✅ File upload support
- ✅ Clean, minimal structure

## Development
The server uses in-memory storage for testing. In production, you would want to add a proper database.

## Testing with Flutter
1. Start the Go server: `go run simple_server.go`
2. Open your Flutter app
3. The Flutter app will connect to `http://localhost:8005`
4. Test login, registration, and password reset functionality 