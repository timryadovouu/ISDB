CREATE DATABASE repair_workshop
WITH
OWNER = postgres
ENCODING = 'UTF8'
TABLESPACE = pg_default
CONNECTION LIMIT = -1
IS_TEMPLATE = False;

--=====================================================================================================
-- Таблица "Клиенты"
CREATE TABLE IF NOT EXISTS public.clients (
    client_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(50) UNIQUE
);

-- Таблица "Заказы"
CREATE TABLE IF NOT EXISTS public.orders (
    order_id SERIAL PRIMARY KEY,
    creation_date DATE NOT NULL,
    completion_date DATE,
    status VARCHAR(50) CHECK (status IN ('Новый', 'В процессе', 'Завершен', 'Отменен')) NOT NULL,
    total_cost NUMERIC(10, 2) CHECK (total_cost >= 0),
    client_id INTEGER REFERENCES clients(client_id) ON DELETE CASCADE
);

-- Таблица "Сотрудники"
CREATE TABLE IF NOT EXISTS public.employees (
    employee_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    position VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL
);

-- Таблица "Материалы"
CREATE TABLE IF NOT EXISTS public.materials (
    material_id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    quantity INTEGER CHECK (quantity >= 0),
    price NUMERIC(10, 2) CHECK (price >= 0)
);

-- Таблица "Услуги"
CREATE TABLE IF NOT EXISTS public.services (
    service_id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    base_cost NUMERIC(10, 2) CHECK (base_cost >= 0)
);

-- Таблица "Оплаты"
CREATE TABLE IF NOT EXISTS public.payments (
    payment_id SERIAL PRIMARY KEY,
    amount NUMERIC(10, 2) CHECK (amount >= 0),
    payment_date DATE NOT NULL,
    status VARCHAR(50) CHECK (status IN ('Оплачено', 'Частично оплачено', 'Не оплачено')) NOT NULL,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE
);

-- Таблица "Отчеты"
CREATE TABLE IF NOT EXISTS public.reports (
    report_id SERIAL PRIMARY KEY,
    creation_date DATE NOT NULL,
    report_type VARCHAR(100) NOT NULL,
    data JSONB,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE
);

-- Таблица "Материалы заказа"
CREATE TABLE IF NOT EXISTS public.order_materials (
    order_id INTEGER REFERENCES public.orders(order_id) ON DELETE CASCADE,
    material_id INTEGER REFERENCES public.materials(material_id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, material_id)
);

-- Таблица "Услуги заказа"
CREATE TABLE IF NOT EXISTS public.order_services (
    order_id INT REFERENCES public.orders(order_id) ON DELETE CASCADE,
    service_id INT REFERENCES public.services(service_id) ON DELETE CASCADE,
    PRIMARY KEY (order_id, service_id)
);

--=====================================================================================================
-- reports
ALTER TABLE public.reports 
ADD COLUMN material_id INT;

ALTER TABLE public.reports 
ADD CONSTRAINT fk_material FOREIGN KEY (material_id)
REFERENCES public.materials(material_id) 
ON DELETE SET NULL;

-- payments
ALTER TABLE public.payments 
ADD COLUMN service_id INT;

ALTER TABLE public.payments 
ADD CONSTRAINT fk_service FOREIGN KEY (service_id) 
REFERENCES public.services(service_id) 
ON DELETE SET NULL;

-- orders
ALTER TABLE public.orders 
ADD COLUMN employee_id INT;

ALTER TABLE public.orders 
ADD CONSTRAINT fk_employee FOREIGN KEY (employee_id) 
REFERENCES public.employees(employee_id) 
ON DELETE SET NULL;

--=====================================================================================================
-- Индексы для таблицы "Заказы"
CREATE INDEX idx_orders_client_id ON public.orders(client_id);

-- Индексы для таблицы "Оплаты"
CREATE INDEX idx_payments_order_id ON public.payments(order_id);

-- Индексы для таблицы "Отчеты"
CREATE INDEX idx_reports_order_id ON public.reports(order_id);

