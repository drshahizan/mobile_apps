-- Create database
CREATE DATABASE edocs_db;

-- Connect to the database
\c edocs_db;

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(10) NOT NULL CHECK (role IN ('admin', 'user')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create documents table
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    file_type VARCHAR(50),
    uploaded_by INTEGER REFERENCES users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tags VARCHAR(50) DEFAULT 'procedure' NOT NULL CHECK (tags IN ('procedure', 'circular', 'archive', 'policy'))
);

-- Insert default admin user (password: admin123)
INSERT INTO users (username, password, role) 
VALUES ('admin', '$2b$10$rQZ9YZ9YZ9YZ9YZ9YZ9YZOqKqKqKqKqKqKqKqKqKqKqKqKqKqKqKq', 'admin');

-- Insert default regular user (password: user123)
INSERT INTO users (username, password, role) 
VALUES ('user', '$2b$10$rQZ9YZ9YZ9YZ9YZ9YZ9YZOqKqKqKqKqKqKqKqKqKqKqKqKqKqKqKq', 'user');
