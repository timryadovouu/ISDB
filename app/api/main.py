from fastapi import FastAPI, Depends, HTTPException, status, Request, Query  # type: ignore
from fastapi.security import OAuth2PasswordRequestForm  # type: ignore
from fastapi.responses import HTMLResponse, RedirectResponse  # type: ignore
from fastapi.staticfiles import StaticFiles  # type: ignore
from fastapi.templating import Jinja2Templates  # type: ignore
from sqlalchemy.orm import Session, joinedload  # type: ignore
from sqlalchemy.exc import SQLAlchemyError  # type: ignore
from sqlalchemy import text  # type: ignore
from fastapi.middleware.cors import CORSMiddleware  # type: ignore
from typing import List, Optional, Dict, Any
from decimal import Decimal
import logging

from database import engine, Base, get_db
from schemas import UserCreate, Token, UserResponse
from utils import verify_password, get_password_hash
from auth import create_access_token, get_current_user
from models import User, Client, Order, Employee, Material, Service, Payment, Report, OrderMaterial, OrderService
from schemas import ClientResponse, OrderResponse, EmployeeResponse, MaterialResponse, ServiceResponse, PaymentResponse, ReportResponse, OrderMaterialResponse, OrderServiceResponse, PaginatedResponse
import models


# create app
app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

# create database tables
Base.metadata.create_all(bind=engine)

# create logger
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===================================== CONST  =====================================
PRIMARY_KEYS = {
    "clients": "client_id",
    "orders": "order_id",
    "employees": "employee_id",
    "materials": "material_id",
    "services": "service_id",
    "payments": "payment_id",
    "reports": "report_id",
    "order_materials": ["order_id", "material_id"],
    "order_services": ["order_id", "service_id"]
}

MODELS_MAPPING = {
    "clients": Client,
    "orders": Order,
    "employees": Employee,
    "materials": Material,
    "services": Service,
    "payments": Payment,
    "reports": Report,
    "order_materials": OrderMaterial,
    "order_services": OrderService,
}

SCHEMAS_MAPPING = {
    "clients": ClientResponse,
    "orders": OrderResponse,
    "employees": EmployeeResponse,
    "materials": MaterialResponse,
    "services": ServiceResponse,
    "payments": PaymentResponse,
    "reports": ReportResponse,
    "order_materials": OrderMaterialResponse,
    "order_services": OrderServiceResponse,
}

# ===================================== LOGIN LOGIC =====================================
@app.get("/login", response_class=HTMLResponse)
async def login_page(request: Request):
    return templates.TemplateResponse(request=request, name="login.html", context={"request": request})

@app.post("/login/", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == form_data.username).first()
    
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # generate JWT token for authentication
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}

# ===================================== REGISTRATION LOGIC =====================================
@app.get("/register", response_class=HTMLResponse)
async def register_page(request: Request):
    return templates.TemplateResponse(request=request, name="register.html", context={"request": request})