--=====================================================================================================
-- Клиенты (10 записей)
INSERT INTO public.clients (full_name, phone, email) VALUES
('Иванов Иван Иванович', '+79111234567', 'ivanov@mail.ru'),
('Петров Петр Петрович', '+79119876543', 'petrov@gmail.com'),
('Сидорова Анна Сергеевна', '+79112345678', 'sidorova@yandex.ru'),
('Васильев Василий Васильевич', '+79119871234', 'vasiliev@mail.ru'),
('Кузнецова Ольга Николаевна', '+79117654321', 'kuznetsova@bk.ru'),
('Смирнов Алексей Владимирович', '+79114567890', 'smirnov@outlook.com'),
('Андреев Андрей Андреевич', '+79115678901', 'andreev@gmail.com'),
('Морозова Марина Павловна', '+79113456789', 'morozova@yandex.ru'),
('Григорьев Григорий Григорьевич', '+79112349876', 'grigoriev@mail.ru'),
('Федорова Дарья Викторовна', '+79119875432', 'fedorova@bk.ru');

-- Сотрудники (10 записей)
INSERT INTO public.employees (full_name, position, phone) VALUES
('Смирнов Алексей Владимирович', 'Мастер', '+79111234569'),
('Кузнецова Ольга Ивановна', 'Кладовщик', '+79111234570'),
('Васильев Дмитрий Сергеевич', 'Администратор', '+79111234571'),
('Морозов Павел Игоревич', 'Инженер', '+79111234572'),
('Тимофеев Артем Викторович', 'Сервисный специалист', '+79111234573'),
('Борисова Наталья Петровна', 'Бухгалтер', '+79111234574'),
('Капустин Виктор Александрович', 'Мастер', '+79111234575'),
('Семенова Екатерина Алексеевна', 'Кладовщик', '+79111234576'),
('Егоров Николай Олегович', 'Инженер', '+79111234577'),
('Фролова Ирина Владимировна', 'Оператор', '+79111234578');

-- Заказы (10 записей)
INSERT INTO public.orders (creation_date, completion_date, status, total_cost, client_id, employee_id) VALUES
('2024-01-01', '2024-01-10', 'Завершен', 5000.00, 1, 1),
('2024-01-05', NULL, 'В процессе', 3000.00, 2, 2),
('2024-01-10', NULL, 'Новый', 2000.00, 3, 3),
('2024-02-01', NULL, 'Новый', 4000.00, 4, 4),
('2024-02-05', '2024-02-15', 'Завершен', 3500.00, 5, 5),
('2024-02-10', NULL, 'В процессе', 2500.00, 6, 6),
('2024-02-15', NULL, 'Новый', 1500.00, 7, 7),
('2024-02-20', NULL, 'Новый', 1800.00, 8, 8),
('2024-02-25', '2024-03-01', 'Завершен', 5000.00, 9, 9),
('2024-03-01', NULL, 'В процессе', 2200.00, 10, 10);

-- Материалы (10 записей)
INSERT INTO public.materials (name, quantity, price) VALUES
('Винты', 100, 10.00),
('Гайки', 200, 5.00),
('Шурупы', 150, 8.00),
('Провода', 300, 15.00),
('Платы', 50, 500.00),
('Разъемы', 120, 20.00),
('Клей', 75, 25.00),
('Термопаста', 100, 50.00),
('Чипы', 30, 700.00),
('Конденсаторы', 500, 2.00);

-- Услуги (10 записей)
INSERT INTO public.services (name, base_cost) VALUES
('Ремонт компьютера', 1000.00),
('Замена жесткого диска', 500.00),
('Установка программного обеспечения', 300.00),
('Чистка ноутбука', 700.00),
('Диагностика', 400.00),
('Замена термопасты', 600.00),
('Настройка сети', 800.00),
('Ремонт блока питания', 1200.00),
('Замена экрана', 2500.00),
('Перепайка компонентов', 1800.00);

