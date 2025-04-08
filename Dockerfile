FROM postgres
ENV POSTGRES_DB=academy
ENV POSTGRES_USER=user
COPY init.sql /docker-entrypoint-initdb.d/
