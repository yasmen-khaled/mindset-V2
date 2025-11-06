# Test simple password reset script for Mindset app

$resetData = @{
    phone_number = "+218912345678"
    new_password = "newpassword123"
} | ConvertTo-Json

Write-Host "Testing password reset with:" $resetData

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8005/webstudent/reset_password" -Method POST -ContentType "application/json" -Body $resetData
    Write-Host "✅ Password reset successful!"
    Write-Host "Response:" ($response | ConvertTo-Json -Depth 3)
} catch {
    Write-Host "❌ Password reset failed!"
    Write-Host "Status:" $_.Exception.Response.StatusCode
    Write-Host "Error:" $_.Exception.Message
    
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error Body:" $errorBody
    }
} 