-- =============================================
-- MINDSET DATABASE SETUP FOR PHPMYADMIN
-- =============================================

-- Create the database (if it doesn't exist)
CREATE DATABASE IF NOT EXISTS `mindset_db` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Use the database
USE `mindset_db`;

-- =============================================
-- Drop existing tables if they exist
-- =============================================
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `user_sessions`;
DROP TABLE IF EXISTS `users`;
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- USERS TABLE
-- =============================================
CREATE TABLE `users` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(50) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `gender` ENUM('male', 'female', 'other') DEFAULT NULL,
    `profile_picture` VARCHAR(255) DEFAULT NULL,
    `is_active` BOOLEAN DEFAULT TRUE,
    `email_verified` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `last_login` TIMESTAMP NULL DEFAULT NULL,
    
    PRIMARY KEY (`id`),
    UNIQUE KEY `email` (`email`),
    KEY `idx_username` (`username`),
    KEY `idx_active` (`is_active`),
    KEY `idx_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- USER SESSIONS TABLE (for JWT token management)
-- =============================================
CREATE TABLE `user_sessions` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `token_hash` VARCHAR(255) NOT NULL,
    `expires_at` TIMESTAMP NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `is_revoked` BOOLEAN DEFAULT FALSE,
    `device_info` VARCHAR(255) DEFAULT NULL,
    `ip_address` VARCHAR(45) DEFAULT NULL,
    
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_token_hash` (`token_hash`),
    KEY `idx_expires_at` (`expires_at`),
    
    CONSTRAINT `fk_sessions_user_id` 
        FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- INSERT SAMPLE DATA FOR TESTING
-- =============================================
-- Password for all test users is 'password123'
-- Hash generated with bcrypt cost 10
INSERT INTO `users` (`username`, `email`, `password_hash`, `gender`) VALUES 
('john_doe', 'john@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'male'),
('jane_smith', 'jane@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'female'),
('test_user', 'test@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'other');

-- =============================================
-- VERIFY SETUP - Run these to check everything works
-- =============================================

-- Check if tables were created
SHOW TABLES;

-- Check users table structure
DESCRIBE `users`;

-- Check sample data
SELECT `id`, `username`, `email`, `gender`, `is_active`, `created_at` FROM `users`;

-- =============================================
-- USEFUL QUERIES FOR DEVELOPMENT
-- =============================================

-- Get all active users
-- SELECT * FROM users WHERE is_active = TRUE;

-- Get user login history
-- SELECT u.username, u.email, u.last_login 
-- FROM users u 
-- WHERE u.last_login IS NOT NULL 
-- ORDER BY u.last_login DESC;

-- Clean expired sessions
-- DELETE FROM user_sessions 
-- WHERE expires_at < NOW() OR is_revoked = TRUE;

-- Get active sessions
-- SELECT s.id, u.username, s.created_at, s.expires_at, s.device_info 
-- FROM user_sessions s 
-- JOIN users u ON s.user_id = u.id 
-- WHERE s.expires_at > NOW() AND s.is_revoked = FALSE;

-- =============================================
-- SUCCESS MESSAGE
-- =============================================
SELECT 'Database setup completed successfully!' AS message; 