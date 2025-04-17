-- show students who passed no exams

-- Using sub-query (slower)
SELECT * FROM Students s 
WHERE s.s_id NOT IN 
    (SELECT DISTINCT e.s_id FROM Exams e);

-- Using JOIN
SELECT s.* FROM Students s 
LEFT JOIN Exams e ON s.s_id = e.s_id 
WHERE e.s_id IS NULL;
