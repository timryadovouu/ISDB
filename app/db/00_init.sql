-- CREATE DATABASE repair_workshop
-- WITH
-- OWNER = postgres
-- ENCODING = 'UTF8'
-- TABLESPACE = pg_default
-- CONNECTION LIMIT = -1
-- IS_TEMPLATE = False;

-- DO
-- $$ 
-- BEGIN
--    IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'repair_workshop') THEN
--       CREATE DATABASE repair_workshop
--       WITH
--       OWNER = postgres
--       ENCODING = 'UTF8'
--       TABLESPACE = pg_default
--       CONNECTION LIMIT = -1
--       IS_TEMPLATE = False;
--    END IF;
-- END
-- $$;

-- подключение к БД
-- \c repair_workshop;

-- инициализация таблиц
-- \i /docker-entrypoint-initdb.d/01_init_tables.sql;

-- расширения таблиц
-- \echo 'Starting adjustment of tables'
-- \i /docker-entrypoint-initdb.d/adjust.sql;


-- -- создание индексов
-- \i /docker-entrypoint-initdb.d/indices.sql;

-- -- заполнение таблиц
-- \i /docker-entrypoint-initdb.d/fill_tables.sql;

-- -- создание представлений
-- \i /docker-entrypoint-initdb.d/views.sql;

-- -- создание триггеров
-- \i /docker-entrypoint-initdb.d/triggers.sql;

-- -- создание функций и шифрование
-- \i /docker-entrypoint-initdb.d/encrypt.sql;

-- -- создание ролей
-- \i /docker-entrypoint-initdb.d/roles.sql;