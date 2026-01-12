DROP DATABASE IF EXISTS stepproject;
CREATE DATABASE IF NOT EXISTS stepproject;
USE stepproject;

-- Таблиця викладачів
CREATE TABLE IF NOT EXISTS teachers (
  teacher_no INT PRIMARY KEY AUTO_INCREMENT,
  teacher_name VARCHAR(100),
  phone_no VARCHAR(20)
);

-- Таблиця курсів
CREATE TABLE IF NOT EXISTS courses (
  course_no INT PRIMARY KEY AUTO_INCREMENT,
  course_name VARCHAR(100),
  start_date DATE,
  end_date DATE
);

-- Таблиця студентів (із зовнішніми ключами)
CREATE TABLE IF NOT EXISTS students (
  student_no INT PRIMARY KEY AUTO_INCREMENT,
  teacher_no INT,
  course_no INT,
  student_name VARCHAR(100),
  email VARCHAR(100),
  birth_date DATE,
  FOREIGN KEY (teacher_no) REFERENCES teachers(teacher_no),
  FOREIGN KEY (course_no) REFERENCES courses(course_no)
);


START TRANSACTION;

-- Викладачі
INSERT INTO teachers (teacher_name, phone_no) VALUES
('Олена Ковальчук', '0671234567'),
('Ігор Сидоренко', '0509876543'),
('Марія Гончар', '0631122334'),
('Андрій Литвин', '0669988776'),
('Наталія Шевченко', '0685566778'),
('Василь Бондар', '0953344556'),
('Тетяна Романенко', '0734455667');

-- Курси
INSERT INTO courses (course_name, start_date, end_date) VALUES
('Основи програмування', '2024-09-01', '2024-12-15'),
('Бази даних', '2024-09-01', '2024-12-15'),
('Веб-розробка', '2024-10-01', '2025-01-20'),
('Математика для ІТ', '2024-09-15', '2024-12-30'),
('Машинне навчання', '2025-01-10', '2025-04-25'),
('Кібербезпека', '2024-11-01', '2025-02-28'),
('Аналіз даних', '2025-02-01', '2025-05-15');

-- Студенти + дублікати
INSERT INTO students (teacher_no, course_no, student_name, email, birth_date) VALUES
(1, 1, 'Анна Мельник', 'anna.m@example.com', '2003-05-12'),
(2, 2, 'Олександр Іванов', 'olex.iv@example.com', '2002-11-23'),
(3, 3, 'Ірина Кравець', 'irina.k@example.com', '2004-02-08'),
(4, 4, 'Дмитро Савченко', 'd.sav@example.com', '2001-07-19'),
(5, 5, 'Катерина Лисенко', 'katya.l@example.com', '2003-09-30'),
(6, 6, 'Богдан Черненко', 'bogdan.c@example.com', '2002-03-15'),
(7, 7, 'Ольга Ткаченко', 'olga.t@example.com', '2004-12-01'),
-- дублікати:
(1, 1, 'Анна Мельник', 'anna.m@example.com', '2003-05-12'),
(1, 1, 'Анна Мельник', 'anna.m@example.com', '2003-05-12'),
(1, 1, 'Анна Мельник', 'anna.m@example.com', '2003-05-12');

COMMIT;


SELECT 
  t.teacher_no,
  t.teacher_name,
  COUNT(s.student_no) AS student_count
FROM teachers t
LEFT JOIN students s ON t.teacher_no = s.teacher_no
GROUP BY t.teacher_no, t.teacher_name;



INSERT INTO stepproject.students (teacher_no, course_no, student_name, email, birth_date)
SELECT teacher_no, course_no, student_name, email, birth_date
FROM stepproject.students
LIMIT 3;


SELECT teacher_no, course_no, student_name, email, birth_date, COUNT(*) AS duplicates
FROM students
GROUP BY teacher_no, course_no, student_name, email, birth_date
HAVING COUNT(*) > 1;