SELECT c.*, SUM(score)/COUNT(score) as average_score
FROM Courses c 
LEFT JOIN Exams e
ON c.c_no = e.c_no
GROUP BY c.c_no
ORDER BY average_score

-- if you want to see courses without any passed exam use RIGHT JOIN
