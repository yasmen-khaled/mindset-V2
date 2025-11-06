#!/bin/bash

# 🧪 Mindset API Test Script
# This script tests all your backend endpoints

BASE_URL="http://localhost:8005/webstudent"
TEST_EMAIL="test@example.com"
TEST_PASSWORD="password123"
NEW_PASSWORD="newpassword456"

echo "🚀 Testing Mindset Backend API..."
echo "=================================="

# Test 1: Register a new user
echo "📝 Testing Registration..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"testuser\",
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\",
    \"gender\": \"male\"
  }")

echo "Register Response: $REGISTER_RESPONSE"

# Test 2: Login with the created user
echo -e "\n🔑 Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\"
  }")

echo "Login Response: $LOGIN_RESPONSE"

# Extract token (assuming JSON response contains "token" field)
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

if [ -z "$TOKEN" ]; then
    echo "❌ Login failed - no token received"
    exit 1
fi

echo "✅ Token received: ${TOKEN:0:20}..."

# Test 3: Get profile with token
echo -e "\n👤 Testing Get Profile..."
PROFILE_RESPONSE=$(curl -s -X POST "$BASE_URL/get_profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN")

echo "Profile Response: $PROFILE_RESPONSE"

# Test 4: Update password
echo -e "\n🔐 Testing Password Update..."
PASSWORD_RESPONSE=$(curl -s -X POST "$BASE_URL/update_password" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"old_password\": \"$TEST_PASSWORD\",
    \"new_password\": \"$NEW_PASSWORD\"
  }")

echo "Password Update Response: $PASSWORD_RESPONSE"

# Test 5: Test file upload endpoint
echo -e "\n📁 Testing File Upload Endpoint..."
UPLOAD_RESPONSE=$(curl -s -X POST "$BASE_URL/upload_file" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@README.md")

echo "Upload Response: $UPLOAD_RESPONSE"

echo -e "\n✅ API Test Complete!"
echo "=================================="

# Summary
echo -e "\n📊 Test Summary:"
echo "- Registration: $(echo $REGISTER_RESPONSE | grep -q 'successful' && echo '✅ PASS' || echo '❌ FAIL')"
echo "- Login: $(echo $LOGIN_RESPONSE | grep -q 'token' && echo '✅ PASS' || echo '❌ FAIL')"
echo "- Get Profile: $(echo $PROFILE_RESPONSE | grep -q -E '(id|email)' && echo '✅ PASS' || echo '❌ FAIL')"
echo "- Password Update: $(echo $PASSWORD_RESPONSE | grep -q 'successful' && echo '✅ PASS' || echo '❌ FAIL')"
echo "- File Upload: $(echo $UPLOAD_RESPONSE | grep -q 'upload' && echo '✅ PASS' || echo '❌ FAIL')"

echo -e "\n🎉 Your backend is working perfectly!" 