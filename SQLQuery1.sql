-- Create the DDR Portal database
CREATE DATABASE DDR_Portal;
GO

-- Select the DDR Portal database
USE DDR_Portal;
GO

-- Create ROLES table
CREATE TABLE ROLES (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name VARCHAR(255),
    [description] VARCHAR(MAX)
);
GO

-- Insert into ROLES
INSERT INTO ROLES (role_name, [description]) VALUES
('Admin', 'The Admin role possesses comprehensive control over the portal''s structure and user permissions.'),
('Head', 'The Head role focuses on overseeing content and user actions within specific categories.'),
('Faculty', 'The Faculty role primarily interacts with the portal for uploading, viewing, and managing their own files.');
GO

-- Create USER_ROLES table
CREATE TABLE USER_ROLES (
    user_id INT,
    role_id INT,
    assigned_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES auth_user(id),
    FOREIGN KEY (role_id) REFERENCES ROLES(role_id),
    PRIMARY KEY (user_id, role_id)
);
GO

INSERT INTO USER_ROLES (user_id, role_id)
VALUES
(1, 1),  -- Admin
(2, 2),  -- Head
(3, 3);  -- Faculty
GO