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

-- Create FOLDERS table
CREATE TABLE FOLDERS (
    id INT IDENTITY(1,1) PRIMARY KEY,
    folder_name NVARCHAR(255) NOT NULL,
    parent_id INT NULL,
    category NVARCHAR(100),
    created_at DATETIME2 DEFAULT SYSDATETIME(),
    updated_at DATETIME2 DEFAULT SYSDATETIME(),
    is_active BIT DEFAULT 1,

    CONSTRAINT FK_folders_parent FOREIGN KEY (parent_id) REFERENCES FOLDERS(id),
);

-- Add an index on parent_id for faster hierarchical queries
CREATE INDEX IX_folders_parent_id ON folders(parent_id);

-- Insert Into Folders
INSERT INTO FOLDERS (folder_name,parent_id,category,created_at,updated_at,is_active)
VALUES ('Academic Calendar', NULL, 'TLP', SYSDATETIME(), SYSDATETIME(), 1), 
('Coordinator Alumni Association (Department Level)', NULL, 'External', SYSDATETIME(), SYSDATETIME(), 1),
('Coordinator - Sports and Games', NULL, 'External', SYSDATETIME(), SYSDATETIME(), 1),
('CO-PO_Coordinator', NULL, 'OBE', SYSDATETIME(), SYSDATETIME(), 1),
('Course File, Lab manual & Handbook Coordinator', NULL, 'Audit', SYSDATETIME(), SYSDATETIME(), 1),
('SoDECA & Student Coordinator', NULL, 'MOOCs and Student Data', SYSDATETIME(), SYSDATETIME(), 1),
('Chief Batch Counselor(CBC) - CSE', NULL, 'TLP', SYSDATETIME(), SYSDATETIME(), 1),
('ERP Coordinator-CSE', NULL, ' Internal', SYSDATETIME(), SYSDATETIME(), 1),
('ERP Coordinator-CSE(Allied)', NULL, 'Internal', SYSDATETIME(), SYSDATETIME(), 1),
('Events organized by department for students and faculty (Sponsored events & Non Sponsored events)', NULL, 'R & D', SYSDATETIME(), SYSDATETIME(), 1),
('Examination Result Analysis Coordinator', NULL, 'Exam and T&P Cell', SYSDATETIME(), SYSDATETIME(), 1),
('External Examination Coordinator', NULL, 'Exam and T&P Cell', SYSDATETIME(), SYSDATETIME(), 1),
('Faculty & Staff Basic Details/Personal', NULL, 'Audit', SYSDATETIME(), SYSDATETIME(), 1),
('Faculty & Staff Basic Details/Higher studies', NULL, 'Audit', SYSDATETIME(), SYSDATETIME(), 1),
('Incubation Cell Coordinator(Department)', NULL, 'R & D', SYSDATETIME(), SYSDATETIME(), 1),
('Industrial Training', NULL, 'Exam and T&P Cell', SYSDATETIME(), SYSDATETIME(), 1),
('Infosys Springboard & IBM Skills Build', NULL, 'Internal', SYSDATETIME(), SYSDATETIME(), 1),
('IOT Center of Excellence Coordinator', NULL, 'R & D', SYSDATETIME(), SYSDATETIME(), 1),
('Member - Red Cross Club', NULL, 'External', SYSDATETIME(), SYSDATETIME(), 1),
('MoUs', NULL, 'TLP', SYSDATETIME(), SYSDATETIME(), 1),
('NAAC & Institute Ranking', NULL, 'Audit', SYSDATETIME(), SYSDATETIME(), 1),
('NIRF Data Format', NULL, 'External', SYSDATETIME(), SYSDATETIME(), 1),
('Oracle Academic & Red Hat Coordinator', NULL, 'Internal', SYSDATETIME(), SYSDATETIME(), 1),
('Placement Record', NULL, 'Exam and T&P Cell', SYSDATETIME(), SYSDATETIME(), 1),
('Publication and Patents (for faculty and Students) Coordinator', NULL, 'R & D', SYSDATETIME(), SYSDATETIME(), 1),
('Question Paper & Answer Sheet Vetting Committee', NULL, 'Exam and T&P Cell', SYSDATETIME(), SYSDATETIME(), 1),
('Remedial,Make-Up Classes Records',NULL,'TLP', SYSDATETIME(), SYSDATETIME(),1),
('Research Centre Coordinator',NULL,'R & D',SYSDATETIME(),SYSDATETIME(),1),
('Skill Development Cell',NULL,'Exam and T&P Cell',SYSDATETIME(),SYSDATETIME(),1),
('SKIT Times, SKIT Brochure Magazine Coordinator Website,Department Social media',NULL,'External',SYSDATETIME(),SYSDATETIME(),1),
('Sponosored Research, Grant Received and Consultancy',NULL,'R & D',SYSDATETIME(),SYSDATETIME(),1),
('Student Project Coordinator(Internal & External)',NULL,'R & D',SYSDATETIME(),SYSDATETIME(),1),
('Time Table CSE',NULL,'TLP',SYSDATETIME(),SYSDATETIME(),1),
('Virtual Lab Records',NULL,'Internal',SYSDATETIME(),SYSDATETIME(),1)
;

-- Create Documents Table
CREATE TABLE DOCUMENTS (
    id INT PRIMARY KEY IDENTITY(1,1),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    folder_id INT,
    dynamic_data NVARCHAR(MAX),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_deleted BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (folder_id) REFERENCES FOLDERS(id)
);

CREATE INDEX idx_folder_latest ON DOCUMENTS (folder_id);

