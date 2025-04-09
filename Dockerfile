FROM postgres
ENV POSTGRES_DB=academy
ENV POSTGRES_USER=user
COPY 0_init.sql 1_add_some.sql /docker-entrypoint-initdb.d/
