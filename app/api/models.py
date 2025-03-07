from sqlalchemy import Column, Integer, String, ForeignKey, Date, DECIMAL, JSON  #type: ignore
from sqlalchemy.orm import relationship  #type: ignore
from database import Base


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)

class Client(Base):
    __tablename__ = "clients"
    client_id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    email = Column(String, nullable=True)

class Order(Base):
    __tablename__ = "orders"
    order_id = Column(Integer, primary_key=True, index=True)
    creation_date = Column(Date, nullable=False)
    completion_date = Column(Date, nullable=True)
    status = Column(String, nullable=False)
    total_cost = Column(DECIMAL, nullable=True)
    client_id = Column(Integer, ForeignKey("clients.client_id"), nullable=False)
    employee_id = Column(Integer, ForeignKey("employees.employee_id"), nullable=True)

    client = relationship("Client")
    employee = relationship("Employee")

class Employee(Base):
    __tablename__ = "employees"
    employee_id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    position = Column(String, nullable=False)
    phone = Column(String, nullable=False)

class Material(Base):
    __tablename__ = "materials"
    material_id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    quantity = Column(Integer, nullable=True)
    price = Column(DECIMAL, nullable=True)

class Service(Base):
    __tablename__ = "services"
    service_id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    base_cost = Column(DECIMAL, nullable=True)

class Payment(Base):
    __tablename__ = "payments"
    payment_id = Column(Integer, primary_key=True, index=True)
    amount = Column(DECIMAL, nullable=True)
    payment_date = Column(Date, nullable=False)
    status = Column(String, nullable=False)
    order_id = Column(Integer, ForeignKey("orders.order_id"), nullable=False)
    service_id = Column(Integer, ForeignKey("services.service_id"), nullable=False)

    order = relationship("Order")
    service = relationship("Service") 

class Report(Base):
    __tablename__ = "reports"
    report_id = Column(Integer, primary_key=True, index=True)
    creation_date = Column(Date, nullable=False)
    report_type = Column(String, nullable=False)
    data = Column(JSON, nullable=True)  # Можно использовать JSON
    order_id = Column(Integer, ForeignKey("orders.order_id"), nullable=False)
    material_id = Column(Integer, ForeignKey("materials.material_id"), nullable=True) 

    order = relationship("Order")  
    material = relationship("Material") 

class OrderMaterial(Base):
    __tablename__ = "order_materials"
    order_id = Column(Integer, ForeignKey("orders.order_id"), primary_key=True)
    material_id = Column(Integer, ForeignKey("materials.material_id"), primary_key=True)
    quantity = Column(Integer, nullable=False)

    order = relationship("Order")  
    material = relationship("Material") 

class OrderService(Base):
    __tablename__ = "order_services"
    order_id = Column(Integer, ForeignKey("orders.order_id"), primary_key=True)
    service_id = Column(Integer, ForeignKey("services.service_id"), primary_key=True)

    order = relationship("Order") 
    service = relationship("Service") 