INSERT INTO DOCUMENTS (
    title,
    description,
    folder_id,
    dynamic_data
)
VALUES (
          'Academic Calender',
  'In this folder, we will manage Academic Calender of the CSE department.',
  1,
  '{
    "AcademicCalendar": {
      "columns": [
        { "name": "Semester", "type": "INT", "constraints": "NOT NULL, CHECK (Semester BETWEEN 1 AND 8), PRIMARY KEY" },
        { "name": "Commencement of Classes", "type": "DATE" },
        { "name": "Assignment1 Release Dates", "type": "DATE" },
        { "name": "Assignment1 Submission Dates", "type": "DATE" },
        { "name": "Commencement of First Mid Term I Theory Exams", "type": "DATE" },
        { "name": "Last Date of Showing Answer Sheets of MT1 to Students", "type": "DATE" },
        { "name": "Submission of Marks of MT1 to Exam Cell", "type": "DATE" },
        { "name": "Remedial Classes for Weak Students", "type": "VARCHAR(255)" },
        { "name": "Commencement of I Internal Practical Exams", "type": "DATE" },
        { "name": "Release of Marks of I Internal Practical Exams", "type": "DATE" },
        { "name": "Assignment2 Release Dates", "type": "DATE" },
        { "name": "Assignment2 Submission Dates", "type": "DATE" },
        { "name": "Commencement of Mid Term II Theory Exams", "type": "DATE" },
        { "name": "Last Date of Showing Answer Sheets of MT2 to Students", "type": "DATE" },
        { "name": "Submission of Marks of MT2 to Exam Cell", "type": "DATE" },
        { "name": "Commencement of II Internal Practical Exams", "type": "DATE" },
        { "name": "Release of Marks of II Internal Practical Exams", "type": "DATE" },
        { "name": "Last Working Day", "type": "DATE" },
        { "name": "Commencement of University Practical Exam", "type": "DATE" },
        { "name": "Commencement of End Term Theory Exam", "type": "DATE" },
        { "name": "Project Report Hardware Submission", "type": "DATE" },
        { "name": "DPAQIC Meeting for Selection of Optional Subjects for Next Semester", "type": "DATE" },
        { "name": "Subjects Allotment to Faculty Members for Next Semester", "type": "DATE" },
        { "name": "Commencement of Classes for Even Semester", "type": "DATE" }
      ]
    }
  }'
  ),
    (
   'Alumni Activity Records',
   'Alumni Records – it contain complete list of Alumni who have been registered on portal.',
   2,
   '{
      "Alumni_Activities_Record": {
         "columns": [
            { "name": "S No", "type": "INT", "constraints": "PRIMARY KEY" },
            { "name": "Date", "type": "DATE" },
            { "name": "Event Name", "type": "VARCHAR(255)" },
            { "name": "Owner of Event", "type": "VARCHAR(100)" },
            { "name": "Alumni Name", "type": "VARCHAR(100)" },
            { "name": "Branch", "type": "VARCHAR(50)" },
            { "name": "Pass Out Year", "type": "INT" },
            { "name": "Email ID", "type": "VARCHAR(100)" },
            { "name": "Mobile Number", "type": "VARCHAR(15)" },
            { "name": "Participant List", "type": "TEXT" },
            { "name": "Poster", "type": "TEXT" },
            { "name": "Notice", "type": "TEXT" },
            { "name": "Summary of Event", "type": "TEXT" },
            { "name": "Photos of Event", "type": "TEXT" },
            { "name": "Feedback", "type": "TEXT" }
         ]
      }
   }'
),   (
  'Alumni Records',
  'Alumni Records – it contain complete list of Alumni who have been registered on portal',
  2,
  '{
    "Alumni_Master_File": {
      "columns": [
        { "name": "Name", "type": "VARCHAR(100)", "constraints": "PRIMARY KEY" },
        { "name": "Department", "type": "VARCHAR(100)" },
        { "name": "Roll Number", "type": "VARCHAR(50)" },
        { "name": "Registration Number", "type": "VARCHAR(50)" },
        { "name": "Course", "type": "VARCHAR(100)" },
        { "name": "Batch Year", "type": "INT" },
        { "name": "Email", "type": "VARCHAR(100)" },
        { "name": "Phone", "type": "VARCHAR(15)" },
        { "name": "Current Address", "type": "TEXT" },
        { "name": "Permanent Address", "type": "TEXT" },
        { "name": "City", "type": "VARCHAR(50)" },
        { "name": "State", "type": "VARCHAR(50)" },
        { "name": "Pincode", "type": "VARCHAR(10)" },
        { "name": "Country", "type": "VARCHAR(50)" },
        { "name": "Membership Status", "type": "VARCHAR(50)" },
        { "name": "Membership Number", "type": "VARCHAR(50)" },
        { "name": "Course Completed", "type": "VARCHAR(100)" },
        { "name": "Institution", "type": "VARCHAR(100)" },
        { "name": "Current Workplace", "type": "VARCHAR(100)" },
        { "name": "LinkedIn Profile", "type": "VARCHAR(255)" },
        { "name": "Facebook Profile", "type": "VARCHAR(255)" },
        { "name": "Instagram Profile", "type": "VARCHAR(255)" },
        { "name": "Years of Experience", "type": "INT" },
        { "name": "Technical Skills", "type": "TEXT" },
        { "name": "Worked in Abroad", "type": "VARCHAR(10)" },
        { "name": "Date of Birth", "type": "DATE" },
        { "name": "Gender", "type": "VARCHAR(10)" },
        { "name": "Alumni Type", "type": "VARCHAR(50)" }
      ]
    }
  }'
),  (
  'SODECA Marks distribution',
  'In this File we will manage SODECA Marks for CSE students',
  6,
  '{
    "SODECA_Marks_Distribution": {
      "columns": [
        { "name": "S No", "type": "INT", "constraints": "PRIMARY KEY" },
        { "name": "Sem", "type": "INT" },
        { "name": "Batch", "type": "VARCHAR(50)" },
        { "name": "Batch Counselor", "type": "VARCHAR(100)" },
        { "name": "University Roll No", "type": "VARCHAR(50)" },
        { "name": "Name of Student", "type": "VARCHAR(100)" },
        { "name": "Discipline Marks", "type": "INT" },
        { "name": "Games Sports Field Activity", "type": "INT" },
        { "name": "Cultural Literary Activities", "type": "INT" },
        { "name": "Academic Technical Professional Development Activities", "type": "INT" },
        { "name": "Social Outreach Personal Development Activities", "type": "INT" },
        { "name": "Anandan Program Activities", "type": "INT" },
        { "name": "Total Marks", "type": "INT" }
      ]
    }
  }'
),     (
  'Sports Achievements NAAC Format',
  'Number of awards/medals for outstanding performance in sports at university/state/national / international level (award for a team event should be counted as one) during the year.',
  3,
  '{
    "NAAC_Sports_Format": {
      "columns": [
        { "name": "Year", "type": "INT" },
        { "name": "Award Name", "type": "VARCHAR(255)" },
        { "name": "Team Or Individual", "type": "VARCHAR(50)" },
        { "name": "Level", "type": "VARCHAR(50)" },
        { "name": "Sports Or Cultural", "type": "VARCHAR(50)" },
        { "name": "Student Name", "type": "VARCHAR(100)" },
        { "name": "Proof Link", "type": "TEXT" }
      ],
      "constraints": {
        "primary_key": ["Year", "Award Name", "Student Name"]
      }
    }
  }'
),

      (
  'Sports Achievements QIV Format',
  'Number of awards/medals for outstanding performance in sports at university/state/national / international level (award for a team event should be counted as one) during the year.',
  3,
  '{
    "QIV_Sports_Format": {
      "columns": [
        { "name": "Event Title", "type": "VARCHAR(255)" },
        { "name": "Activity Name", "type": "VARCHAR(255)" },
        { "name": "Type", "type": "VARCHAR(50)" },
        { "name": "Awarding Organization", "type": "VARCHAR(255)" },
        { "name": "Level", "type": "VARCHAR(50)" },
        { "name": "Activity Date From", "type": "DATE" },
        { "name": "Activity Date To", "type": "DATE" },
        { "name": "Team Members Count", "type": "INT" },
        { "name": "Position", "type": "VARCHAR(50)" },
        { "name": "Proof Enclosed", "type": "VARCHAR(10)" }
      ],
      "constraints": {
        "primary_key": ["Event Title", "Activity Name", "Activity Date From"]
      }
    }
  }'
), (
  'Sports Achievements NBA Format',
  'Number of awards/medals for outstanding performance in sports at university/state/national / international level (award for a team event should be counted as one) during the year.',
  3,
  '{
    "NBA_Sports_Format": {
      "columns": [
        { "name": "Year", "type": "INT" },
        { "name": "Award Name", "type": "VARCHAR(255)" },
        { "name": "Team Or Individual", "type": "VARCHAR(50)" },
        { "name": "Level", "type": "VARCHAR(50)" },
        { "name": "Sports Or Cultural", "type": "VARCHAR(50)" },
        { "name": "Student Name", "type": "VARCHAR(100)" }
      ],
      "constraints": {
        "primary_key": ["Year", "Award Name", "Student Name"]
      }
    }
  }'
),

        (
  'CO-PO-PSO Mapping and Attainment Practical_Midterm_Performance',
  'In this folder, we will manage Session wise / Batch-wise Course Mappings and Attainments of CO-PO and PSO',
  4,
  '{
    "Practical_Midterm_Performance": {
      "columns": [
        { "name": "S No", "type": "INT", "constraints": ["PRIMARY KEY"] },
        { "name": "RTU Roll Number", "type": "VARCHAR(50)", "constraints": ["NOT NULL"] },
        { "name": "Student Name", "type": "VARCHAR(100)" },
        { "name": "Q1", "type": "INT" },
        { "name": "Q2", "type": "INT" },
        { "name": "Total", "type": "INT" },
        { "name": "Viva", "type": "INT" },
        { "name": "Lab Performance", "type": "INT" },
        { "name": "File Work", "type": "INT" },
        { "name": "Attendance", "type": "INT" },
        { "name": "Mapped CO Q1", "type": "VARCHAR(10)" },
        { "name": "Mapped CO Q2", "type": "VARCHAR(10)" }
      ]
    }
  }'
  ),
   (
  'CO-PO-PSO Mapping and Attainment Practical_CO_Attainment_Sectionwise',
  'In this folder, we will manage Session wise / Batch-wise Course Mappings and Attainments of CO-PO and PSO',
  4,
  '{
    "Practical_CO_Attainment_Sectionwise": {
      "columns": [
        { "name": "S No", "type": "INT", "constraints": ["PRIMARY KEY"] },
        { "name": "Roll No", "type": "VARCHAR(50)" },
        { "name": "Student Name", "type": "VARCHAR(100)" },
        { "name": "I Midterm Exam", "type": "INT" },
        { "name": "I Viva", "type": "INT" },
        { "name": "I Lab Performance", "type": "INT" },
        { "name": "I File Work", "type": "INT" },
        { "name": "I Attendance", "type": "INT" },
        { "name": "Total A", "type": "INT" },
        { "name": "II Midterm Exam", "type": "INT" },
        { "name": "II Viva", "type": "INT" },
        { "name": "II Lab Performance", "type": "INT" },
        { "name": "II File Work", "type": "INT" },
        { "name": "II Attendance", "type": "INT" },
        { "name": "Total B", "type": "INT" },
        { "name": "Average Internal Marks", "type": "DECIMAL(5,2)" },
        { "name": "External Lab Performance", "type": "INT" },
        { "name": "External Viva", "type": "INT" },
        { "name": "Total External Marks", "type": "INT" },
        { "name": "Total Marks", "type": "INT" }
      ]
    }
  }'),

          (
  'CO-PO-PSO Mapping and Attainment Practical_CO_Attainment_Summary',
  'In this folder, we will manage Session wise / Batch-wise Course Mappings and Attainments of CO-PO and PSO',
  4,
  '{
    "Practical_CO_Attainment_Summary": {
      "columns": [
        { "name": "Course Code", "type": "VARCHAR(20)", "constraints": ["PRIMARY KEY"] },
        { "name": "Course Name", "type": "VARCHAR(100)" },
        { "name": "Attainment I Midterm Evaluation", "type": "DECIMAL(5,2)" },
        { "name": "Attainment II Midterm Evaluation", "type": "DECIMAL(5,2)" },
        { "name": "Attainment External Lab Performance", "type": "DECIMAL(5,2)" },
        { "name": "Attainment External Viva", "type": "DECIMAL(5,2)" },
        { "name": "Average CO Attainment", "type": "DECIMAL(5,2)" },
        { "name": "Consolidated Attainment Level", "type": "DECIMAL(5,2)" }
      ]
    }
  }'),

        (
  'CO-PO-PSO Mapping and Attainment Theory_Midterm_Attainment',
  'In this folder, we will manage Session wise / Batch-wise Course Mappings and Attainments of CO-PO and PSO',
  4,
  '{
    "Theory_Midterm_Attainment": {
      "columns": [
        { "name": "S No", "type": "INT", "constraints": ["PRIMARY KEY"] },
        { "name": "Section", "type": "VARCHAR(20)" },
        { "name": "Roll No", "type": "VARCHAR(50)" },
        { "name": "Part A", "type": "INT" },
        { "name": "Part B", "type": "INT" },
        { "name": "Part C", "type": "INT" },
        { "name": "Total 20", "type": "INT" },
        { "name": "Assignment 10", "type": "INT" },
        { "name": "Total 30", "type": "INT" },
        { "name": "CO1", "type": "VARCHAR(10)" },
        { "name": "CO2", "type": "VARCHAR(10)" },
        { "name": "CO3", "type": "VARCHAR(10)" },
        { "name": "CO4", "type": "VARCHAR(10)" },
        { "name": "CO5", "type": "VARCHAR(10)" },
        { "name": "CO6", "type": "VARCHAR(10)" },
        { "name": "CO7", "type": "VARCHAR(10)" },
        { "name": "CO8", "type": "VARCHAR(10)" }
      ]
    }
  }'),

        (
  'CO-PO-PSO Mapping and Attainment Theory_CO_Attainment_Summary',
  'In this folder, we will manage Session wise / Batch-wise Course Mappings and Attainments of CO-PO and PSO',
  4,
  '{
    "Theory_CO_Attainment_Summary": {
      "columns": [
        { "name": "Course Code", "type": "VARCHAR(20)", "constraints": ["PRIMARY KEY"] },
        { "name": "Course Name", "type": "VARCHAR(100)" },
        { "name": "CO1 Percentage", "type": "DECIMAL(5,2)" },
        { "name": "CO1 Level", "type": "VARCHAR(10)" },
        { "name": "CO2 Percentage", "type": "DECIMAL(5,2)" },
        { "name": "CO2 Level", "type": "VARCHAR(10)" },
        { "name": "CO3 Percentage", "type": "DECIMAL(5,2)" },
        { "name": "CO3 Level", "type": "VARCHAR(10)" },
        { "name": "CO4 Percentage", "type": "DECIMAL(5,2)" },
        { "name": "CO4 Level", "type": "VARCHAR(10)" },
        { "name": "CO5 Percentage", "type": "DECIMAL(5,2)" },
        { "name": "CO5 Level", "type": "VARCHAR(10)" }
      ]
    }
  }'
),

        (
  'CO-PO-PSO Mapping and Attainment Theory_CO_Attainment_Batchwise',
  'In this folder, we will manage Session wise / Batch-wise Course Mappings and Attainments of CO-PO and PSO',
  4,
  '{
    "Theory_CO_Attainment_Batchwise": {
      "columns": [
        { "name": "S No", "type": "INT", "constraints": ["PRIMARY KEY"] },
        { "name": "Semester", "type": "INT" },
        { "name": "Subject Code", "type": "VARCHAR(20)" },
        { "name": "Subject Name", "type": "VARCHAR(100)" },
        { "name": "CO1", "type": "DECIMAL(5,2)" },
        { "name": "CO2", "type": "DECIMAL(5,2)" },
        { "name": "CO3", "type": "DECIMAL(5,2)" },
        { "name": "CO4", "type": "DECIMAL(5,2)" },
        { "name": "CO5", "type": "DECIMAL(5,2)" },
        { "name": "CO6", "type": "DECIMAL(5,2)" },
        { "name": "Internal Exam Attainment", "type": "DECIMAL(5,2)" },
        { "name": "Assignment Unit Test Attainment", "type": "DECIMAL(5,2)" },
        { "name": "Internal Assessment Attainment", "type": "DECIMAL(5,2)" },
        { "name": "External Exam Attainment", "type": "DECIMAL(5,2)" },
        { "name": "Overall Attainment Level", "type": "DECIMAL(5,2)" }
      ]
    }
  }'
),

        (
  'CO-PO-PSO Mapping and Attainment Practical_CO_Attainment_Batchwise',
  'In this folder, we will manage Session wise / Batch-wise Course Mappings and Attainments of CO-PO and PSO',
  4,
  '{
    "Practical_CO_Attainment_Batchwise": {
      "columns": [
        { "name": "Sr No", "type": "INT", "constraints": ["PRIMARY KEY"] },
        { "name": "Semester", "type": "INT" },
        { "name": "Subject Code", "type": "VARCHAR(20)" },
        { "name": "Subject Name", "type": "VARCHAR(100)" },
        { "name": "CO1", "type": "DECIMAL(5,2)" },
        { "name": "CO2", "type": "DECIMAL(5,2)" },
        { "name": "CO3", "type": "DECIMAL(5,2)" },
        { "name": "CO4", "type": "DECIMAL(5,2)" },
        { "name": "CO5", "type": "DECIMAL(5,2)" },
        { "name": "CO6", "type": "DECIMAL(5,2)" },
        { "name": "I Midterm Attainment", "type": "DECIMAL(5,2)" },
        { "name": "II Midterm Attainment", "type": "DECIMAL(5,2)" },
        { "name": "Internal Attainment", "type": "DECIMAL(5,2)" },
        { "name": "External Attainment", "type": "DECIMAL(5,2)" },
        { "name": "Consolidated Attainment Level", "type": "DECIMAL(5,2)" }
      ]
    }
  }'),

         (
  'CO-PO-PSO Mapping and Attainment PO_PSO_Attainment_Summary',
  'In this folder, we will manage Session wise / Batch-wise Course Mappings and Attainments of CO-PO and PSO',
  4,
  '{
    "PO_PSO_Attainment_Summary": {
      "columns": [
        { "name": "S No", "type": "INT", "constraints": ["PRIMARY KEY"] },
        { "name": "Course Code", "type": "VARCHAR(20)" },
        { "name": "Course Name", "type": "VARCHAR(100)" },
        { "name": "Consolidated CO", "type": "VARCHAR(20)" },
        { "name": "PO1", "type": "DECIMAL(5,2)" },
        { "name": "PO2", "type": "DECIMAL(5,2)" },
        { "name": "PO3", "type": "DECIMAL(5,2)" },
        { "name": "PO4", "type": "DECIMAL(5,2)" },
        { "name": "PO5", "type": "DECIMAL(5,2)" },
        { "name": "PO6", "type": "DECIMAL(5,2)" },
        { "name": "PO7", "type": "DECIMAL(5,2)" },
        { "name": "PO8", "type": "DECIMAL(5,2)" },
        { "name": "PO9", "type": "DECIMAL(5,2)" },
        { "name": "PO10", "type": "DECIMAL(5,2)" },
        { "name": "PO11", "type": "DECIMAL(5,2)" },
        { "name": "PO12", "type": "DECIMAL(5,2)" },
        { "name": "PSO1", "type": "DECIMAL(5,2)" },
        { "name": "PSO2", "type": "DECIMAL(5,2)" },
        { "name": "PSO3", "type": "DECIMAL(5,2)" }
      ]
    }
  }'
),

     (
  'Course File',
  'The course file will be reviewed on the basis of the availability of following documents (as listed in Table1) in the said sequence only.',
  5,
  '{
    "Course_File": {
      "columns": [
        { "name": "Institute Vision Mission Quality Policy", "type": "TEXT" },
        { "name": "Department Vision Mission", "type": "TEXT" },
        { "name": "RTU Scheme Syllabus", "type": "TEXT" },
        { "name": "Prerequisite of Course", "type": "TEXT" },
        { "name": "List of Text and Reference Books", "type": "TEXT" },
        { "name": "Time Table", "type": "TEXT" },
        { "name": "Syllabus Deployment Course Plan", "type": "TEXT" },
        { "name": "Coverage", "type": "TEXT" },
        { "name": "PO PSO Indicators Competency", "type": "TEXT" },
        { "name": "COs Competency Level 1", "type": "TEXT" },
        { "name": "CO PO PSO Mapping Using Performance Indicators PIs", "type": "TEXT" },
        { "name": "CO PO PSO Mapping Formula Justification", "type": "TEXT" },
        { "name": "Attainment Level Internal Assessment", "type": "TEXT" },
        { "name": "Learning Level Students Through Marks 1st Test Quiz", "type": "TEXT" },
        { "name": "Planning Remedial Classes Below Average Students", "type": "TEXT" },
        { "name": "Teaching Learning Methodology", "type": "TEXT" },
        { "name": "RTU Papers Previous Years", "type": "TEXT" },
        { "name": "Mid Term Papers Blooms Taxonomy COs", "type": "TEXT" },
        { "name": "Tutorial Sheets WITH EMD Analysis", "type": "TEXT" },
        { "name": "Technical Quiz Papers", "type": "TEXT" },
        { "name": "Assignments RTU Format", "type": "TEXT" },
        { "name": "Efforts to Fill Gap Between COs and POs", "type": "TEXT" },
        { "name": "Lecture Notes", "type": "TEXT" }
      ]
    }
  }'
),
(
  'Handbook',
  'The faculty handbooks will be reviewed on the basis of the availability of following documents.',
  5,
  '{
    "Handbook": {
      "columns": [
        { "name": "Institute Vision Mission Quality Policy", "type": "TEXT" },
        { "name": "Department Vision Mission", "type": "TEXT" },
        { "name": "PEO PO PSO", "type": "TEXT" },
        { "name": "Time Table", "type": "TEXT" },
        { "name": "RTU Syllabus", "type": "TEXT" },
        { "name": "Syllabus Deployment Course Plan", "type": "TEXT" },
        { "name": "Course Coverage", "type": "TEXT" },
        { "name": "Student Details", "type": "TEXT" },
        { "name": "Attendance Mark Properly", "type": "TEXT" },
        { "name": "Listing Total Students Present Absent Total", "type": "TEXT" },
        { "name": "List of Text and Reference Books", "type": "TEXT" }
      ]
    }
  }'
),

       (
  'SODECA NAAC Format - 1',
  'Number of awards/medals for outstanding performance in sports/cultural activities at university/state/national / international level (award for a team event should be counted as one) during the year.',
  7,
  '{
    "Naac_format_DECA_1": {
      "columns": [
        { "name": "Year", "type": "YEAR" },
        { "name": "Name of the award or medal", "type": "VARCHAR(30)" },
        { "name": "Team or Individual", "type": "ENUM", "values": ["Team", "Individual"] },
        { "name": "Level", "type": "ENUM", "values": ["University", "State", "National", "International"] },
        { "name": "Sports or Cultural", "type": "ENUM", "values": ["sports", "cultural"] },
        { "name": "Student name", "type": "VARCHAR(50)" },
        { "name": "Proof link", "type": "VARCHAR(80)" }
      ]
    }
  }'
),
(
  'SODECA NAAC Format - 2',
  'Average number of sports, technical and cultural activities/events in which students of the Institution participated during this year (organised by the institution/other institutions) (20)',
  7,
  '{
    "NAAC_format_DECA_2": {
      "columns": [
        { "name": "Date of event", "type": "DATE" },
        { "name": "Name of event", "type": "VARCHAR(30)" },
        { "name": "Roll no", "type": "VARCHAR(20)" },
        { "name": "Name of student participated", "type": "VARCHAR(30)" },
        { "name": "Link of proof", "type": "VARCHAR(50)" }
      ]
    }
  }'
),

      (
  'SODECA QIV Format - 1',
  'Number of awards/medals for outstanding performance in sports/cultural activities at university/state/national / international level (award for a team event should be counted as one) during the year.',
  7,
  '{
    "QIV_format_DECA_1": {
      "columns": [
        { "name": "Title of event", "type": "VARCHAR(50)" },
        { "name": "Name of activity", "type": "VARCHAR(50)" },
        { "name": "Type", "type": "ENUM", "values": ["Faculty", "Student"] },
        { "name": "Awarding Organization", "type": "VARCHAR(50)" },
        { "name": "Level", "type": "ENUM", "values": ["International", "National"] },
        { "name": "Date to", "type": "DATE" },
        { "name": "Date from", "type": "DATE" },
        { "name": "No of members in team", "type": "INT" },
        { "name": "Position", "type": "INT" },
        { "name": "Proof enclosed", "type": "ENUM", "values": ["Yes", "No"] }
      ]
    }
  }'
),

       (
  'SODECA QIV Format - 2',
  'Average number of sports, technical and cultural activities/events in which students of the Institution participated during this year (organised by the institution/other institutions) (20)',
  7,
  N'{
    "QIV_format_DECA_2": {
      "columns": [
        { "name": "Title of event", "type": "VARCHAR(50)" },
        { "name": "Choose", "type": "ENUM", "values": ["Faculty", "Student", "Coordinator"] },
        { "name": "Name of faculty or Student Coordinator", "type": "VARCHAR(30)" },
        { "name": "Awarding Organization", "type": "VARCHAR(50)" },
        { "name": "Level", "type": "ENUM", "values": ["International", "National"] },
        { "name": "Type", "type": "ENUM", "values": ["Curricular", "Co-curricular"] },
        { "name": "Date to", "type": "DATE" },
        { "name": "Date from", "type": "DATE" },
        { "name": "Position", "type": "INT" },
        { "name": "Department", "type": "VARCHAR(30)" },
        { "name": "Proof enclosed", "type": "ENUM", "values": ["Yes", "No"] }
      ]
    }
  }'
),
(
  'SODECA NBA Format',
  'Number of awards/medals for outstanding performance in sports/cultural activities at university/state/national / international level (award for a team event should be counted as one) during the year.',
  7,
  '{
    "NBA_format_DECA": {
      "columns": [
        { "name": "Session", "type": "VARCHAR(20)" },
        { "name": "Name of student or team members", "type": "VARCHAR(80)" },
        { "name": "Name of award", "type": "VARCHAR(30)" },
        { "name": "Event date to", "type": "DATE" },
        { "name": "Event date from", "type": "DATE" },
        { "name": "Event Name", "type": "VARCHAR(60)" },
        { "name": "Event Venue", "type": "VARCHAR(90)" },
        { "name": "Level", "type": "ENUM("International", "National", "State", "College level")" },
        { "name": "Category", "type": "VARCHAR(60)" },
        { "name": "Proof link", "type": "VARCHAR(90)" }
      ]
    }
  }'
),

     (
  'SODECA NIRF Format',
  'NULL',
  7,
  '{
    "NIRF_format_DECA": {
      "columns": [
        { "name": "Dept", "type": "VARCHAR(20)" },
        { "name": "S No", "type": "INT", "constraints": ["AUTO_INCREMENT", "PRIMARY KEY"] },
        { "name": "Enrollment Number", "type": "INT" },
        { "name": "Name of the award", "type": "VARCHAR(40)" },
        { "name": "Name of International institution", "type": "VARCHAR(50)" },
        { "name": "Address of the Agency giving award", "type": "VARCHAR(90)" },
        { "name": "Contact Email ID of the institution", "type": "VARCHAR(60)" },
        { "name": "Year of receiving award", "type": "YEAR" },
        { "name": "Email ID of the Student", "type": "VARCHAR(50)" },
        { "name": "Contact no of the Student", "type": "CHAR(10)" }
      ]
    }
  }'
),

       (
  'Events Organized',
  'In this folder, we will manage data which is relevant to events like workshop, FDP, Conference, Seminar, etc Organized for Faculty and Students.',
  10,
  '{
    "Naac_Format_event_organized": {
      "columns": [
        { "name": "sn", "type": "INT", "constraints": ["AUTO_INCREMENT", "PRIMARY KEY"] },
        { "name": "from date", "type": "DATE" },
        { "name": "to date", "type": "DATE" },
        { "name": "Title of the professional development program organised for teaching staff", "type": "VARCHAR(255)" },
        { "name": "Title of the administrative training program organised for non teaching staff", "type": "VARCHAR(255)" },
        { "name": "Total no. of participants Teaching or Non teaching", "type": "INT" },
        { "name": "Link to the report of the Program", "type": "TEXT" },
        { "name": "Link to the list of participant with Employee code", "type": "TEXT" }
      ]
    }
  }'
),

       (
  'Events Organized',
  'In this folder, we will manage data which is relevant to events like workshop, FDP, Conference, Seminar, etc Organized for Faculty and Students.',
  10,
  '{
    "NBA_format_DECA": {
      "columns": [
        { "name": "Session", "type": "VARCHAR(20)" },
        { "name": "Name of student or team members", "type": "VARCHAR(80)" },
        { "name": "Name of award", "type": "VARCHAR(30)" },
        { "name": "Event date to", "type": "DATE" },
        { "name": "Event date from", "type": "DATE" },
        { "name": "Event Name", "type": "VARCHAR(60)" },
        { "name": "Event Venue", "type": "VARCHAR(90)" },
        { "name": "level", "type": "ENUM(''International'', ''National'', ''State'', ''College level'')" },
        { "name": "Category", "type": "VARCHAR(60)" },
        { "name": "Proof link", "type": "VARCHAR(90)" }
      ]
    }
  }'
),

     (
  'Result Analysis',
  'In this folder, we will manage the result analysis of CSE, AI, DS and IoT',
  11,
  '{
    "nirf_result_analysis": {
      "columns": [
        { "name": "academic year", "type": "VARCHAR(9)" },
        { "name": "No. of first year students intake in the year", "type": "INT" },
        { "name": "No. of first year students admitted in the year", "type": "INT" },
        { "name": "Academic Year", "type": "INT" },
        { "name": "No. of students admitted through lateral entry", "type": "INT" },
        { "name": "No. of student graduating in minimum stipulated time", "type": "INT" },
        { "name": "No. of students places", "type": "INT" },
        { "name": "Median salary of placed graduates per annum Amount in Rs", "type": "DECIMAL(10, 2)" },
        { "name": "Median salary of placed graduates per annum Amount in Words", "type": "VARCHAR(255)" },
        { "name": "No. of students selected for Higher Studies", "type": "INT" }
      ]
    }
  }'
),

       (
  'Result Analysis',
  'In this folder, we will manage the result analysis of CSE, AI, DS and IoT',
  11,
  '{
    "qiv_result_analysis": {
      "columns": [
        { "name": "sn", "type": "INT", "attributes": ["AUTO_INCREMENT", "PRIMARY KEY"] },
        { "name": "University Roll no", "type": "VARCHAR(50)" },
        { "name": "Student name", "type": "VARCHAR(255)" },
        { "name": "Branch", "type": "VARCHAR(100)" },
        { "name": "Percentage", "type": "DECIMAL(5,2)" },
        { "name": "Result", "type": "VARCHAR(50)" }
      ]
    }
  }'
),

      (
  'Result Analysis',
  'In this folder, we will manage the result analysis of CSE, AI,DS and IoT',
  11,
  '{
    "qiv_result_analysis": {
      "columns": [
        { "name": "sn", "type": "INT", "attributes": ["AUTO_INCREMENT", "PRIMARY KEY"] },
        { "name": "University Roll no", "type": "VARCHAR(50)" },
        { "name": "Student name", "type": "VARCHAR(255)" },
        { "name": "Branch", "type": "VARCHAR(100)" },
        { "name": "Percentage", "type": "DECIMAL(5,2)" },
        { "name": "Result", "type": "VARCHAR(50)" }
      ]
    }
  }'
),

      (
  'External Examination Coordinator',
  'In this folder, we will manage External Examination Records data',
  12,
  '{
    "external_examination_records_master": {
      "columns": [
        { "name": "sr no", "type": "INT", "attributes": ["PRIMARY KEY"] },
        { "name": "Date of Exam", "type": "DATE" },
        { "name": "Name of Lab", "type": "VARCHAR(100)" },
        { "name": "External Examiner no", "type": "VARCHAR(50)" },
        { "name": "Name of External Examiner", "type": "VARCHAR(100)" },
        { "name": "Name of Internal Examiner", "type": "VARCHAR(100)" },
        { "name": "No of Students to be Examined", "type": "INT" }
      ]
    }
  }'
),

        (
  'External Examination Coordinator',
  'In this folder, we will manage External Examination Records data',
  12,
  '{
    "external_examination_records_master": {
      "columns": [
        { "name": "Sr No.", "type": "INT", "attributes": ["PRIMARY KEY"] },
        { "name": "Date of Exam", "type": "DATE" },
        { "name": "Name of Lab", "type": "VARCHAR(100)" },
        { "name": "External Examiner no", "type": "VARCHAR(50)" },
        { "name": "Name of External Examiner", "type": "VARCHAR(100)" },
        { "name": "Name of Internal Examiner", "type": "VARCHAR(100)" },
        { "name": "No of Students to be Examined", "type": "INT" }
      ]
    }
  }'
),

