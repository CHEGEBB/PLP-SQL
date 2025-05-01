-- Task Manager Database Schema

CREATE DATABASE IF NOT EXISTS task_manager;
USE task_manager;

-- Users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Projects table
CREATE TABLE projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Tasks table
CREATE TABLE tasks (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    status ENUM('todo', 'in_progress', 'completed') DEFAULT 'todo',
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    due_date DATE,
    project_id INT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Sample data insertion
INSERT INTO users (username, email, password_hash) VALUES
('john_doe', 'john@example.com', '$2b$12$kUFX5KLhDJUkS4lHv0vLfeoeMwFLASfOmSy4ASM2K61ZDmV1HqNLW'), -- password: password123
('jane_smith', 'jane@example.com', '$2b$12$RQ6jQxmUyuwGrS9QXZqSVOwQfN4Lqm89.Z5Q9JFQ.4Uu3/76kcB4a'); -- password: securepass

INSERT INTO projects (title, description, user_id) VALUES
('Personal Website', 'Redesign of my portfolio website', 1),
('Mobile App', 'Fitness tracking application', 1),
('Work Tasks', 'Regular tasks for my job', 2);

INSERT INTO tasks (title, description, status, priority, due_date, project_id, user_id) VALUES
('Design homepage', 'Create wireframes for the homepage', 'in_progress', 'high', '2025-05-15', 1, 1),
('Setup MySQL database', 'Configure and initialize the database', 'completed', 'high', '2025-04-28', 1, 1),
('Research frameworks', 'Evaluate different frontend frameworks', 'todo', 'medium', '2025-05-10', 1, 1),
('Design UI mockups', 'Create mockups for the mobile app', 'todo', 'medium', '2025-06-01', 2, 1),
('Weekly report', 'Prepare weekly status report', 'todo', 'high', '2025-05-03', 3, 2);