from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# SQLite DB file will be created in backend/receipts.db
DATABASE_URL = "sqlite:///./receipts.db" 

# connect_args is needed for SQLite when used with FastAPI
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}
)

# SessionLocal is a "factory" that creates DB sessions
SessionLocal = sessionmaker(autocommit= False, autoflush=False, bind=engine)

# Base is the parent class for our ORM models
Base = declarative_base()

def get_db():
    """
    Dependency function:
    Yields a DB session to API routes and ensures it closes after request finishes.
    """

    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()