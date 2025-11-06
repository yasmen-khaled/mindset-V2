# Test login script for Mindset app

Write-Host "Testing Login API..." -ForegroundColor Cyan

Start-Sleep 3

$body = @{
    phone_number = "+12345678901"
    password = "password123"
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri "http://localhost:8005/webstudent/login" -Method POST -ContentType "application/json" -Body $body
    Write-Host "LOGIN SUCCESS!" -ForegroundColor Green
    Write-Host "Username: $($result.username)" -ForegroundColor White
    Write-Host "Token: $($result.token.Substring(0,20))..." -ForegroundColor White
    Write-Host "Country: $($result.country)" -ForegroundColor White
} catch {
    Write-Host "LOGIN ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
} 