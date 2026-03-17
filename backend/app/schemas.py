# Schemas are for API
#check for framework

from pydantic import BaseModel
from typing import List, Optional

# Class for describing and validating API data
class LineItemCreate(BaseModel):
    item_name : str
    item_price : Optional[float] = None

class DocumentCreate(BaseModel):
    image_path: Optional[str] = None
    doc_type: str = "receipt"
    marchant_name: Optional[str] = None
    doc_date: Optional[str] = None
    total_amount: Optional[float] = None
    currency: str = "USD"
    raw_text: Optional[str] = None

    # items must be a list and each item in the list must match LineItemCreate
    items : List[LineItemCreate] = []

# class for line items coming out from API/database
class LineItemOut(BaseModel):
    id: int
    item_name : str
    item_price : Optional[float] = None

# To give permission to Pylandic to read object attributes
# imp for object serialization
class Config:
    from_attributes: True

class DocumentOut(BaseModel):
    id : int
    marchant_name: Optional[str] = None
    doc_date: Optional[str] = None
    total_amount: Optional[float] = None

    # No default here, output should contain real value
    currency: str 
    items: List[LineItemOut] = []

class Config:
    from_attributes: True

# schemas for update lineitems and document
class LineItemUpdate(BaseModel):
    item_name: str
    item_price: Optional[float] = None


class DocumentUpdate(BaseModel):
    merchant_name: Optional[str] = None
    doc_date: Optional[str] = None
    total_amount: Optional[float] = None
    currency: Optional[str] = None
    raw_text: Optional[str] = None
    items: List[LineItemUpdate] = []









