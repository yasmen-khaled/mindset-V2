-- =============================================
-- MINDSET DATABASE SCHEMA
-- =============================================

-- Drop existing tables if they exist (for fresh setup)
DROP TABLE IF EXISTS sms_verification_codes;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS users;

-- =============================================
-- USERS TABLE
-- =============================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL UNIQUE, -- Changed from email to phone
    password_hash VARCHAR(255) NOT NULL,
    gender ENUM('male', 'female', 'other') DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE, -- Optional email for notifications
    phone_verified BOOLEAN DEFAULT FALSE, -- Phone verification status
    
    -- Profile information
    full_name VARCHAR(100) DEFAULT NULL,
    date_of_birth DATE DEFAULT NULL,
    profile_picture_url VARCHAR(500) DEFAULT NULL,
    bio TEXT DEFAULT NULL,
    
    -- Gaming stats
    level INT DEFAULT 1,
    stars INT DEFAULT 0,
    experience_points INT DEFAULT 0,
    problems_solved INT DEFAULT 0,
    days_streak INT DEFAULT 0,
    last_streak_date DATE DEFAULT NULL,
    
    -- Account metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    -- Indexes for performance
    INDEX idx_phone_number (phone_number),
    INDEX idx_username (username),
    INDEX idx_active (is_active),
    INDEX idx_level_stars (level, stars),
    INDEX idx_created_at (created_at)
);

-- =============================================
-- USER SESSIONS TABLE (for JWT token management)
-- =============================================
CREATE TABLE user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(255) DEFAULT NULL,
    ip_address VARCHAR(45) DEFAULT NULL, -- Supports both IPv4 and IPv6
    user_agent TEXT DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_session_token (session_token),
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_expires_at (expires_at)
);

-- =============================================
-- SMS VERIFICATION CODES TABLE (for password reset)
-- =============================================
CREATE TABLE sms_verification_codes (
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

-- =============================================
-- SAMPLE DATA FOR TESTING
-- =============================================
-- Insert test users (passwords are 'password123' hashed with bcrypt)
INSERT INTO users (
    username, 
    phone_number, 
    password_hash, 
    gender, 
    full_name, 
    level, 
    stars, 
    problems_solved, 
    days_streak,
    phone_verified
) VALUES 
('john_doe', '+1234567890', '$2a$10$EIXwKj6r1KL9p4rKd4d8UuYyQN5Zt8oWXX7J2GmLz1QF5HK8JQY3S', 'male', 'John Doe', 5, 120, 45, 7, TRUE),
('sarah_chen', '+1987654321', '$2a$10$EIXwKj6r1KL9p4rKd4d8UuYyQN5Zt8oWXX7J2GmLz1QF5HK8JQY3S', 'female', 'Sarah Chen', 7, 250, 145, 30, TRUE),
('alex_kumar', '+4412345678', '$2a$10$EIXwKj6r1KL9p4rKd4d8UuYyQN5Zt8oWXX7J2GmLz1QF5HK8JQY3S', 'male', 'Alex Kumar', 7, 245, 140, 25, TRUE),
('maria_garcia', '+34123456789', '$2a$10$EIXwKj6r1KL9p4rKd4d8UuYyQN5Zt8oWXX7J2GmLz1QF5HK8JQY3S', 'female', 'Maria Garcia', 6, 220, 89, 12, TRUE),
('ahmed_libya', '+218912345678', '$2a$10$EIXwKj6r1KL9p4rKd4d8UuYyQN5Zt8oWXX7J2GmLz1QF5HK8JQY3S', 'male', 'Ahmed Al-Libyan', 4, 180, 78, 15, TRUE),
('fatima_libya', '+218923456789', '$2a$10$EIXwKj6r1KL9p4rKd4d8UuYyQN5Zt8oWXX7J2GmLz1QF5HK8JQY3S', 'female', 'Fatima Benghazi', 6, 210, 95, 20, TRUE),
('demo_user', '+1555000000', '$2a$10$EIXwKj6r1KL9p4rKd4d8UuYyQN5Zt8oWXX7J2GmLz1QF5HK8JQY3S', 'other', 'Demo User', 1, 0, 0, 0, TRUE);

-- =============================================
-- USEFUL QUERIES FOR TESTING
-- =============================================

-- Check all users
-- SELECT id, username, phone_number, gender, created_at FROM users;

-- Check user sessions
-- SELECT s.*, u.username FROM user_sessions s JOIN users u ON s.user_id = u.id;

-- Clean expired sessions
-- DELETE FROM user_sessions WHERE expires_at < NOW() OR is_revoked = TRUE;

-- Check SMS verification codes
-- SELECT * FROM sms_verification_codes WHERE expires_at > NOW() ORDER BY created_at DESC;

-- Clean expired SMS codes
-- DELETE FROM sms_verification_codes WHERE expires_at < NOW();

-- =============================================
-- POSTGRESQL VERSION (if using PostgreSQL instead of MySQL)
-- =============================================

/*
-- Drop existing tables if they exist
DROP TABLE IF EXISTS sms_verification_codes CASCADE;
DROP TABLE IF EXISTS user_sessions CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create ENUM type for gender (PostgreSQL specific)
CREATE TYPE gender_enum AS ENUM ('male', 'female', 'other');

-- Users table for PostgreSQL
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    gender gender_enum DEFAULT NULL,
    profile_picture VARCHAR(255) DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL DEFAULT NULL
);

-- User sessions table for PostgreSQL
CREATE TABLE user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_revoked BOOLEAN DEFAULT FALSE,
    device_info VARCHAR(255) DEFAULT NULL,
    ip_address INET DEFAULT NULL
);

-- SMS verification codes table for PostgreSQL
CREATE TABLE sms_verification_codes (
    id SERIAL PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL,
    verification_code VARCHAR(10) NOT NULL,
    code_type VARCHAR(20) DEFAULT 'password_reset',
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for PostgreSQL
CREATE INDEX idx_users_phone_number ON users(phone_number);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_sessions_token_hash ON user_sessions(token_hash);
CREATE INDEX idx_sms_phone_code ON sms_verification_codes(phone_number, verification_code);

-- Function to update updated_at automatically (PostgreSQL)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE
    ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
*/ 