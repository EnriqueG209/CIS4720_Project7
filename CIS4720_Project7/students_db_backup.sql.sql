/* ==========================================================================
   students_db_backup.sql
   CIS 4720 Database Management and SQL

   WHAT THIS FILE IS
   A starter database for in_class_lab7b. It builds a schema called
   students_db holding one table of students, plus a view. The lab PCs are
   wiped every night, so a script like this one is how you get a working
   database back in a few seconds instead of typing it all again. The file
   is the database. The server is disposable.

   WHAT IT BUILDS
     1. A schema called students_db
     2. One table, STUDENT, with six columns and a primary key
     3. Five rows of data
     4. One view, STUDENT_GPA, showing just the names and the grade averages

   BEFORE YOU RUN IT
   The schema has to exist before VS Code can connect to it, and VS Code
   will not create one for you. Step 4 of the lab has you create it at the
   command prompt first. Do that step before you open VS Code.

   HOW TO RUN IT
   Open it in VS Code with SQLTools connected to students_db, then run the
   whole file. Lab7b walks you through it.

   READ THIS BEFORE YOU RUN IT A SECOND TIME
   Run it once and everything works. Run it twice and you get errors,
   because the table already exists and the rows are already there. Step 10
   of the lab explains which parts to comment out and why.
   ========================================================================== */


-- ======================================================================
-- SECTION 1. The schema
-- A schema is the container that holds your tables. CREATE DATABASE makes
-- one, and USE tells the server which one the statements below apply to.
-- ======================================================================

-- Create the schema. IF NOT EXISTS means this line is safe to run twice,
-- and safe to run even though you already made it at the command prompt.
-- CREATE DATABASE IF NOT EXISTS students_db;

-- Switch into it. Everything below lands inside this schema.
USE students_db;


-- ======================================================================
-- PROJECT 7 STEP 6. Create the COURSE table

-- Stores course information and prevents duplicate course IDs.
CREATE TABLE COURSE (
    course_id INT NOT NULL,
    course_code VARCHAR(10) NOT NULL,
    course_title VARCHAR(50) NOT NULL,
    credits INT,
    dept VARCHAR(30),
    PRIMARY KEY (course_id)
);

-- Checks the structure of the new table.
DESCRIBE COURSE;


-- ======================================================================
-- SECTION 3. The data
-- Five students. Two enrolled in the same term, which is useful later when
-- you start filtering on a date.
-- ======================================================================

INSERT INTO COURSE VALUES (101,'CIS4720','Database Management and SQL',3,'CIS');
INSERT INTO COURSE VALUES (102,'CIS2000','Intro to Programming',3,'CIS');
INSERT INTO COURSE VALUES (103,'MATH1600','Calculus I',4,'Mathematics');
INSERT INTO COURSE VALUES (104,'BUS2100','Principles of Management',3,'Business');
INSERT INTO COURSE VALUES (105,'CIS4850','Advanced Python',3,'CIS');
SELECT * FROM COURSE;


-- PROJECT 7 STEP 8. Create the ENROLLMENT table

-- Connects each student to their courses and prevents invalid enrollments.
CREATE TABLE ENROLLMENT (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    term VARCHAR(15),
    grade CHAR(1),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id),
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id)
);

-- Checks that the enrollment columns and keys were created.
DESCRIBE ENROLLMENT;


-- PROJECT 7 STEP 9. Add rows to ENROLLMENT

-- Adds the student-course pairings used for the schedule reports.
INSERT INTO ENROLLMENT VALUES (1,101,'Fall 2026','A');

-- Adds a second course for student 1.
INSERT INTO ENROLLMENT VALUES (1,102,'Fall 2026','B');

-- Adds a third course for student 1.
INSERT INTO ENROLLMENT VALUES (1,103,'Spring 2026','A');

-- Records student 2 in Database Management.
INSERT INTO ENROLLMENT VALUES (2,101,'Fall 2026','B');

-- Records student 2 in Management.
INSERT INTO ENROLLMENT VALUES (2,104,'Fall 2026','C');

-- Records student 3 in Database Management.
INSERT INTO ENROLLMENT VALUES (3,101,'Fall 2026','A');

-- Records student 3 in Calculus.
INSERT INTO ENROLLMENT VALUES (3,103,'Spring 2026','A');

-- Records student 4 in Programming.
INSERT INTO ENROLLMENT VALUES (4,102,'Fall 2026','C');

