FROM postgres
ENV POSTGRES_DB=academy
ENV POSTGRES_USER=user
COPY 0_init.sql /docker-entrypoint-initdb.d/
COPY *.sql /home/script/
