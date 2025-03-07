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
