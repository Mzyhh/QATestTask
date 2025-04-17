CREATE OR REPLACE FUNCTION get_random_string( string_length INTEGER, possible_chars TEXT
        DEFAULT 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ абвгдеёжзийклмнопрстуфхцчшщъыьэюя'
    ) RETURNS text AS $$
DECLARE
    output TEXT = '';
    i INT4;
    pos INT4;
BEGIN
    FOR i IN 1..string_length LOOP
        pos := 1 + floor(random() * (LENGTH(possible_chars) - 1))::int;
        output := output || substr(possible_chars, pos, 1);
    END LOOP;
    RETURN output;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_random_int( min_value INTEGER, max_value INTEGER) RETURNS INTEGER AS $$
BEGIN
    RETURN floor(random() * (max_value + 1 - min_value) + min_value)::int;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_students(number INTEGER) 
RETURNS TABLE(name VARCHAR(100), start_year INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT get_random_string(50)::varchar(100) AS name, 
                        get_random_int(2000, 2025) AS start_year
                 FROM generate_series(1, number);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_courses(records INTEGER)
RETURNS TABLE(title VARCHAR(100), hours INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT get_random_string(100)::varchar(100) AS title,
                        get_random_int(1, 500) AS hours
                 FROM generate_series(1, records);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_exams(records INTEGER)
RETURNS TABLE(s_id INTEGER, c_no INTEGER, score INTEGER) AS $$
BEGIN
    RETURN QUERY
END;
$$ LANGUAGE plpgsql;

INSERT INTO Students (name, start_year) SELECT * FROM random_students(100);
INSERT INTO courses (title, hours) SELECT * FROM random_courses(20);
