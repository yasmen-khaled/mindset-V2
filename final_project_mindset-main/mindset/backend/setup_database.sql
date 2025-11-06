-- Mindset Database Setup
-- Run this script in MySQL to create the database and tables

-- Create database
CREATE DATABASE IF NOT EXISTS mindset_db;
USE mindset_db;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    gender ENUM('male', 'female', 'other') DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    INDEX idx_phone_number (phone_number),
    INDEX idx_username (username),
    INDEX idx_active (is_active)
);

-- Create SMS verification codes table
CREATE TABLE IF NOT EXISTS sms_verification_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL,
    verification_code VARCHAR(10) NOT NULL,
    code_type ENUM('password_reset', 'phone_verification') DEFAULT 'password_reset',
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP NULL,
    is_used BOOLEAN DEFAULT FALSE,
    attempts INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_phone_code (phone_number, verification_code),
    INDEX idx_expires_at (expires_at),
    INDEX idx_code_type (code_type),
    INDEX idx_used (is_used)
);

-- Insert test users with hashed passwords
-- Password for all test users is: password123
INSERT INTO users (username, phone_number, password_hash, gender) VALUES 
(
    'john_doe', 
    '+12345678901', 
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password123
    'male'
),
(
    'sarah_chen', 
    '+12345678902', 
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password123
    'female'
),
(
    'demo_user', 
    '+12345678903', 
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password123
    'male'
),
(
    'test_user', 
    '+12345678999', 
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password123
    'male'
)
ON DUPLICATE KEY UPDATE 
    password_hash = VALUES(password_hash),
    updated_at = CURRENT_TIMESTAMP;

-- Create user preferences table (for Flutter app settings)
CREATE TABLE IF NOT EXISTS user_preferences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    learning_path ENUM('software_engineering', 'tmazight_language', 'academic_courses') NOT NULL,
    app_language ENUM('arabic', 'english', 'tmazight') NOT NULL,
    academic_level ENUM('kg1', 'kg2', 'kg3', 'high1', 'high2', 'high3') NULL,
    tmazight_script ENUM('tifinagh', 'arabic_letters') NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
);

-- Create user progress table (for learning progress)
CREATE TABLE IF NOT EXISTS user_progress (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    course_type VARCHAR(50) NOT NULL,
    level_completed INT DEFAULT 0,
    total_score INT DEFAULT 0,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_course (user_id, course_type),
    INDEX idx_user_id (user_id),
    INDEX idx_course_type (course_type)
);

-- Show created tables
SHOW TABLES;

-- Show test users
SELECT id, username, phone_number, gender, is_active, created_at FROM users;

-- Database setup completed!
SELECT 'Database setup completed successfully!' AS status; 