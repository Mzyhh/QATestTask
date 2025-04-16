FROM postgres
ENV POSTGRES_DB=academy
ENV POSTGRES_USER=user
COPY scripts/0_init.sql /docker-entrypoint-initdb.d/
COPY sripts/*.sql /home/script/
