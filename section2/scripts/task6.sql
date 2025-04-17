-- show students with number of passed exams 
-- only for student with at least one passed exam else use commented version

SELECT name, COUNT(Exams.s_id) as CountExams
FROM Students
JOIN Exams ON Students.s_id = Exams.s_id
GROUP BY name;

-- SELECT name, COUNT(Exams.s_id) as CountExams 
-- FROM Students 
-- LEFT JOIN Exams ON Students.s_id = Exams.s_id 
-- GROUP BY name;
