-- Индексы для таблицы "Заказы"
CREATE INDEX idx_orders_client_id ON public.orders(client_id);

-- Индексы для таблицы "Оплаты"
CREATE INDEX idx_payments_order_id ON public.payments(order_id);

-- Индексы для таблицы "Отчеты"
CREATE INDEX idx_reports_order_id ON public.reports(order_id);