-- Confirms that eight enrollment records were added.
SELECT COUNT(*) AS enrollment_rows FROM ENROLLMENT;


-- -- Tests whether an enrollment for a nonexistent student is rejected.
-- INSERT INTO ENROLLMENT VALUES (99,101,'Fall 2026','A');

-- -- Tests whether an enrollment for a nonexistent course is rejected.
-- INSERT INTO ENROLLMENT VALUES (1,999,'Fall 2026','A');

-- -- Tests whether the same student-course combination can be inserted twice.
-- INSERT INTO ENROLLMENT VALUES (1,101,'Spring 2027','B');

-- PROJECT 7 STEP 10. Join one, the three table join

-- Combines student names, course details, and enrollment records.
-- This makes the schedule easier to read than using IDs alone.
SELECT s.first_name, s.last_name,
       c.course_code, c.course_title,
       e.term, e.grade
FROM STUDENT s
JOIN ENROLLMENT e ON s.student_id = e.student_id
JOIN COURSE c ON e.course_id = c.course_id
ORDER BY s.last_name, c.course_code;

-- PROJECT 7 STEP 11. Join two, the outer join

-- Counts each student's courses, including students taking none.
SELECT s.first_name, s.last_name,
       COUNT(e.course_id) AS courses_taken
FROM STUDENT s
LEFT JOIN ENROLLMENT e
ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name
ORDER BY courses_taken DESC, s.last_name;

-- Keeps every student in the schedule, even without an enrollment.
-- Empty course fields show NULL for students without classes.
SELECT s.first_name, s.last_name,
       c.course_code, c.course_title,
       e.term, e.grade
FROM STUDENT s
LEFT JOIN ENROLLMENT e ON s.student_id = e.student_id
LEFT JOIN COURSE c ON e.course_id = c.course_id
ORDER BY s.last_name, c.course_code;

-- Finds courses with no enrolled students.
SELECT c.course_code, c.course_title
FROM COURSE c
LEFT JOIN ENROLLMENT e ON c.course_id = e.course_id
WHERE e.student_id IS NULL;


-- PROJECT 7 STEP 12. View one, STUDENT_SCHEDULE

-- Saves the combined student and course information as a reusable schedule.
CREATE VIEW STUDENT_SCHEDULE AS
SELECT s.first_name, s.last_name,
       c.course_code, c.course_title,
       e.term, e.grade
FROM STUDENT s
JOIN ENROLLMENT e ON s.student_id = e.student_id
JOIN COURSE c ON e.course_id = c.course_id;

-- Displays every record from the saved schedule.
SELECT * FROM STUDENT_SCHEDULE;

-- Filters the schedule to Ana Reyes.
SELECT * FROM STUDENT_SCHEDULE
WHERE last_name = 'Reyes';

-- Finds everyone enrolled in CIS4720.
SELECT * FROM STUDENT_SCHEDULE
WHERE course_code = 'CIS4720';


-- PROJECT 7 STEP 13. View two, COURSE_HEADCOUNT

-- Counts students in each course while keeping empty classes visible.
CREATE VIEW COURSE_HEADCOUNT AS
SELECT c.course_code, c.course_title,
       COUNT(e.student_id) AS students_enrolled
FROM COURSE c
LEFT JOIN ENROLLMENT e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_title;

-- Displays course enrollment totals from highest to lowest.
SELECT * FROM COURSE_HEADCOUNT
ORDER BY students_enrolled DESC;

-- Checks that the database contains the expected tables and views.
SHOW FULL TABLES;


-- Tests whether a calculated enrollment count can be edited directly.
-- Expected error 1288 because this aggregate view is not updatable.
-- UPDATE COURSE_HEADCOUNT
SET students_enrolled = 99
WHERE course_code = 'CIS4720';
-- ======================================================================
-- SECTION 4. The view
-- A view is a stored SELECT statement you can query as if it were a table.
-- This one shows only the names and the grade average, so anyone using it
-- cannot reach the id, the major or the enrollment date.
-- ======================================================================

-- CREATE VIEW STUDENT_GPA AS
-- SELECT first_name, last_name, gpa
-- FROM STUDENT;


-- ======================================================================
-- SECTION 5. Checks
-- These only read. They are safe to run as many times as you like, so
-- leave them switched on even after the first run.
-- ======================================================================

-- All five rows, straight from the table.
SELECT * FROM STUDENT;

-- The view, highest grade average first. Three columns, not six.
SELECT * FROM STUDENT_GPA ORDER BY gpa DESC;

