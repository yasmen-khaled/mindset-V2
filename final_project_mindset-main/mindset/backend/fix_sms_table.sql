-- Add missing SMS verification codes table
CREATE TABLE IF NOT EXISTS sms_verification_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL,
    verification_code VARCHAR(10) NOT NULL,
    code_type ENUM('password_reset', 'phone_verification') DEFAULT 'password_reset',
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_phone_code (phone_number, verification_code),
    INDEX idx_expires_at (expires_at),
    INDEX idx_code_type (code_type)
);

-- Update test users with proper bcrypt hash for password123
UPDATE users SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjQp5xW5W/vVPLlR8DBeeNKNzIABLJm' WHERE username IN ('john_doe', 'sarah_chen', 'alex_kumar', 'maria_garcia', 'ahmed_libya', 'fatima_libya', 'demo_user');

-- Check if tables exist
SELECT 'Users table:' as info, COUNT(*) as user_count FROM users;
SELECT 'SMS table:' as info, COUNT(*) as sms_count FROM sms_verification_codes; 