(
  'Virtual_Lab_Monthly_Usage',
  NULL,
  34,
  '{
    "Virtual_Lab_Monthly_Usage": {
      "columns": [
        { "name": "Usage ID", "type": "INT", "constraints": "PRIMARY KEY IDENTITY(1,1)" },
        { "name": "Month", "type": "VARCHAR(20)" },
        { "name": "Workshop Date", "type": "DATE" },
        { "name": "Branch", "type": "VARCHAR(50)" },
        { "name": "Year Batch", "type": "VARCHAR(20)" },
        { "name": "No of Participants", "type": "INT" },
        { "name": "No of Labs Performed", "type": "INT" },
        { "name": "No of Experiments Performed", "type": "INT" },
        { "name": "Usage Remark", "type": "VARCHAR(200)" }
      ]
    }
  }'
),

    (
  'Master_Time_Table',
  'In this folder, I will manage data for Time table of Classes, faculties, labs and Lecture rooms.',
  33,
  '{
    "Master_Time_Table": {
      "columns": [
        { "name": "SN", "type": "INT", "constraints": "PRIMARY KEY IDENTITY(1,1)" },
        { "name": "Session", "type": "VARCHAR(20)" },
        { "name": "Class", "type": "VARCHAR(50)" },
        { "name": "Faculty", "type": "VARCHAR(100)" },
        { "name": "Subject Name", "type": "VARCHAR(100)" },
        { "name": "Subject Code", "type": "VARCHAR(20)" },
        { "name": "Subject Type", "type": "VARCHAR(50)" },
        { "name": "Batch", "type": "VARCHAR(50)" }
      ]
    }
  }'
),

   (
  'master_file_Research_centre_Records',
  'In this folder, we will manage Research Centre Records data',
  28,
  N'{
    "master_file_Research_centre_Records": {
      "columns": [
        { "name": "S NO", "type": "INT", "constraints": "PRIMARY KEY NOT NULL" },
        { "name": "TEACHER NAME", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "QUALIFICATION AND YEAR", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "RECOGNIZED AS RESEARCH GUIDE", "type": "VARCHAR(10)", "constraints": "NOT NULL" },
        { "name": "YEAR OF RECOGNITION", "type": "INT", "constraints": "NOT NULL" },
        { "name": "IS STILL SERVING", "type": "VARCHAR(10)", "constraints": "NOT NULL" },
        { "name": "LAST YEAR OF SERVICE", "type": "INT" },
        { "name": "SCHOLAR NAME", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "SCHOLAR REGISTRATION YEAR", "type": "INT", "constraints": "NOT NULL" },
        { "name": "RTU ENROLL NO", "type": "VARCHAR(50)", "constraints": "NOT NULL" },
        { "name": "THESIS TITLE", "type": "TEXT", "constraints": "NOT NULL" },
        { "name": "YEAR OF COMPLETION", "type": "INT", "constraints": "NOT NULL" }
      ]
    }
  }'
),
(
  'master_file_Research_centre_Records',
  'In this folder, we will manage Research Centre Records data',
  28,
  '{
    "master_file_Research_centre_Records": {
      "columns": [
        { "name": "S NO", "type": "INT", "constraints": "PRIMARY KEY NOT NULL" },
        { "name": "TEACHER NAME", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "QUALIFICATION AND YEAR", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "RECOGNIZED AS RESEARCH GUIDE", "type": "VARCHAR(10)", "constraints": "NOT NULL" },
        { "name": "YEAR OF RECOGNITION", "type": "INT", "constraints": "NOT NULL" },
        { "name": "IS STILL SERVING", "type": "VARCHAR(10)", "constraints": "NOT NULL" },
        { "name": "LAST YEAR OF SERVICE", "type": "INT" },
        { "name": "SCHOLAR NAME", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "SCHOLAR REGISTRATION YEAR", "type": "INT", "constraints": "NOT NULL" },
        { "name": "RTU ENROLL NO", "type": "VARCHAR(50)", "constraints": "NOT NULL" },
        { "name": "THESIS TITLE", "type": "TEXT", "constraints": "NOT NULL" },
        { "name": "YEAR OF COMPLETION", "type": "INT", "constraints": "NOT NULL" }
      ]
    }
  }'
),

    (
  'Remedial_List_of_Students',
  'In this folder we are going to maintain the information such as attendance, time table, list of student, Notice of remedial class.',
  27,
  '{
    "Remedial_List_of_Students": {
      "columns": [
        { "name": "SL NO", "type": "INT", "constraints": "NOT NULL" },
        { "name": "ROLL NO", "type": "VARCHAR(20)", "constraints": "PRIMARY KEY NOT NULL" },
        { "name": "UNIVERSITY REGISTER NO", "type": "VARCHAR(30)", "constraints": "NOT NULL" },
        { "name": "NAME OF THE STUDENT", "type": "VARCHAR(100)", "constraints": "NOT NULL" },
        { "name": "CLASS", "type": "VARCHAR(50)", "constraints": "NOT NULL" },
        { "name": "SUBJECT", "type": "VARCHAR(100)", "constraints": "NOT NULL" },
        { "name": "ACADEMIC YEAR", "type": "VARCHAR(10)", "constraints": "NOT NULL" }
      ]
    }
  }'
),

   (
  'NAAC_Research_Projects',
  'In this folder, detailed information related to accepted research projects as well as consultancy projects of the faculty members of Computer Science and Engineering Department will be shared.',
  31,
  '{
    "NAAC_Research_Projects": {
      "columns": [
        { "name": "PROJECT ID", "type": "INT", "constraints": "PRIMARY KEY IDENTITY(1,1)" },
        { "name": "PROJECT NAME", "type": "VARCHAR(255)", "constraints": "NOT NULL" },
        { "name": "PRINCIPAL INVESTIGATOR", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "DEPARTMENT", "type": "VARCHAR(100)", "constraints": "NOT NULL" },
        { "name": "YEAR OF AWARD", "type": "INT", "constraints": "NOT NULL" },
        { "name": "AMOUNT SANCTIONED", "type": "DECIMAL(15,2)", "constraints": "NOT NULL" },
        { "name": "PROJECT DURATION", "type": "VARCHAR(50)", "constraints": "NOT NULL" },
        { "name": "FUNDING AGENCY", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "FUNDING TYPE", "type": "VARCHAR(20)", "constraints": "NOT NULL" }
      ]
    }
  }'
),

   (
  'Master_table_of_Expert_Lectures',
  'In this folder, detailed information related to the expert or guest lecturers held under any activity will be shared. The folder will have all the related documents such as approval, brochure, attendance, PPTs of expert, etc.',
  31,
  '{
    "Master_table_of_Expert_Lectures": {
      "columns": [
        { "name": "EVENT ID", "type": "INT", "constraints": "PRIMARY KEY IDENTITY(1,1)" },
        { "name": "EVENT TITLE", "type": "VARCHAR(255)", "constraints": "NOT NULL" },
        { "name": "EVENT LEVEL", "type": "VARCHAR(20)", "constraints": "NOT NULL" },
        { "name": "SESSION TITLE", "type": "VARCHAR(255)" },
        { "name": "LECTURE TITLE", "type": "VARCHAR(255)" },
        { "name": "EXPERT NAME", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "EXPERT AFFILIATION", "type": "VARCHAR(255)", "constraints": "NOT NULL" },
        { "name": "EVENT DATE", "type": "DATE", "constraints": "NOT NULL" },
        { "name": "VENUE", "type": "VARCHAR(200)", "constraints": "NOT NULL" },
        { "name": "DURATION DAYS", "type": "INT", "constraints": "NOT NULL" },
        { "name": "FUNDING AGENCY", "type": "VARCHAR(150)" },
        { "name": "FUNDING TYPE", "type": "VARCHAR(20)" },
        { "name": "AMOUNT INR", "type": "DECIMAL(15,2)" }
      ]
    }
  }'
),

   (
  'Master_Table_Research_Projects',
  'In this folder, detailed information related to accepted research projects as well as consultancy projects of the faculty members of Computer Science and Engineering Department will be shared.',
  31,
  '{
    "Master_Table_Research_Projects": {
      "columns": [
        { "name": "Project ID", "type": "INT", "constraints": "PRIMARY KEY IDENTITY(1,1)" },
        { "name": "Faculty Name", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "Project Title", "type": "VARCHAR(255)", "constraints": "NOT NULL" },
        { "name": "Role", "type": "VARCHAR(10)", "constraints": "NOT NULL" },
        { "name": "External PI Details", "type": "VARCHAR(255)" },
        { "name": "Collaborating Institutions", "type": "TEXT" },
        { "name": "Funding Agency", "type": "VARCHAR(255)", "constraints": "NOT NULL" },
        { "name": "Funding Agency Type", "type": "VARCHAR(20)", "constraints": "NOT NULL" },
        { "name": "Project Category", "type": "VARCHAR(50)", "constraints": "NOT NULL" },
        { "name": "Project Duration Months", "type": "INT", "constraints": "NOT NULL" },
        { "name": "Start Date", "type": "DATE", "constraints": "NOT NULL" },
        { "name": "End Date", "type": "DATE", "constraints": "NOT NULL" },
        { "name": "Amount INR", "type": "DECIMAL(15,2)", "constraints": "NOT NULL" },
        { "name": "Status", "type": "VARCHAR(20)", "constraints": "NOT NULL" }
      ]
    }
  }'
),

   (
  'NAAC_Expert_Lectures',
  'In this folder, detailed information related to the expert or guest lecturers held under any activity will be shared. The folder will have all the related documents such as approval, brochure, attendance, PPTs of expert, etc.',
  31,
  '{
    "NAAC_Expert_Lectures": {
      "columns": [
        { "name": "PROJECT ID", "type": "INT", "constraints": "PRIMARY KEY IDENTITY(1,1)" },
        { "name": "PROJECT NAME", "type": "VARCHAR(255)", "constraints": "NOT NULL" },
        { "name": "PRINCIPAL INVESTIGATOR", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "DEPARTMENT", "type": "VARCHAR(100)", "constraints": "NOT NULL" },
        { "name": "YEAR OF AWARD", "type": "INT", "constraints": "NOT NULL" },
        { "name": "AMOUNT SANCTIONED", "type": "DECIMAL(15,2)", "constraints": "NOT NULL" },
        { "name": "PROJECT DURATION", "type": "VARCHAR(50)", "constraints": "NOT NULL" },
        { "name": "FUNDING AGENCY", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "FUNDING TYPE", "type": "VARCHAR(20)", "constraints": "NOT NULL" }
      ]
    }
  }'
),
(
  'NAAC_External_Project_Proposal',
  'In this folder, detailed information related to accepted research projects as well as consultancy projects of the students of Computer Science and Engineering Department will be shared.',
  32,
  '{
    "NAAC_External_Project_Proposal": {
      "columns": [
        { "name": "PROJECT ID", "type": "INT", "constraints": "PRIMARY KEY IDENTITY(1,1)" },
        { "name": "PROJECT NAME", "type": "VARCHAR(255)", "constraints": "NOT NULL" },
        { "name": "PRINCIPAL INVESTIGATOR", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "DEPARTMENT", "type": "VARCHAR(100)", "constraints": "NOT NULL" },
        { "name": "YEAR OF AWARD", "type": "INT", "constraints": "NOT NULL" },
        { "name": "AMOUNT SANCTIONED", "type": "DECIMAL(15,2)", "constraints": "NOT NULL" },
        { "name": "PROJECT DURATION", "type": "VARCHAR(50)", "constraints": "NOT NULL" },
        { "name": "FUNDING AGENCY", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "FUNDING TYPE", "type": "VARCHAR(20)", "constraints": "NOT NULL" }
      ]
    }
  }'
),

    (
  'Master_table_of_External_project_proposal',
  'In this folder, detailed information related to accepted research projects as well as consultancy projects of the students of Computer Science and Engineering Department will be shared.',
  32,
  '{
    "Master_table_of_External_project_proposal": {
      "columns": [
        { "name": "DETAIL ID", "type": "INT", "constraints": "PRIMARY KEY IDENTITY(1,1)" },
        { "name": "PROJECT ID", "type": "INT", "constraints": "NOT NULL, FOREIGN KEY REFERENCES NAAC_External_Project_Proposal(PROJECT_ID)" },
        { "name": "PROJECT NAME", "type": "VARCHAR(255)", "constraints": "NOT NULL" },
        { "name": "NAME OF SUMIT", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "ROLE", "type": "VARCHAR(10)", "constraints": "NOT NULL" },
        { "name": "EXTERNAL PI NAME AFFILIATION", "type": "VARCHAR(255)" },
        { "name": "COLLABORATING INSTITUTIONS", "type": "TEXT" },
        { "name": "FUNDING AGENCY", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "FUNDING TYPE", "type": "VARCHAR(20)", "constraints": "NOT NULL" },
        { "name": "CATEGORY", "type": "VARCHAR(50)", "constraints": "NOT NULL" },
        { "name": "DURATION MONTHS", "type": "INT", "constraints": "NOT NULL" },
        { "name": "START DATE", "type": "DATE", "constraints": "NOT NULL" },
        { "name": "END DATE", "type": "DATE", "constraints": "NOT NULL" },
        { "name": "AMOUNT INR", "type": "DECIMAL(15,2)", "constraints": "NOT NULL" },
        { "name": "STATUS", "type": "VARCHAR(20)", "constraints": "NOT NULL" }
      ]
    }
  }'
),

   (
  'NAAC_Student_Internship',
  'In this folder, we will manage final year student project list, Mentor approval letters, various sample like Abstract, form-1, form-2, form-3, SRS, PPT, Project Report, Demo Video etc.',
  32,
  '{
    "NAAC_Student_Internship": {
      "columns": [
        { "name": "INTERNSHIP ID", "type": "INT", "constraints": "PRIMARY KEY IDENTITY(1,1)" },
        { "name": "PROGRAM NAME", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "PROGRAM CODE", "type": "VARCHAR(50)" },
        { "name": "ROLL NUMBER", "type": "VARCHAR(50)", "constraints": "NOT NULL UNIQUE" },
        { "name": "STUDENT NAME", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
        { "name": "FIRM NAME ADDRESS", "type": "TEXT", "constraints": "NOT NULL" },
        { "name": "START DATE", "type": "DATE", "constraints": "NOT NULL" },
        { "name": "END DATE", "type": "DATE", "constraints": "NOT NULL" },
        { "name": "GOOGLE DRIVE LINK", "type": "TEXT" }
      ]
    }
  }'
),

    (
  'Master_Table_of_Student_Internship',
  'In this folder, we will manage final year student project list, Mentor approval letters, various sample like Abstract, form-1, form-2, form-3, SRS, PPT, Project Report, Demo Video etc.',
  32,
  '{
      "Master Table of Student Internship": {
          "columns": [
              { "name": "SNO", "type": "INT", "constraints": "PRIMARY KEY IDENTITY(1,1)" },
              { "name": "ROLL NUMBER", "type": "VARCHAR(50)", "constraints": "NOT NULL, FOREIGN KEY REFERENCES NAAC_Student_Internship(ROLL_NUMBER)" },
              { "name": "STUDENT NAME", "type": "VARCHAR(100)" },
              { "name": "PROJECT TITLE", "type": "VARCHAR(200)" },
              { "name": "PROJECT MENTOR", "type": "VARCHAR(100)" }
          ]
      }
  }'
),

   (
  'UG_Higher_Studies',
  'NULL',
  22,
  '{
      "UG Higher Studies": {
          "columns": [
              { "name": "ID", "type": "INT", "constraints": "AUTO_INCREMENT PRIMARY KEY" },
              { "name": "Dept", "type": "VARCHAR(200)", "constraints": "NOT NULL" },
              { "name": "Session", "type": "VARCHAR(200)", "constraints": "NOT NULL" },
              { "name": "No of Students", "type": "INT", "constraints": "NOT NULL" }
          ]
      }
  }'
),

  (
  'PG_Higher_Studies',
  'NULL',
  22,
  '{
      "PG Higher Studies": {
          "columns": [
              { "name": "ID", "type": "INT", "constraints": "AUTO_INCREMENT PRIMARY KEY" },
              { "name": "Dept", "type": "VARCHAR(200)", "constraints": "NOT NULL" },
              { "name": "Session", "type": "VARCHAR(200)", "constraints": "NOT NULL" },
              { "name": "No of Students", "type": "INT", "constraints": "NOT NULL" }
          ]
      }
  }'
),

   (
  'Patents',
  'NULL',
  22,
  '{
      "Patents": {
          "columns": [
              { "name": "ID", "type": "INT", "constraints": "AUTO_INCREMENT PRIMARY KEY" },
              { "name": "Deptartment", "type": "VARCHAR(100)", "constraints": "NOT NULL" },
              { "name": "Calendar Year", "type": "YEAR", "constraints": "NOT NULL" },
              { "name": "Number of Published", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Number of Granted", "type": "INT", "constraints": "NOT NULL" }
          ]
      }
  }'
),

   (
  'Sponsored Research Detail',
  'NULL',
  22,
  '{
      "Sponsored Research Detail": {
          "columns": [
              { "name": "ID", "type": "INT", "constraints": "AUTO_INCREMENT PRIMARY KEY" },
              { "name": "Dept", "type": "VARCHAR(100)", "constraints": "NOT NULL" },
              { "name": "Financial Year", "type": "VARCHAR(9)", "constraints": "NOT NULL" },
              { "name": "Number of Projects", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Number of Funding Agencies", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Amount Received Rs", "type": "DECIMAL(15,2)", "constraints": "NOT NULL" },
              { "name": "Amount in Words", "type": "VARCHAR(255)", "constraints": "NOT NULL" }
          ]
      }
  }'
),

   (
  'Consultancy Projects Details',
  'NULL',
  22,
  '{
      "Consultancy Projects Details": {
          "columns": [
              { "name": "ID", "type": "INT", "constraints": "AUTO_INCREMENT PRIMARY KEY" },
              { "name": "Dept", "type": "VARCHAR(100)", "constraints": "NOT NULL" },
              { "name": "Financial Year", "type": "VARCHAR(9)", "constraints": "NOT NULL" },
              { "name": "Number of Projects", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Number of Client Originations", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Amount Received Rs", "type": "DECIMAL(15,2)", "constraints": "NOT NULL" },
              { "name": "Amount in Words", "type": "VARCHAR(255)", "constraints": "NOT NULL" }
          ]
      }
  }'
),

   (
  'ERP Total Student Strength',
  'NULL',
  22,
  '{
      "ERP Total Student Strength": {
          "columns": [
              { "name": "ID", "type": "INT", "constraints": "AUTO_INCREMENT PRIMARY KEY" },
              { "name": "Program", "type": "VARCHAR(255)", "constraints": "NOT NULL" },
              { "name": "Male Students", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Female Students", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Total Students", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Within State", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Outside State", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Outside Country", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Economically Backward", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Socially Challenged", "type": "INT", "constraints": "NOT NULL" }
          ]
      }
  }'
),

    (
  'ERP PhD Student Strength Doctoral Program',
  'NULL',
  22,
  '{
      "ERP PhD Student Strength Doctoral Program": {
          "columns": [
              { "name": "ID", "type": "INT", "constraints": "AUTO_INCREMENT PRIMARY KEY" },
              { "name": "Program Year", "type": "VARCHAR(20)", "constraints": "NOT NULL" },
              { "name": "Full Time Students", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Part Time Students", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Total Students", "type": "INT", "constraints": "NOT NULL" }
          ]
      }
  }'
),

   (
  'PhD Student Strength',
  'NULL',
  22,
  '{
      "PhD Student Strength": {
          "columns": [
              { "name": "ID", "type": "INT", "constraints": "AUTO_INCREMENT PRIMARY KEY" },
              { "name": "Program Year", "type": "VARCHAR(20)", "constraints": "NOT NULL" },
              { "name": "Full Time Students", "type": "INT", "constraints": "NOT NULL" },
              { "name": "Part Time Students", "type": "INT", "constraints": "NOT NULL" }
          ]
      }
  }'
),
(
    'Placement UG 4 Year Program',
    'NULL',
    21,
    '{
        "Placement UG 4 Year Program": {
            "columns": [
                { "name": "Academic Year Intake", "type": "VARCHAR(9)", "constraints": "" },
                { "name": "First Year Intake", "type": "INT", "constraints": "" },
                { "name": "First Year Admitted", "type": "INT", "constraints": "" },

                { "name": "Academic Year Lateral Entry", "type": "VARCHAR(9)", "constraints": "" },
                { "name": "Lateral Entry Admitted", "type": "INT", "constraints": "" },

                { "name": "Academic Year Graduated", "type": "VARCHAR(9)", "constraints": "" },
                { "name": "Graduated In Time", "type": "INT", "constraints": "" },

                { "name": "Students Placed", "type": "INT", "constraints": "" },
                { "name": "Median Salary Rs", "type": "DECIMAL(12,2)", "constraints": "" },
                { "name": "Median Salary Words", "type": "VARCHAR(100)", "constraints": "" },
                { "name": "Higher Studies Count", "type": "INT", "constraints": "" }
            ]
        }
    }'
),

  (
    'PG 2 Year Program',
    'NULL',
    21,
    '{
        "PG 2 Year Program": {
            "columns": [
                { "name": "Academic Year", "type": "VARCHAR(9)", "constraints": "" },
                { "name": "First Year Intake", "type": "INT", "constraints": "" },
                { "name": "First Year Admitted", "type": "INT", "constraints": "" },

                { "name": "Academic Year Graduated", "type": "VARCHAR(9)", "constraints": "" },
                { "name": "Graduated In Time", "type": "INT", "constraints": "" },

                { "name": "Students Placed", "type": "INT", "constraints": "" },
                { "name": "Median Salary Rs", "type": "DECIMAL(12,2)", "constraints": "" },
                { "name": "Median Salary Words", "type": "VARCHAR(100)", "constraints": "" },
                { "name": "Higher Studies Count", "type": "INT", "constraints": "" }
            ]
        }
    }'
),

   (
    'Oracle nimish',
    'In this folder, we will manage Memorandum of understanding (MoU) with Oracle.',
    22,
    '{
        "Oracle nimish": {
            "columns": [
                { "name": "Organisation MoU Signed With", "type": "VARCHAR(255)", "constraints": "" },
                { "name": "Institution Or Industry Name", "type": "VARCHAR(255)", "constraints": "" },
                { "name": "MoU Signing Year", "type": "DATE", "constraints": "" },
                { "name": "MoU Duration", "type": "VARCHAR(100)", "constraints": "" },
                { "name": "MoU Activities Yearwise", "type": "TEXT", "constraints": "" },
                { "name": "Participants Count", "type": "INT", "constraints": "" }
            ]
        }
    }'
),

  (
  'Average Placement of Student',
  'In this folder, we will manage : Average Placement of Students',
  23,
  '{
      "Average Placement of Student": {
          "columns": [
              { "name": "Year", "type": "VARCHAR(10)", "constraints": "PRIMARY KEY (Year, Category)" },
              { "name": "Category", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Count", "type": "INT", "constraints": "" }
          ]
      }
  }'
),

   (
  'Placement Data',
  'In this folder, we will manage : Placement Data',
  23,
  '{
      "Placement Data": {
          "columns": [
              { "name": "S No", "type": "INT", "constraints": "PRIMARY KEY" },
              { "name": "Roll No", "type": "VARCHAR(20)", "constraints": "" },
              { "name": "Student Name", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Email", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Contact No", "type": "VARCHAR(20)", "constraints": "" },
              { "name": "Company Name", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Selection", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Package LPA", "type": "DECIMAL(5,2)", "constraints": "" },
              { "name": "Date", "type": "DATE", "constraints": "" },
              { "name": "Venue", "type": "VARCHAR(100)", "constraints": "" }
          ]
      }
  }'
),

   (
  'NAAC Journal Publication',
  'In this folder, we will manage faculties and students conference, journal, book, book chapter, patent, publications.',
  24,
  '{
      "NAAC Journal Publication": {
          "columns": [
              { "name": "Title of paper", "type": "VARCHAR(500)", "constraints": "NOT NULL" },
              { "name": "Name of the author/s", "type": "VARCHAR(300)", "constraints": "NOT NULL" },
              { "name": "Department of the teacher", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
              { "name": "Name of journal", "type": "VARCHAR(255)", "constraints": "NOT NULL" },
              { "name": "Year of publication", "type": "INT", "constraints": "NOT NULL" },
              { "name": "ISSN number", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Link to the recognition in UGC enlistment of the Journal /Digital Object Identifier (doi) number", "type": "TEXT", "constraints": "" },
              { "name": "Link to website of the Journal", "type": "TEXT", "constraints": "" },
              { "name": "Link to article/paper/abstract of the article", "type": "TEXT", "constraints": "" },
              { "name": "Is it listed in UGC Care list/Scopus/Web of Science/other, mention", "type": "VARCHAR(100)", "constraints": "" }
          ]
      }
  }'
),

    (
  'Qiv Journal Publication',
  'In this folder, we will manage faculties and students conference, journal, book, book chapter, patent, publications.',
  24,
  '{
      "Qiv Journal Publication": {
          "columns": [
              { "name": "S.No.", "type": "INT", "constraints": "PRIMARY KEY" },
              { "name": "Department", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
              { "name": "Contributing faculty members from concerned department", "type": "VARCHAR(300)", "constraints": "NOT NULL" },
              { "name": "Title of the Paper", "type": "VARCHAR(500)", "constraints": "NOT NULL" },
              { "name": "International/National Level", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Publishers Name", "type": "VARCHAR(200)", "constraints": "" },
              { "name": "Journals Name", "type": "VARCHAR(300)", "constraints": "" },
              { "name": "Indexing (SCI/ SCIE/ Scopus)", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "ISSN No.", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "ISBN No.", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Volume", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Issue", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Year", "type": "INT", "constraints": "" },
              { "name": "Article Id/ Page No.", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Date of Publication", "type": "DATE", "constraints": "" },
              { "name": "Is co-authored by faculty members from different departments of parent Institute (Yes/ No)", "type": "VARCHAR(10)", "constraints": "" },
              { "name": "Proof Enclosed (Yes/ No)", "type": "VARCHAR(10)", "constraints": "" }
          ]
      }
  }'
),

   (
  'NBA Journal Publication',
  'In this folder, we will manage faculties and students conference, journal, book, book chapter, patent, publications.',
  24,
  '{
      "NBA Journal Publication": {
          "columns": [
              { "name": "Title of paper", "type": "VARCHAR(500)", "constraints": "NOT NULL" },
              { "name": "Name of the author/s", "type": "VARCHAR(300)", "constraints": "NOT NULL" },
              { "name": "Department of the teacher", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
              { "name": "Name of journal", "type": "VARCHAR(300)", "constraints": "NOT NULL" },
              { "name": "Year of publication", "type": "INT", "constraints": "NOT NULL" },
              { "name": "ISSN number", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Link to the recognition in UGC enlistment of the Journal /Digital Object Identifier (doi) number", "type": "VARCHAR(500)", "constraints": "" },
              { "name": "Link to website of the Journal", "type": "VARCHAR(500)", "constraints": "" },
              { "name": "Link to article/paper/abstract of the article", "type": "VARCHAR(500)", "constraints": "" },
              { "name": "Is it listed in UGC Care list/Scopus/Web of Science/other, mention", "type": "VARCHAR(150)", "constraints": "" }
          ]
      }
  }'
),

  (
  'Master Journal Publications',
  'In this folder, we will manage faculties and students conference, journal, book, book chapter, patent, publications.',
  24,
  '{
      "Master Journal Publications": {
          "columns": [
              { "name": "Name of Faculty", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
              { "name": "Department", "type": "VARCHAR(150)", "constraints": "NOT NULL" },
              { "name": "Title of Paper", "type": "VARCHAR(500)", "constraints": "NOT NULL" },
              { "name": "Role(Author/Editor/Other)", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "List of Authors /Editors(as per the paper sequence)", "type": "TEXT", "constraints": "" },
              { "name": "Name of journal", "type": "VARCHAR(300)", "constraints": "" },
              { "name": "Publishers Name", "type": "VARCHAR(200)", "constraints": "" },
              { "name": "Volume, Issue", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Article Id/ Page No.", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Date of Publication", "type": "DATE", "constraints": "" },
              { "name": "ISSN Number", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "ISBN Number", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "DOI", "type": "VARCHAR(200)", "constraints": "" },
              { "name": "Status", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Indexing (SCI/ SCIE/ Scopus)", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Link to website of the Journal", "type": "VARCHAR(500)", "constraints": "" },
              { "name": "Link to article/paper/abstract of the article", "type": "VARCHAR(500)", "constraints": "" },
              { "name": "Attach the Paper", "type": "VARCHAR(500)", "constraints": "" }
          ]
      }
  }'
),

    (
  'NAAC Faculty Participation',
  'In this folder, we will manage faculties participation Professional Development programs like FDPs/ Workshops/Seminars/STTPs/Orientation/Induction/Refresher course/training program and conferences.',
  24,
  '{
      "NAAC Faculty Participation": {
          "columns": [
              { "name": "S.No.", "type": "INT", "constraints": "PRIMARY KEY" },
              { "name": "Emp ID", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Department", "type": "VARCHAR(150)", "constraints": "" },
              { "name": "Name of faculty member", "type": "VARCHAR(150)", "constraints": "" },
              { "name": "Title of Program", "type": "VARCHAR(300)", "constraints": "" },
              { "name": "Conference/FDPs/Workshop/Semnar/STTP", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Mode(Online/Offline)", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Level(National/International)", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Organizer", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "Sponsored by", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "Duration", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Session", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "No.of Days", "type": "INT", "constraints": "" },
              { "name": "Proof Enclosed", "type": "VARCHAR(10)", "constraints": "" }
          ]
      }
  }'
),

  (
  'QIV Faculty Participation',
  'In this folder, we will manage faculties participation Professional Development programs like FDPs/ Workshops/Seminars/STTPs/Orientation/Induction/Refresher course/training program and conferences.',
  24,
  '{
      "QIV Faculty Participation": {
          "columns": [
              { "name": "S.No.", "type": "INT", "constraints": "PRIMARY KEY" },
              { "name": "Name of the Faculty", "type": "VARCHAR(150)", "constraints": "" },
              { "name": "Department", "type": "VARCHAR(150)", "constraints": "" },
              { "name": "Title of Event/Program", "type": "VARCHAR(300)", "constraints": "" },
              { "name": "Type Conference/Workshop/Seminar/STTP", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "International/National Level", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Organizer", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "Duration From| To", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Proof Enclosed (Yes/ No)", "type": "VARCHAR(10)", "constraints": "" }
          ]
      }
  }'
),
(
  'NBA Faculty Participation',
  'In this folder, we will manage faculties participation Professional Development programs like FDPs/ Workshops/Seminars/STTPs/Orientation/Induction/Refresher course/training program and conferences.',
  24,
  '{
      "NBA Faculty Participation": {
          "columns": [
              { "name": "S.No.", "type": "INT", "constraints": "" },
              { "name": "Emp ID", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Department", "type": "VARCHAR(150)", "constraints": "" },
              { "name": "Name of faculty member", "type": "VARCHAR(150)", "constraints": "" },
              { "name": "Title of Program", "type": "VARCHAR(300)", "constraints": "" },
              { "name": "Conference/FDPs/Workshop/Semnar/STTP", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Mode(Online/Offline)", "type": "VARCHAR(20)", "constraints": "" },
              { "name": "Level(National/International)", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Organizer", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "Grant Received from SKIT (YES/NO)", "type": "VARCHAR(5)", "constraints": "" },
              { "name": "Duration", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Session", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "No.of Days", "type": "INT", "constraints": "" },
              { "name": "Proof Enclosed", "type": "VARCHAR(10)", "constraints": "" }
          ]
      }
  }'
),
(
  'Master Faculty Participation',
  'In this folder, we will manage faculties participation Professional Development programs like FDPs/ Workshops/Seminars/STTPs/Orientation/Induction/Refresher course/training program and conferences.',
  24,
  '{
      "Master Faculty Participation": {
          "columns": [
              { "name": "S.No.", "type": "INT", "constraints": "" },
              { "name": "Emp ID", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Department", "type": "VARCHAR(150)", "constraints": "" },
              { "name": "Name of faculty member", "type": "VARCHAR(150)", "constraints": "" },
              { "name": "Title of Program", "type": "VARCHAR(300)", "constraints": "" },
              { "name": "Conference/FDPs/Workshop/Semnar/STTP", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Mode(Online/Offline)", "type": "VARCHAR(20)", "constraints": "" },
              { "name": "Level(National/International)", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Organizer", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "Sponsored by", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "Grant Received from SKIT (Y/N)", "type": "VARCHAR(3)", "constraints": "" },
              { "name": "Duration", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Session", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "No.of Days", "type": "INT", "constraints": "" },
              { "name": "Proof Enclosed(Y/N)", "type": "VARCHAR(3)", "constraints": "" }
          ]
      }
  }'
),
(
  'NAAC INDUSTRIAL TRAINING',
  'In this folder, detailed information related to summer internship of V semester students is shared.',
  16,
  '{
      "NAAC INDUSTRIAL TRAINING": {
          "columns": [
              { "name": "ProgrammeName", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "ProgramCode", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "RollNo", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "StudentName", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "FirmNameAddress", "type": "TEXT", "constraints": "" },
              { "name": "DurationFrom", "type": "DATE", "constraints": "" },
              { "name": "DurationTo", "type": "DATE", "constraints": "" },
              { "name": "ProofLink", "type": "TEXT", "constraints": "" }
          ]
      }
  }'
),
(
  'QIV INDUSTRIAL TRAINING',
  'In this folder, detailed information related to summer internship of V semester students is shared.',
  16,
  '{
      "QIV INDUSTRIAL TRAINING": {
          "columns": [
              { "name": "SNo", "type": "INT", "constraints": "PRIMARY KEY AUTO_INCREMENT" },
              { "name": "EmailAddress", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "RollNo", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "TrainingTitle", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "StipendAmount", "type": "DECIMAL(10, 2)", "constraints": "" },
              { "name": "StudentName", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "CompanyName", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "DateFrom", "type": "DATE", "constraints": "" },
              { "name": "DateTo", "type": "DATE", "constraints": "" },
              { "name": "CertificateLink", "type": "TEXT", "constraints": "" },
              { "name": "EvaluationFormLink", "type": "TEXT", "constraints": "" },
              { "name": "InformationVerified", "type": "BOOLEAN", "constraints": "" },
              { "name": "StipendProofLink", "type": "TEXT", "constraints": "" }
          ]
      }
  }'
),
(
  'NBA INDUSTRIAL TRAINING',
  '',
  16,
  '{
      "NBA INDUSTRIAL TRAINING": {
          "columns": [
              { "name": "SNo", "type": "INT", "constraints": "PRIMARY KEY AUTO_INCREMENT" },
              { "name": "EmailAddress", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "RollNo", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "TrainingTitle", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "StipendAmount", "type": "DECIMAL(10, 2)", "constraints": "" },
              { "name": "StudentName", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "CompanyName", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "DateFrom", "type": "DATE", "constraints": "" },
              { "name": "DateTo", "type": "DATE", "constraints": "" },
              { "name": "CertificateLink", "type": "TEXT", "constraints": "" },
              { "name": "EvaluationFormLink", "type": "TEXT", "constraints": "" },
              { "name": "InformationVerified", "type": "BOOLEAN", "constraints": "" },
              { "name": "StipendProofLink", "type": "TEXT", "constraints": "" }
          ]
      }
  }'
),
(
  'Student Courses',
  'In this folder, we will manage : Template for SKIT TIMES Data',
  17,
  '{
      "Student Courses": {
          "columns": [
              { "name": "S. No.", "type": "INT", "constraints": "PRIMARY KEY" },
              { "name": "Roll No.", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Enrolment No.", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Student Name", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "E-mail (SKIT Domain)", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "E-mail (Personal)", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Branch", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Section", "type": "VARCHAR(10)", "constraints": "" },
              { "name": "Name of Course 1", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Attach Course 1 Certificate", "type": "BLOB", "constraints": "" },
              { "name": "Name of Course 2", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Attach Course 2 Certificate", "type": "BLOB", "constraints": "" }
          ]
      }
  }'
),
(
  'COE Event Training Report',
  'In this folder, detailed information related to IoT CoE.',
  18,
  '{
      "COE Event Training Report": {
          "columns": [
              { "name": "Sr. No.", "type": "INT", "constraints": "PRIMARY KEY AUTO_INCREMENT" },
              { "name": "Dates (from-to) (in DD.MM.YYYY format only)", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Departments / Cell / Committees / Labs /COE", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "Name of Faculty Coordinator (s)", "type": "TEXT", "constraints": "" },
              { "name": "Title of the professional development program organised for students", "type": "TEXT", "constraints": "" },
              { "name": "Title of the professional development program organised for teaching staff", "type": "TEXT", "constraints": "" },
              { "name": "Title of the administrative training program organised for non-teaching staff", "type": "TEXT", "constraints": "" },
              { "name": "No. of participants", "type": "INT", "constraints": "" },
              { "name": "Academic Session", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Collaboration-Details (If any)", "type": "TEXT", "constraints": "" },
              { "name": "Grant Received (YES/NO)", "type": "VARCHAR(3)", "constraints": "" },
              { "name": "Grant Details", "type": "TEXT", "constraints": "" },
              { "name": "Association with professional societies for organization of event", "type": "TEXT", "constraints": "" },
              { "name": "Number of SKIT students participated (Provided list of students with their RTU roll no. & Certificates)", "type": "TEXT", "constraints": "" },
              { "name": "Number of staff member participated (Provide list of staff member with their EMPLOYEE ID & Certificates)", "type": "TEXT", "constraints": "" },
              { "name": "Event report attached in proper format (YES/NO)", "type": "VARCHAR(3)", "constraints": "" },
              { "name": "Remarks", "type": "TEXT", "constraints": "" }
          ]
      }
  }'
),
(
  'NAAC QIV NBA MoU Report',
  'In this folder, we will manage Memorandum of understanding (MoU) with Microsoft.',
  19,
  '{
      "NAAC QIV NBA MoU Report": {
          "columns": [
              { "name": "Organization with which MoU is signed", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "Name of the institution/ industry/ corporate house", "type": "VARCHAR(255)", "constraints": "" },
              { "name": "Year of signing MoU", "type": "YEAR", "constraints": "" },
              { "name": "Duration", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "List the actual activities under each MOU year wise", "type": "TEXT", "constraints": "" },
              { "name": "Number of students/teachers participated under MoUs", "type": "INT", "constraints": "" }
          ]
      }
  }'
),
(
  'MASTER format faculty higher study',
  'In this folder, we will manage faculty’s Higher study data',
  14,
  '{
      "MASTER format faculty higher study": {
          "columns": [
              { "name": "Sr No", "type": "INT", "constraints": "" },
              { "name": "Name", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Department", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Designation", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Employee ID", "type": "VARCHAR(50)", "constraints": "" },
              { "name": "Qualification", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Joining Date", "type": "DATE", "constraints": "" },
              { "name": "Promotion Date", "type": "DATE", "constraints": "" },
              { "name": "Retirement Date", "type": "DATE", "constraints": "" },
              { "name": "Offer Letter Status", "type": "BOOLEAN", "constraints": "" },
              { "name": "Appointment Letter Status", "type": "BOOLEAN", "constraints": "" },
              { "name": "Highest Degree", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Degree Awarding University", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "PhD Pursuing", "type": "BOOLEAN", "constraints": "" },
              { "name": "PhD Registration Date", "type": "DATE", "constraints": "" },
              { "name": "PAN No", "type": "VARCHAR(20)", "constraints": "" },
              { "name": "Area of Specialization", "type": "VARCHAR(100)", "constraints": "" },
              { "name": "Date of Birth", "type": "DATE", "constraints": "" },
              { "name": "Info Correct As Per Knowledge", "type": "BOOLEAN", "constraints": "" },
              { "name": "Awards Recognitions Extension Activities", "type": "TEXT", "constraints": "" }
          ]
      }
  }'
),
(
  'AICTE format faculty personal data',
  'In this folder, we will manage faculties Personal data',
 13,
 '{
     "AICTE format faculty personal data": {
         "columns": [
             { "name": "Sr No", "type": "INT" },
             { "name": "Faculty Name", "type": "VARCHAR(100)" },
             { "name": "Department", "type": "VARCHAR(100)" },
             { "name": "PAN No", "type": "VARCHAR(20)" },
             { "name": "Aadhaar No", "type": "VARCHAR(20)" },
             { "name": "AICTE Unique ID", "type": "VARCHAR(50)" },
             { "name": "Valid Vidwan ID", "type": "VARCHAR(50)" },
             { "name": "Caste Category", "type": "VARCHAR(50)" },
             { "name": "RCI Status", "type": "VARCHAR(50)" },
             { "name": "Faculty Status", "type": "VARCHAR(50)" },
             { "name": "All India Council Status", "type": "VARCHAR(50)" },
             { "name": "Designation", "type": "VARCHAR(100)" },
             { "name": "Date of Joining", "type": "DATE" },
             { "name": "Date of Confirmation", "type": "DATE" },
             { "name": "Name as per Degree", "type": "VARCHAR(100)" },
             { "name": "Qualification", "type": "VARCHAR(100)" },
             { "name": "Additional Qualification", "type": "VARCHAR(100)" },
             { "name": "Faculty ID", "type": "VARCHAR(50)" },
             { "name": "Email ID", "type": "VARCHAR(100)" },
             { "name": "Mobile No", "type": "VARCHAR(15)" },
             { "name": "Highest Qualification", "type": "VARCHAR(100)" },
             { "name": "Program Taught", "type": "VARCHAR(100)" },
             { "name": "UG or PG or PhD", "type": "VARCHAR(20)" },
             { "name": "Appointment Type", "type": "VARCHAR(50)" },
             { "name": "Date of Appraisal", "type": "DATE" },
             { "name": "FDP Attended", "type": "VARCHAR(100)" },
             { "name": "FDP Duration", "type": "VARCHAR(50)" },
             { "name": "FDP Certificate Uploaded", "type": "BOOLEAN" },
             { "name": "Guide Ship Status", "type": "BOOLEAN" },
             { "name": "PG Guide", "type": "BOOLEAN" },
             { "name": "Doctorate Guide", "type": "BOOLEAN" },
             { "name": "Common Subject Teacher FY", "type": "BOOLEAN" }
         ]
     }
 }'
),
(
  'NAAC format faculty higher study',
  'In this folder, we will manage faculties Personal data',
 13,
 '{
     "NAAC format faculty higher study": {
         "columns": [
             { "name": "Sr No", "type": "INT" },
             { "name": "Name", "type": "VARCHAR(100)" },
             { "name": "Department", "type": "VARCHAR(100)" },
             { "name": "Designation", "type": "VARCHAR(100)" },
             { "name": "Employee ID", "type": "VARCHAR(50)" },
             { "name": "Qualification", "type": "VARCHAR(100)" },
             { "name": "Joining Date", "type": "DATE" },
             { "name": "Promotion Date", "type": "DATE" },
             { "name": "Retirement Date", "type": "DATE" },
             { "name": "Offer Letter Status", "type": "BOOLEAN" },
             { "name": "Appointment Letter Status", "type": "BOOLEAN" },
             { "name": "Highest Degree", "type": "VARCHAR(100)" },
             { "name": "Degree Awarding University", "type": "VARCHAR(100)" },
             { "name": "PhD Pursuing", "type": "BOOLEAN" },
             { "name": "PhD Registration Date", "type": "DATE" },
             { "name": "PhD Area of Specialization", "type": "VARCHAR(100)" },
             { "name": "Date of Birth", "type": "DATE" },
             { "name": "Information Verified", "type": "BOOLEAN" },
             { "name": "Awards and Recognitions", "type": "TEXT" }
         ]
     }
 }'
);