CREATE DATABASE University;


USE University;


CREATE TABLE Region
(
RegionID INT IDENTITY(1, 1),
Region CHAR(25) CHECK (Region in('England', 'Scotland', 'Wales', 'Northern Ireland')) NOT NULL,
PRIMARY KEY (RegionID)
);


CREATE TABLE Student
(
StudentID INT IDENTITY(10, 1),
StudentName CHAR(50) NOT NULL,
RegionID INT NOT NULL,
PRIMARY KEY (StudentID),
FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);



CREATE TABLE Course
(
CourseID INT IDENTITY(20, 1),
Title CHAR(50) NOT NULL,
Credit INT CHECK (Credit in (15,30)) NOT NULL,
Quota INT NOT NULL,
PRIMARY KEY (CourseID)
);


CREATE TABLE StudentCourse
(
StudentID INT REFERENCES Student(StudentID) NOT NULL, 
CourseID INT REFERENCES Course(CourseID) NOT NULL, 
registrationDate Date NOT NULL,
PRIMARY KEY (StudentID, CourseID),
FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);


CREATE TABLE Staff
(
StaffID INT IDENTITY(30, 1),
StaffName CHAR(50) NOT NULL,
RegionID INT NOT NULL,
PRIMARY KEY (StaffID),
FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);


CREATE TABLE StudentStaff
(
StudentID INT REFERENCES Student(StudentID) NOT NULL, 
StaffID INT REFERENCES Staff(StaffID) NOT NULL, 
StaffType CHAR(25) CHECK(StaffType in ('Counsel', 'Tutor')) NOT NULL,
PRIMARY KEY (StudentID, StaffID, StaffType),
FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
FOREIGN KEY (StaffID) REFERENCES Staff(StaffID));




CREATE TABLE StaffCourse
(
StaffID INT REFERENCES Staff(StaffID) NOT NULL,
CourseID INT REFERENCES Course(CourseID) NOT NULL, 
PRIMARY KEY (StaffID, CourseID),
FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
FOREIGN KEY (CourseID) REFERENCES Course(CourseID));


CREATE TABLE Assignment
(
StudentID INT REFERENCES Student(StudentID) NOT NULL, 
CourseID INT REFERENCES Course(CourseID) NOT NULL, 
AssignmentID INT NOT NULL,
Note INT Check(Note <=100) NOT NULL,
PRIMARY KEY (StudentID, CourseID, AssignmentID),
FOREIGN KEY (StudentID, CourseID) REFERENCES StudentCourse(StudentID, CourseID));


CREATE FUNCTION check_volume()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT sc.StudentID, sum(Credit) 
FROM Course c JOIN StudentCourse sc ON c.CourseID=sc.CourseID
GROUP BY sc.StudentID
HAVING SUM(Credit) > 180) 
SELECT @ret = 1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE StudentCourse
ADD CONSTRAINT square_volume CHECK(dbo.check_volume() = 0);


CREATE FUNCTION check_volume2()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT avg(c.Quota) - count(c.CourseID)
FROM Course c JOIN StudentCourse sc ON c.CourseID=sc.CourseID
GROUP BY c.CourseID   
HAVING avg(c.Quota) -count(c.CourseID) < 0)
SELECT @ret = 1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE StudentCourse
ADD CONSTRAINT square_volume2 CHECK(dbo.check_volume2() = 0);


CREATE FUNCTION check_volume3()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT count(a.AssignmentID)
FROM Assignment a JOIN StudentCourse sc ON a.CourseID=sc.CourseID and a.StudentID = sc.StudentID
JOIN Course c ON a.CourseID = c.CourseID 
WHERE c.Credit = 30 
GROUP BY sc.StudentID, c.CourseID 
HAVING count(a.AssignmentID) > 5)
SELECT @ret =1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE Assignment
ADD CONSTRAINT square_volume3 CHECK(dbo.check_volume3() = 0);


CREATE FUNCTION check_volume4()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT count(a.AssignmentID)
FROM Assignment a JOIN StudentCourse sc ON a.CourseID=sc.CourseID and a.StudentID = sc.StudentID
JOIN Course c ON a.CourseID = c.CourseID 
WHERE c.Credit = 15 
GROUP BY sc.StudentID, c.CourseID 
HAVING count(a.AssignmentID) > 3)
SELECT @ret =1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE Assignment
ADD CONSTRAINT square_volume4 CHECK(dbo.check_volume4() = 0);


CREATE FUNCTION check_volume5()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT *
FROM Region r JOIN Student s ON r.RegionID = s.RegionID JOIN StudentStaff ss ON s.StudentID = ss.StudentID JOIN Staff sf ON ss.StaffID = sf.StaffID
WHERE s.RegionID != sf.RegionID)
SELECT @ret =1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE StudentStaff
ADD CONSTRAINT square_volume5 CHECK(dbo.check_volume5() = 0);


