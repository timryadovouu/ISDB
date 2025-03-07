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
