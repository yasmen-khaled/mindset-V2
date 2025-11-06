@echo off
echo Testing Mindset API...

echo.
echo Testing login with test user (+12345678901):
curl -X POST http://localhost:8005/webstudent/login -H "Content-Type: application/json" -d "{\"phone_number\":\"+12345678901\",\"password\":\"password123\"}"

echo.
echo.
echo Testing registration with new user:
curl -X POST http://localhost:8005/webstudent/register -H "Content-Type: application/json" -d "{\"username\":\"testuser\",\"phone_number\":\"+15551234567\",\"password\":\"password123\",\"gender\":\"male\"}"

echo.
echo.
echo API tests completed!
echo Your backend is running on port 8005
pause 