CREATE FUNCTION check_volume6()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT Count(s.StudentID)
FROM Region r JOIN Student s ON r.RegionID = s.RegionID JOIN StudentStaff ss ON s.StudentID = ss.StudentID JOIN Staff sf ON ss.StaffID = sf.StaffID
WHERE StaffType = 'Counsel'
GROUP BY s.StudentID
HAVING Count(s.StudentID) != 1)
SELECT @ret =1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE StudentStaff
ADD CONSTRAINT square_volume6 CHECK(dbo.check_volume6() = 0);


INSERT INTO Region (Region)
VALUES('England'),
('Scotland'),
('Wales'),
('Northern Ireland');



INSERT INTO Student ([StudentName], RegionID)
VALUES('Ali Güzel',  1),
('Osman Yücel',  1),
('Ömer Ýlhan', 1),
('Bekir Gül', 2),
('Ahmet Çiçek', 2),
('Mehmet Uyanýk', 3),
('Ayþe Menekþe', 4);



INSERT INTO Course (Title, Credit, Quota)
VALUES('Math', 30, 3),
('Physics', 30, 3),
('Chemistry', 30, 3),
('English', 30, 2),
('Biology', 15, 2),
('Fine Arts', 15, 2),
('German', 15, 2);

INSERT INTO Course (Title, Credit, Quota)
VALUES('Math3', 30, 3)


select * from course


INSERT INTO Staff ([StaffName],  RegionID)
VALUES('Selim Aydýn',  1),
('Semil Açýk', 1),
('Güngör Salih', 1),
('Gülsüm Çiçekçi', 2),
('Hatice Doðan', 2),
('Esra Gamze', 3),
('Eda Yücel', 4),

INSERT INTO Staff ([StaffName],  RegionID)
VALUES('Emre Þahin', 1);



INSERT INTO StaffCourse (StaffID, CourseID)
VALUES(30, 20),
(30, 21),
(31, 20),
(32, 22),
(33, 23),
(34, 25),
(35, 24),
(36, 24),
(33, 26);



INSERT INTO StudentStaff (StudentID, StaffID, StaffType)
VALUES(16, 36, 'Counsel'),
(16, 36, 'Tutor'),
(15, 35, 'Counsel'),
(10, 30, 'Counsel'),
(10, 30, 'Tutor'),
(10, 31, 'Tutor'),
(11, 32, 'Counsel');




INSERT INTO StudentCourse (StudentID, CourseID, registrationDate)
VALUES(10, 20, '2020-05-12'),
(10, 21, '2020-05-12'),
(10, 22, '2020-05-12'),
(10, 23, '2020-05-12'),
(10, 24, '2020-05-12'),
(10, 25, '2020-05-12'),
(11, 20, '2020-05-12'),
(11, 21, '2020-05-12'),
(12, 20, '2020-05-12'),
(11, 22, '2020-05-12'),
(13, 23, '2020-05-12');

INSERT INTO StudentCourse (StudentID, CourseID, registrationDate)
VALUES(10, 28, '2020-05-12')



INSERT INTO Assignment (StudentID, CourseID, AssignmentID, Note)
VALUES(10, 20, 1, 90),
(10, 20, 2, 95),
(10, 20, 3, 100),
(10, 20, 4, 100),
(10, 20, 5, 100),
(13, 23, 1, 95),
(13, 23, 2, 100),
(13, 23, 3, 95);


-- Update the credit for a course.
SELECT * FROM Course

UPDATE Course
SET Credit = 15 -- old value was 30
WHERE CourseID = 21

-- Swap the responsible staff of two students with each other in the student table.
SELECT * FROM StudentStaff

UPDATE StudentStaff
SET StaffID = 32-- old value was 30
WHERE StudentID = 10 and StaffID = 30 and StaffType = 'Counsel'

UPDATE StudentStaff
SET StaffID = 30-- old value was 32
WHERE StudentID = 11 and StaffID = 32 and StaffType = 'Counsel'

--Remove a staff member who is not assigned to any student from the staff table.
SELECT * FROM Staff


DELETE FROM Staff WHERE StaffID = (SELECT TOP 1 sf.StaffID FROM Student s JOIN StudentStaff ss ON s.StudentID = ss.StudentID RIGHT JOIN Staff sf ON ss.StaffID = sf.StaffID
WHERE s.StudentID IS NULL ORDER BY sf.StaffID desc);

--Add a student to the student table and enroll the student you added to any course.

INSERT INTO Student ([StudentName], RegionID)
VALUES('Zeynep Gülcü',  1);


SELECT * FROM Student


INSERT INTO StudentCourse (StudentID, CourseID, registrationDate)
VALUES(17, 24, '2020-10-10');