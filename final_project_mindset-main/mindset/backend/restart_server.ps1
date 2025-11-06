# Stop any existing Go processes
Write-Host "Stopping existing server processes..." -ForegroundColor Yellow
Get-Process -Name "go" -ErrorAction SilentlyContinue | Stop-Process -Force

# Wait a moment
Start-Sleep -Seconds 2

# Change to backend directory and start server
Write-Host "Starting backend server..." -ForegroundColor Green
Set-Location -Path "backend"
go run simple_server.go 