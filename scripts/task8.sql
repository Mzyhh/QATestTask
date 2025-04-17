CREATE OR REPLACE FUNCTION get_random_string( string_length INTEGER, possible_chars TEXT
        DEFAULT 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ абвгдеёжзийклмнопрстуфхцчшщъыьэюя')
RETURNS text AS $$
DECLARE
    output TEXT = '';
    i INTEGER;
BEGIN
    FOR i IN 1..string_length LOOP
        output := output || substr(possible_chars, get_random_int(1, 67), 1);
    END LOOP;
    RETURN output;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_random_int(min_value INTEGER, max_value INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN floor(random() * (max_value + 1 - min_value) + min_value)::int;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPlACE FUNCTION random_varint(nrecords INTEGER, minint INTEGER, maxint INTEGER) 
RETURNS TABLE(txt varchar(100), num integer) as $$
BEGIN
    RETURN query SELECT get_random_string(get_random_int(1, 100))::varchar(100) as txt, 
                        get_random_int(minint, maxint) as num
                 FROM generate_series(1, nrecords);
END;
$$ LANGUAGE plpgsql;


-- main block
DO $$
DECLARE 
    N integer = 1000;
    i integer;
    student_id integer;
    course_no integer;
    exam_score integer;
    nstudents integer;
    ncourses integer;
BEGIN
    INSERT INTO Students (name, start_year) SELECT * FROM random_varint(N, 2000, 2025);
    RAISE NOTICE 'Inserted % student records', n;
    INSERT INTO Courses (title, hours) SELECT * FROM random_varint(N, 1, 1000);
    RAISE NOTICE 'Inserted % course records', n;

    SELECT COUNT(*) INTO nstudents FROM Students;
    SELECT COUNT(*) INTO ncourses FROM Courses;
    FOR i in 1..n LOOP
        SELECT s_id INTO student_id FROM Students LIMIT 1 OFFSET get_random_int(1, nstudents - 1);
        SELECT c_no INTO course_no FROM Courses LIMIT 1 OFFSET get_random_int(1, ncourses - 1);
        exam_score := get_random_int(0, 100);

        INSERT INTO exams (s_id, c_no, score)
        VALUES (student_id, course_no, exam_score)
        ON CONFLICT DO NOTHING;
    END LOOP;
    RAISE NOTICE 'Inserted % exam records', n;
END;
$$ LANGUAGE plpgsql;