@app.post("/register/", response_model=Token)
def register(user: UserCreate, db: Session = Depends(get_db)):
    # check if user already exists
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # hash the password and create the user
    hashed_password = get_password_hash(user.password)
    new_user = User(email=user.email, hashed_password=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # generate JWT token
    access_token = create_access_token(data={"sub": new_user.email})
    return {"access_token": access_token, "token_type": "bearer"}

# ===================================== TABLES LOGIC =====================================
@app.get("/tables", response_class=HTMLResponse)
async def tables_page(request: Request):
    return templates.TemplateResponse(request=request, name="tables.html", context={"request": request})

@app.get("/tables/{table_name}", response_class=HTMLResponse)
async def table_page(request: Request, table_name: str):
    return templates.TemplateResponse("table.html", {"request": request, "table_name": table_name})

# ===================================== API TABLES LOGIC =====================================
@app.get("/api/tables")
def get_available_tables():
    return {
        "tables": [
            "clients", "orders", "employees", "materials",
            "services", "payments", "reports", 
            "order_materials", "order_services"
        ]
    }

@app.get("/api/tables/{table_name}", response_model=PaginatedResponse)
def get_table_data(table_name: str, db: Session = Depends(get_db)):
    try:
        model = MODELS_MAPPING.get(table_name)
        if not model:
            raise HTTPException(status_code=404, detail="Table not found")
        if table_name == "clients":
            data = db.query(model).order_by(model.client_id).all()
        elif table_name == "orders":
            data = db.query(model).order_by(model.order_id).all()
        elif table_name == "employees":
            data = db.query(model).order_by(model.employee_id).all()
        elif table_name == "materials":
            data = db.query(model).order_by(model.material_id).all()
        elif table_name == "services":
            data = db.query(model).order_by(model.service_id).all()
        elif table_name == "payments":
            data = db.query(model).order_by(model.payment_id).all()
        else:
            data = db.query(model).all()
        total_count = db.query(model).count()        
        schema = SCHEMAS_MAPPING[table_name]
        serialized_data = [schema.from_orm(item) for item in data]
        
        return {"data": serialized_data, "totalCount": total_count}

    except AttributeError:
        raise HTTPException(status_code=404, detail="Table not found")
    except Exception as e:
        logger.error(f"exception: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))
    
# ===================================== CREATE & UPDATE & DELETE =====================================
@app.post("/api/tables/{table_name}")
def add_row(table_name: str, data: dict, db: Session = Depends(get_db)):
    try:
        model = MODELS_MAPPING.get(table_name)
        if not model:
            raise HTTPException(status_code=404, detail="Table not found")
        
        new_row = model(**data)
        db.add(new_row)
        db.commit()
        db.refresh(new_row)
        return {"message": "Row added successfully"}
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e._message))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")

@app.patch("/api/tables/{table_name}/{row_id}")
def update_row(table_name: str, row_id: str, data: dict, db: Session = Depends(get_db)):
    try:
        model = MODELS_MAPPING.get(table_name)
        if not model:
            raise HTTPException(status_code=404, detail="Table not found")
        
        pk = PRIMARY_KEYS.get(table_name)
        
        # Обработка составных ключей
        if isinstance(pk, list):
            key_parts = row_id.split('-')
            if len(key_parts) != len(pk):
                raise HTTPException(status_code=400, detail="Invalid composite key")
            
            filters = [getattr(model, pk[i]) == key_parts[i] for i in range(len(pk))]
        else:
            filters = [getattr(model, pk) == row_id]

        row = db.query(model).filter(*filters).first()
        
        if not row:
            raise HTTPException(status_code=404, detail="Row not found")

        for key, value in data.items():
            if hasattr(model, key):
                setattr(row, key, value)
            else:
                raise HTTPException(status_code=400, detail=f"Invalid field: {key}")

        db.commit()
        return {"message": "Row updated successfully"}
    
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")

@app.delete("/api/tables/{table_name}/{row_id}")
def delete_row(table_name: str, row_id: int, db: Session = Depends(get_db)):
    try:
        model = MODELS_MAPPING.get(table_name)
        if not model:
            raise HTTPException(status_code=404, detail="Table not found")
        
        pk = PRIMARY_KEYS.get(table_name)
        if not pk:
            raise HTTPException(status_code=400, detail="Invalid table")
        
        row = db.query(model).filter(getattr(model, pk) == row_id).first()
        if not row:
            raise HTTPException(status_code=404, detail="Row not found")
        
        db.delete(row)
        db.commit()
        return {"message": "Row deleted successfully"}
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e._message))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")
    
# ===================================== ANOTHER LOGIC =====================================
@app.get("/home", response_class=HTMLResponse)
async def read_root(request: Request):
    # return {"message": "Welcome to the FastAPI Auth Demo"}
    return templates.TemplateResponse(request=request, name="home.html", context={"request": request})

@app.get("/")
def redirect_to_home():
    # redirect
    return RedirectResponse(url="/home", status_code=301)

# Protected route to check JWT token validity
@app.get("/me", response_model=UserResponse)
def access_cabinet(current_user: User = Depends(get_current_user)):
    return {"message": f"Welcome to your cabinet, {current_user.email}!", "user": current_user}