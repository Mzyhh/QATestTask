## Секция работы с базами данных. 

### Задание 1. Развёртка `PostgreSQL` в `Docker`.

```sh
# опционально: при запуске контейнера Docker Daemon сам подтянет его образ с DockerHub
docker pull postgres

# общий синтаксис создания контейнера на основании образа postgres
docker run --name some_container -e POSTGRES_PASSWORD=password -d database 

# подключение к базе данных в интерактивном режиме
docker exec -it some_container psql -U user -d database
```

### Задание 2. Создание БД `academy`.

Сперва создадим [Dockerfile](Dockerfile):

```Dockerfile
FROM postgres
ENV POSTGRES_DB=academy
ENV POSTGRES_USER=user
COPY scripts/init.sql /docker-entrypoint-initdb.d/
COPY scripts/*.sql /home/script/
```

После чего соберем на его основании собственный образ `Docker`:

```sh
docker build -t academy .

docker run --name academy -e POSTGRES_PASSWORD=password -d academy
```

### Задание 3. Добавление таблиц.

*Типы столбцов*:

+ `s_id`, `c_no` являются первичными ключами таблицы.
+ `name`, `title` - строки фиксированной длины 100, так как
данной длины вполне достаточно для данных объектов, а также это спасает
систему от загрузки текста романа "Война и мир" в поле "ФИО пользователя".
+ `start_year`, `hours` - целочисленные, а не `DATE` и `TIME` в соответствии
с названиями данных столбцов. `hours` не дробный, потому что обычно не принято
указывать дробные часы на курсы. На оба поставлен `constraint CHECK(>0)`, так как,
очевидно, ни один студент точно не мог поступить в ВУЗ до начала эры
(в нашей системе счисления), и курс не может длиться отрицательное число часов
или быть равен 0, потому что это имеет мало смысла.
+ `score`: диапазон оценки за курс 0-100, как это принято в НИЯУ МИФИ,
дробные оценки в таком случае избыточны.

```sql
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
    FOREIGN KEY (c_no) REFERENCES Courses (c_no) ON DELETE CASCADE
);
```

При создании образа этот файл помещается в директорию `docker-entrypoint-initdb.d`.
Файлы из этой директории автоматически исполняются при запуске контейнера.

### Задание 4. Пробные записи.

[Скрипт](scripts/task4.sql)

```sql
INSERT INTO Students (name, start_year)
VALUES
    ('Иванов Иван Иванович', 2022),
    ('Аделаидов Максат Ильшатович', 2021),
    ('Шварценегер-Невский Александр Галактионович', 2024),
    ('Оперемок Дмитрий Александрович', 2020),
    ('Виктор Павел Максимович', 2022);

INSERT INTO Courses (title, hours)
VALUES
    ('Математическое моделирование', 40),
    ('Функциональный анализ', 140),
    ('Алгоритмы и структуры данных', 200);

INSERT INTO Exams (s_id, c_no, score)
VALUES
    (1, 1, 70),
    (2, 1, 100),
    (3, 2, 20),
    (4, 1, 60),
    (1, 3, 85);
```

### Задание 5. Студенты, не сдавшие ни одного экзамена.

Решение с `JOIN`:

```sql
SELECT s.* FROM Students s 
LEFT JOIN Exams e ON s.s_id = e.s_id 
WHERE e.s_id IS NULL;
```

Решение с `sub-query` (медленнее, чем первый вариант):

```sql
SELECT * FROM Students s 
WHERE s.s_id NOT IN 
    (SELECT DISTINCT e.s_id FROM Exams e);
```

### Задание 6.

```sql
SELECT name, COUNT(Exams.s_id) as CountExams
FROM Students
JOIN Exams ON Students.s_id = Exams.s_id
GROUP BY name;
```

Данная реализация не учитывает студентов, не сдавших ни одного экзамена, 
как это указано в задании.
Но если мы всё же хотим получить более полный список, то следует использовать
следующий скрипт:

```sql
SELECT name, COUNT(Exams.s_id) as CountExams 
FROM Students
LEFT JOIN Exams ON Students.s_id = Exams.s_id 
GROUP BY name;
```

### Задание 7.

```sql
SELECT c.*, ROUND(AVG(score), 2) as average_score
FROM Courses c 
LEFT JOIN Exams e
ON c.c_no = e.c_no
GROUP BY c.c_no
ORDER BY average_score;
```

Если использовать `RIGHT JOIN`, то в списке окажутся также и курсы,
по которым экзаменов ещё не было или не предполагается (со средней оценкой
за экзамен равной 0)

### Задание 8. Время `plpgsql`.

```plpgsql
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
    INSERT INTO Students (name, start_year) 
        SELECT * FROM random_varint(N, 2000, 2025);

    RAISE NOTICE 'Inserted % student records', n;

    INSERT INTO Courses (title, hours) 
        SELECT * FROM random_varint(N, 1, 1000);

    RAISE NOTICE 'Inserted % course records', n;

    SELECT COUNT(*) INTO nstudents FROM Students;
    SELECT COUNT(*) INTO ncourses FROM Courses;
    FOR i in 1..n LOOP
        SELECT s_id INTO student_id FROM Students 
            LIMIT 1 OFFSET get_random_int(1, nstudents - 1);
        SELECT c_no INTO course_no FROM Courses
            LIMIT 1 OFFSET get_random_int(1, ncourses - 1);
        exam_score := get_random_int(0, 100);

        INSERT INTO exams (s_id, c_no, score)
        VALUES (student_id, course_no, exam_score)
        ON CONFLICT DO NOTHING;
    END LOOP;
    RAISE NOTICE 'Inserted % exam records', n;
END;
```

### Примечание.

Указанные скрипты в образе `academy` лежат в директории 
`home/scripts`. Чтобы выполнить их прямо в `psql` можно использовать следующую
команду:

```psql
\i \home\scripts\some_script.sql
```
