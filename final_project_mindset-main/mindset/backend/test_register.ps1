Write-Host "Testing Registration API..." -ForegroundColor Cyan

$body = @{
    username = "testuser"
    phone_number = "+15551234567"
    password = "password123"
    gender = "male"
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri "http://localhost:8005/webstudent/register" -Method POST -ContentType "application/json" -Body $body
    Write-Host "REGISTRATION SUCCESS!" -ForegroundColor Green
    Write-Host "User ID: $($result.user_id)" -ForegroundColor White
    Write-Host "Username: $($result.username)" -ForegroundColor White
    Write-Host "Token: $($result.token.Substring(0,20))..." -ForegroundColor White
    Write-Host "Country: $($result.country)" -ForegroundColor White
} catch {
    Write-Host "REGISTRATION ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
} 