-- Оплаты (10 записей)
INSERT INTO public.payments (amount, payment_date, status, order_id, service_id) VALUES
(5000.00, '2024-01-10', 'Оплачено', 1, 1),
(1500.00, '2024-01-06', 'Частично оплачено', 2, 2),
(3500.00, '2024-02-15', 'Оплачено', 5, 3),
(1000.00, '2024-02-16', 'Частично оплачено', 6, 4),
(1800.00, '2024-02-26', 'Оплачено', 9, 5),
(1200.00, '2024-03-01', 'Оплачено', 10, 6),
(3000.00, '2024-02-21', 'Оплачено', 8, 7),
(700.00, '2024-02-22', 'Частично оплачено', 7, 8),
(2500.00, '2024-02-28', 'Оплачено', 4, 9),
(600.00, '2024-02-27', 'Частично оплачено', 3, 10);

-- Отчеты (10 записей)
INSERT INTO public.reports (creation_date, report_type, data, order_id, material_id) VALUES
('2024-01-10', 'Финансовый отчет', '{"total_cost": 5000, "paid": 5000}', 1, 1),
('2024-01-06', 'Отчет по материалам', '{"materials_used": ["Винты", "Гайки"]}', 2, 2),
('2024-02-15', 'Финансовый отчет', '{"total_cost": 3500, "paid": 3500}', 5, 3),
('2024-02-16', 'Отчет по материалам', '{"materials_used": ["Шурупы"]}', 6, 4),
('2024-02-20', 'Финансовый отчет', '{"total_cost": 1800, "paid": 1800}', 8, 5),
('2024-02-22', 'Отчет по материалам', '{"materials_used": ["Провода", "Клей"]}', 7, 6),
('2024-02-25', 'Финансовый отчет', '{"total_cost": 5000, "paid": 5000}', 9, 7),
('2024-02-27', 'Отчет по материалам', '{"materials_used": ["Термопаста"]}', 3, 8),
('2024-02-28', 'Финансовый отчет', '{"total_cost": 2500, "paid": 2500}', 4, 9),
('2024-03-01', 'Финансовый отчет', '{"total_cost": 2200, "paid": 2200}', 10, 10);

-- Связь заказов и материалов
INSERT INTO public.order_materials (order_id, material_id, quantity) VALUES
(1, 1, 10),
(1, 2, 20),
(2, 3, 15),
(2, 4, 10),
(3, 5, 2),
(4, 6, 5),
(5, 7, 3),
(6, 8, 4),
(7, 9, 1),
(8, 10, 50),
(9, 1, 10),
(9, 3, 12),
(10, 2, 5),
(10, 5, 3);

-- Связь заказов и услуг
INSERT INTO public.order_services (order_id, service_id) VALUES
(1, 1), 
(1, 2), 
(2, 3), 
(2, 4),  
(3, 5),  
(4, 6),
(5, 7), 
(6, 8), 
(7, 9),  
(8, 10),
(9, 1),  
(9, 3), 
(10, 2), 
(10, 4);

--=====================================================================================================
-- view 1
CREATE VIEW public.current_orders AS
SELECT 
    o.order_id,
    o.status,
    c.full_name AS client_name,
    o.creation_date,
    o.total_cost
FROM public.orders o
JOIN public.clients c ON o.client_id = c.client_id
WHERE o.status NOT IN ('Завершен', 'Отменен'); -- only active orders

-- view 2 
CREATE VIEW public.material_reports AS
SELECT 
    m.name AS material_name,
    m.material_id AS material_id,
    m.quantity AS stock_quantity,
    m.price AS unit_price,
    COALESCE(SUM(om.quantity), 0) AS used_in_orders
FROM public.materials m
LEFT JOIN public.order_materials om ON m.material_id = om.material_id
GROUP BY m.material_id;

-- view 3 
CREATE VIEW public.master_tasks AS
SELECT 
    o.order_id,
    c.full_name AS client_name,
    STRING_AGG(DISTINCT s.name, ', ') AS service_list,
    STRING_AGG(DISTINCT m.name, ', ') AS material_list
FROM public.orders o
JOIN public.clients c ON o.client_id = c.client_id
LEFT JOIN public.order_services os ON o.order_id = os.order_id
LEFT JOIN public.services s ON os.service_id = s.service_id
LEFT JOIN public.order_materials om ON o.order_id = om.order_id
LEFT JOIN public.materials m ON om.material_id = m.material_id
GROUP BY o.order_id, c.full_name;