-- Should come back as 5 students and an average of 3.43.
SELECT COUNT(*) AS students, ROUND(AVG(gpa), 2) AS average_gpa FROM STUDENT;

-- STUDENT is a BASE TABLE and STUDENT_GPA is a VIEW. SHOW TABLES on its
-- own does not tell them apart, which is why this one says FULL.
SHOW FULL TABLES;


-- ######################################################################
-- YOUR LAB7B WORK STARTS BELOW THIS LINE
--
-- Add your Chapter 5 statements under the headings below, in order. Put a
-- comment above every statement saying what it does, in your own words.
-- The comments are graded.
-- ######################################################################


-- STEP 11. Section 5.1, look at your schema
-- Shows which database the current connection is using.
SELECT DATABASE() AS my_schema;

-- Lists tables and views and identifies their types.
SHOW FULL TABLES;

-- STEP 12. Section 5.2, look at the data types
-- Displays the STUDENT columns, types, and key restrictions.
DESCRIBE STUDENT;

-- STEP 13. Section 5.3, create a table by copying with a subquery
-- Copies four columns and all five student rows into a new table.
-- CREATE TABLE STUDENT_COPY AS
SELECT student_id, first_name, last_name, gpa
FROM STUDENT;

-- Displays the rows copied into STUDENT_COPY.
SELECT * FROM STUDENT_COPY;

-- Shows that the copied table did not inherit the primary key.
SHOW CREATE TABLE STUDENT_COPY;

-- STEP 14. Section 5.4, change the structure of the copy
-- Adds a one-character honors column to the copied table.
-- ALTER TABLE STUDENT_COPY ADD COLUMN honors CHAR(1);

-- Expands last names to 50 characters while keeping them required.
-- ALTER TABLE STUDENT_COPY
MODIFY COLUMN last_name VARCHAR(50) NOT NULL;

-- Makes student_id unique and required in the copied table.
-- ALTER TABLE STUDENT_COPY ADD PRIMARY KEY (student_id);

-- Checks the updated columns and primary key.
DESCRIBE STUDENT_COPY;

-- Tests whether the primary key prevents duplicate student IDs.
-- INSERT INTO STUDENT_COPY
-- VALUES (1,'Duplicate','Row',0.00,NULL);

-- Removes the temporary honors column from the copied table.
-- ALTER TABLE STUDENT_COPY DROP COLUMN honors;
-- STEP 15. Section 5.5, insert, update and delete a row
-- Adds Omar as a sixth student in the copied table.
-- INSERT INTO STUDENT_COPY
VALUES (6,'Omar','Faruqi',3.10);

-- Confirms Omar was added with a GPA of 3.10.
SELECT * FROM STUDENT_COPY WHERE student_id = 6;

-- Changes only Omar's GPA to 3.35.
-- UPDATE STUDENT_COPY
SET gpa = 3.35
WHERE student_id = 6;

-- Confirms Omar's GPA was updated.
SELECT * FROM STUDENT_COPY WHERE student_id = 6;

-- Removes only Omar's record from the copied table.
-- DELETE FROM STUDENT_COPY WHERE student_id = 6;

-- Confirms five rows remain after deleting Omar.
SELECT COUNT(*) AS rows_left FROM STUDENT_COPY;

-- STEP 16. Section 5.6, create a view and update through it

-- Creates a view of students whose GPAs are at least 3.50.
-- CREATE VIEW HIGH_GPA AS
SELECT student_id, first_name, last_name, gpa
FROM STUDENT_COPY
WHERE gpa >= 3.50;

-- Displays students with high GPAs from highest to lowest.
SELECT * FROM HIGH_GPA ORDER BY gpa DESC;

-- Shows Ana's GPA before the change.
SELECT student_id, gpa
FROM STUDENT_COPY
WHERE student_id = 1;

-- Updates Ana's GPA through the view.
-- UPDATE HIGH_GPA
SET gpa = 3.95
WHERE student_id = 1;

-- Confirms the underlying table was updated.
SELECT student_id, gpa
FROM STUDENT_COPY
WHERE student_id = 1;

-- Creates a summary view of the student count and average GPA.
-- CREATE VIEW GPA_SUMMARY AS
SELECT COUNT(*) AS n,
       ROUND(AVG(gpa), 2) AS avg_gpa
FROM STUDENT_COPY;

-- Tests whether an aggregate view can be updated.
-- UPDATE GPA_SUMMARY SET avg_gpa = 4.00;

SHOW FULL TABLES;