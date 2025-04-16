SELECT name, COUNT(name) as CountExams FROM Students s JOIN Exams e ON s.s_id = e.s_id WHERE e.s_id IS NOT NULL GROUP BY name;
