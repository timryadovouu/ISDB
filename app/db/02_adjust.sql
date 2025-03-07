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
