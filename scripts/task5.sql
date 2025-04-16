SELECT * FROM Students s 
WHERE
    (SELECT COUNT(*) FROM exams e WHERE e.s_id = s.s_id) = 0;

-- SELECT s.* FROM Students s LEFT JOIN Exams e ON s.s_id = e.s_id WHERE e.s_id IS NULL;
