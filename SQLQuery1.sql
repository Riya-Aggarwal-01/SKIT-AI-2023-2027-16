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