-- view 4
CREATE VIEW public.completed_work_reports AS
SELECT 
    o.order_id,
    e.full_name AS employee_name,
    o.completion_date,
    STRING_AGG(DISTINCT m.name, ', ') AS used_materials
FROM public.orders o
JOIN public.employees e ON o.employee_id = e.employee_id
LEFT JOIN public.order_materials om ON o.order_id = om.order_id
LEFT JOIN public.materials m ON om.material_id = m.material_id
WHERE o.status = 'Завершен'
GROUP BY o.order_id, e.full_name, o.completion_date;

--=====================================================================================================
CREATE TABLE public.main_log (
    log_item_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation_type VARCHAR(30) NOT NULL,
    operation_date TIMESTAMP,
    user_operator VARCHAR(30) NOT NULL,
    changed_data JSONB
);

CREATE OR REPLACE FUNCTION logging() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.main_log (table_name, operation_type, operation_date, user_operator, changed_data)
    VALUES (
        TG_TABLE_NAME,
        TG_OP,
        NOW(),  
        current_user,
        row_to_json(CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END)
    );
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$ LANGUAGE plpgsql;

-- Триггер для таблицы "Заказы"
CREATE TRIGGER logging_orders
AFTER INSERT OR UPDATE OR DELETE ON public.orders
FOR EACH ROW EXECUTE FUNCTION logging();

-- Триггер для таблицы "Клиенты"
CREATE TRIGGER logging_clients
AFTER INSERT OR UPDATE OR DELETE ON public.clients
FOR EACH ROW EXECUTE FUNCTION logging();

-- Триггер для таблицы "Сотрудники"
CREATE TRIGGER logging_employees
AFTER INSERT OR UPDATE OR DELETE ON public.employees
FOR EACH ROW EXECUTE FUNCTION logging();

-- Вставка данных в таблицу "Заказы"
INSERT INTO public.orders (creation_date, completion_date, status, total_cost, client_id, employee_id)
VALUES ('2024-02-02', NULL, 'Новый', 2500.00, 1, 1);

-- Обновление данных в таблице "Клиенты"
UPDATE public.clients SET email = 'new_email@mail.ru' WHERE client_id = 1;

-- Удаление данных из таблицы "Сотрудники"
DELETE FROM public.employees WHERE employee_id = 1;

-- Проверка таблицы-лога
-- SELECT * FROM public.main_log;

--=====================================================================================================
CREATE TABLE public.secret_data (
    id SERIAL PRIMARY KEY,
    username VARCHAR(30) NOT NULL,
    secret_token BYTEA NOT NULL
);

-- Установка расширения pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Вставка зашифрованных данных
INSERT INTO public.secret_data (username, secret_token)
VALUES (
    'operator_1', pgp_sym_encrypt('token_', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08')
);

-- Проверка зашифрованных данных
-- SELECT * FROM public.secret_data;

-- Попытка расшифровки данных без ключа
-- SELECT pgp_sym_decrypt(secret_token::bytea, 'wrong_key') FROM public.secret_data;

-- SELECT username, 
--        pgp_sym_decrypt(secret_token, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08') AS decrypted_token
-- FROM public.secret_data;

--=====================================================================================================
-- Удаление ролей, если они уже существуют
DROP ROLE IF EXISTS operator_role;
DROP ROLE IF EXISTS master_role;

-- Удаление пользователей, если они уже существуют
DROP ROLE IF EXISTS operator_user;
DROP ROLE IF EXISTS master_user;
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

--=====================================================================================================
-- pg_dump -U postgres -F c -b -v -f backup.dump repair_workshop

-- UPDATE orders SET status = 'Отменен' WHERE order_id = 1;
-- DELETE FROM clients WHERE client_id = 2;

-- psql -U postgres -c "DROP DATABASE repair_workshop;"
-- psql -U postgres -c "CREATE DATABASE repair_workshop;"

-- SELECT * FROM main_log WHERE operation_type IN ('UPDATE', 'DELETE');