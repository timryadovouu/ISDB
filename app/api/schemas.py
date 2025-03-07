from pydantic import BaseModel  #type: ignore
from typing import List, Optional, Dict, Any, Union
from datetime import date
from decimal import Decimal


# ===================================== USER&TOKEN =====================================
class User(BaseModel):
    email: str

class UserCreate(BaseModel):
    email: str
    password: str

class UserResponse(BaseModel):
    message: str
    user: User

class Token(BaseModel):
    access_token: str
    token_type: str

# ===================================== TABLES =====================================
class ClientResponse(BaseModel):
    client_id: int
    full_name: str
    phone: str
    email: Optional[str] = None

    class Config:
        orm_mode = True
        from_attributes=True

class OrderResponse(BaseModel):
    order_id: int
    creation_date: date
    completion_date: Optional[date] = None
    status: str
    total_cost: Optional[Decimal] = None
    client_id: int

    class Config:
        orm_mode = True
        from_attributes=True

class EmployeeResponse(BaseModel):
    employee_id: int
    full_name: str
    position: str
    phone: str

    class Config:
        orm_mode = True
        from_attributes=True

class MaterialResponse(BaseModel):
    material_id: int
    name: str
    quantity: Optional[int] = None
    price: Optional[Decimal] = None

    class Config:
        orm_mode = True
        from_attributes=True

class ServiceResponse(BaseModel):
    service_id: int
    name: str
    base_cost: Optional[Decimal] = None

    class Config:
        orm_mode = True
        from_attributes=True

class PaymentResponse(BaseModel):
    payment_id: int
    amount: Optional[Decimal] = None
    payment_date: date
    status: str
    order_id: int
    service_id: int

    class Config:
        orm_mode = True
        from_attributes=True

class ReportResponse(BaseModel):
    report_id: int
    creation_date: date
    report_type: str
    data: Optional[dict] = None
    order_id: int
    material_id: int

    class Config:
        orm_mode = True
        from_attributes=True
        json_encoders = {
            date: lambda v: v.isoformat()
        }

class OrderMaterialResponse(BaseModel):
    order_id: int
    material_id: int
    quantity: int

    class Config:
        orm_mode = True
        from_attributes=True

class OrderServiceResponse(BaseModel):
    order_id: int
    service_id: int

    class Config:
        orm_mode = True
        from_attributes=True

class PaginatedResponse(BaseModel):
    data: List[Union[ClientResponse, OrderResponse, EmployeeResponse, MaterialResponse, ServiceResponse, PaymentResponse, ReportResponse, OrderMaterialResponse, OrderServiceResponse]]
    totalCount: int
