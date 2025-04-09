INSERT INTO Students (s_id, name, start_year)
VALUES
(1, 'Иванов Иван Иванович', 2022),
(2, 'Аделаидов Максат Ильшатович', 2021),
(3, 'Шварценегер-Невский Александр Галактионович', 2024);

INSERT INTO Courses (c_no, title, hours)
VALUES
(1, 'Математическое моделирование', 40),
(2, 'Функциональный анализ', 140);

INSERT INTO Exams (s_id, c_no, score)
VALUES
(1, 1, 3),
(2, 1, 5),
(3, 2, 4);
