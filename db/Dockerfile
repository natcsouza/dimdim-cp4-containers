FROM mysql:8.0

# O DDL roda automaticamente na primeira inicializacao do banco.
COPY init/01-ddl.sql /docker-entrypoint-initdb.d/01-ddl.sql

EXPOSE 3306
