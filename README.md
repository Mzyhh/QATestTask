# QATestTask
Solution to the test task on QA engineer in PostgresProffesional

## Second task

**Step 1**: Pull official PostgreSQL image from DockerHub

```sh
docker pull postgres
```

**Step 2**: Create new Docker image based on postgres via Dockerfile

**Step 3**: Create the init.sql file. In the future we will use it to 
make whole `academy` database.

**Step 4**: Build the image

```sh
docker build -t academy .
```

**Step 5**: Run the container

```sh
docker run --name academy -e POSTGRES\_PASSWORD=password -d academy
```
