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
