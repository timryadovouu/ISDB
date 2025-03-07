-- Роль для операторов
CREATE ROLE operator_role WITH
    NOLOGIN
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    INHERIT;

-- Роль для мастеров
CREATE ROLE master_role WITH
    NOLOGIN
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    INHERIT;

-- Привилегии для операторов
GRANT SELECT, INSERT, UPDATE ON public.orders TO operator_role;
GRANT SELECT ON public.clients TO operator_role;

-- Привилегии для мастеров 
GRANT SELECT, INSERT, UPDATE ON public.employees TO master_role;
GRANT SELECT ON public.materials TO master_role;

-- Пользователь для оператора
CREATE ROLE operator_user WITH LOGIN PASSWORD 'operator_pass';
GRANT operator_role TO operator_user;

-- Пользователь для мастера
CREATE ROLE master_user WITH LOGIN PASSWORD 'master_pass';
GRANT master_role TO master_user;


-- SET ROLE operator_user;
-- SELECT * FROM public.orders;  -- ok
-- SELECT * FROM public.employees;  -- not ok
-- RESET ROLE;
