CREATE TABLE Students (
    s_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_year INTEGER NOT NULL CHECK(start_year > 0)
);

CREATE TABLE Courses (
    c_no SERIAL PRIMARY KEY,
    title VARCHAR(100) UNIQUE NOT NULL,
    hours INTEGER NOT NULL CHECK(hours > 0) 
);

CREATE TABLE Exams (
    s_id INTEGER NOT NULL,
    c_no INTEGER NOT NULL,
    score INTEGER DEFAULT 0 CHECK(score >= 0 AND score <= 100),
    FOREIGN KEY (s_id) REFERENCES Students (s_id) ON DELETE CASCADE,
    FOREIGN KEY (c_no) REFERENCES Courses (c_no) ON DELETE CASCADE,
    PRIMARY KEY (s_id, c_no)
);
