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

CREATE OR REPLACE FUNCTION get_random_int(
        IN min_value INTEGER,
        IN max_value INTEGER
    ) RETURNS INTEGER AS $$
BEGIN
    RETURN floor(random() * (max_value + 1) + min_value)::int;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_wtf(number INTEGER) 
RETURNS TABLE(s_id INTEGER, name VARCHAR(100), start_year INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT generate_series(1, number) AS s_id, get_random_string(50)::varchar(100) AS name, 
                        get_random_int(2000, 2025) AS start_year;
END;
$$ LANGUAGE plpgsql;
