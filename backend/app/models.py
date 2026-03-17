# Importing important imports
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.database import Base

# Creating python class/model named Document
class Document(Base):

    # Defining table name
    __tablename__ = "documents"

    # Defining table columns
    id = Column(Integer, primary_key = True, index = True)
    image_path = Column(String, nullable = True)
    doc_type = Column(String, default = "receipt")
    merchant_name = Column(String, nullable = True)
    doc_date  = Column(String, nullable = True)
    total_amount = Column(String, nullable = True)
    currency = Column(String, default = "USD")
    raw_text = Column(String, nullable = True)
    created_at = Column(DateTime, default = lambda: datetime.now(timezone.utc))
    items = relationship("LineItem", back_populates = "document", cascade = "all, delete-orphan")

class LineItem(Base):
    __tablename__ = "line_items"

    id = Column(Integer, primary_key = True, index = True)
    document_id = Column(Integer, ForeignKey("documents.id"), nullable= False)
    item_name = Column(String, nullable = False)
    item_price = Column(Float, nullable = True)

    # Document has items and items belong to document
    document = relationship("Document", back_populates="items")
    


