## Задание № 2 

**Задание 1-2**: Создание нового образа на основе официального образа postgres с DockerHub (см. Dockerfile)

```sh
docker build -t academy .

docker run --name academy -e POSTGRES_PASSWORD=password -d academy
```

**Step 3**: Create the init.sql file. In the future we will use it to 
make whole `academy` database.

**Step 4**: Build the image


**Step 5**: Run the container


Use the following command to connect to database in interactive mode:

```sh
docker exec -it academy psql -U user -d academy
```

### Academy database

> If you open the init.sql file you can see the whole script creating 
`academy` database :smile:
