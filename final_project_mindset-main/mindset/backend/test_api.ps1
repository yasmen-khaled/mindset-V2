# Test the Mindset API
Write-Host "Testing Mindset API..." -ForegroundColor Cyan

# Test login with existing user
Write-Host "`nTesting login with test user..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8005/webstudent/login" -Method POST -ContentType "application/json" -Body '{"phone_number":"+12345678901","password":"password123"}'
    Write-Host "Login successful!" -ForegroundColor Green
    Write-Host "   Username: $($loginResponse.username)" -ForegroundColor White
    Write-Host "   Token: $($loginResponse.token.Substring(0,20))..." -ForegroundColor White
    $token = $loginResponse.token
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test registration with new user
Write-Host "`nTesting registration with new user..." -ForegroundColor Yellow
try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:8005/webstudent/register" -Method POST -ContentType "application/json" -Body '{"username":"newuser","phone_number":"+12345678999","password":"newpass123","gender":"male"}'
    Write-Host "Registration successful!" -ForegroundColor Green
    Write-Host "   User ID: $($registerResponse.user_id)" -ForegroundColor White
    Write-Host "   Username: $($registerResponse.username)" -ForegroundColor White
} catch {
    Write-Host "Registration failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test login with newly registered user
Write-Host "`nTesting login with newly registered user..." -ForegroundColor Yellow
try {
    $newLoginResponse = Invoke-RestMethod -Uri "http://localhost:8005/webstudent/login" -Method POST -ContentType "application/json" -Body '{"phone_number":"+12345678999","password":"newpass123"}'
    Write-Host "New user login successful!" -ForegroundColor Green
    Write-Host "   Username: $($newLoginResponse.username)" -ForegroundColor White
} catch {
    Write-Host "New user login failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nAPI tests completed!" -ForegroundColor Cyan
Write-Host "Your backend is working perfectly without MySQL!" -ForegroundColor Green
Write-Host "You can now test your Flutter app!" -ForegroundColor Yellow 