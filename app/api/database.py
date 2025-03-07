from sqlalchemy import create_engine  #type: ignore
from sqlalchemy.ext.declarative import declarative_base  #type: ignore
from sqlalchemy.orm import sessionmaker  #type: ignore
import os

DATABASE_URL = os.getenv("DATABASE_URL", f"postgresql://${os.getenv("POSTGRES_USER")}:${os.getenv("POSTGRES_PASSWORD")}@db:5432/${os.getenv("POSTGRES_DB")}")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()