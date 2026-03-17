from sqlalchemy.orm import Session
from app import models, schemas

""" 
This is a function that takes 2 arguements:
db: Session -> this function requires a db session to talk to the database
payload: schemas.DocumentCreate -> expects incoming validated data in same structure as DocumentCreate
-> models.Document is a type hint that return object should be a model object of Document class

The function creates a doc which exists in memory and when data comes into payload, the data is
mapped onto the document to save it into the database. 

In this function, we don't need to manually add primary or foreign keys because relationships
are defined in models and SQLAlchemy understand these line items belong to this document so it 
handles the foreign key for us. 

Payload is a DocumentCreate Object 
"""

def create_document(db: Session, payload: schemas.DocumentCreate) -> models.Document:
    doc = models.Document(
        image_path = payload.image_path,
        doc_type = payload.doc_type,
        merchant_name = payload.merchant_name,
        doc_date = payload.doc_date,
        total_amount = payload.total_amount,
        currency = payload.currency,
        raw_text = payload.raw_text,
    )

    # add items since doc is a list of items
    for it in payload.items:
        doc.items.append(models.LineItem(item_name=it.item_name, item_price=it.item_price))

    db.add(doc)
    db.commit()
    db.refresh(doc)
    return doc

"""
This function reads and returns db data. It tells the system to start the query on the documents table,
sort by document id in descending order and only return at most 50 rows. 
"""

def list_documents(db: Session, limit: int = 50):
    return db.query(models.Document).order_by(models.Document.id.desc()).limit(limit).all()

"""
This function is for updating whole document and lineitems.
1. The doc = db.query() code line looks for id in document table that matches Document.id and returns first match, 
   and in case of no match, returns none. 
2. The next lines update field-by-field. 
3. We clear all old items in the current doc
4. After removing old items, add the new list of items
"""

def update_document(db: Session, document_id: int, payload: schemas.DocumentUpdate):
    doc = db.query(models.Document).filter(models.Document.id == document_id).first()

    if not doc:
        return None

    doc.merchant_name = payload.merchant_name
    doc.doc_date = payload.doc_date
    doc.total_amount = payload.total_amount
    doc.currency = payload.currency
    doc.raw_text = payload.raw_text

    # replace old items with new items
    doc.items.clear()

    for it in payload.items:
        doc.items.append(
            models.LineItem(
                item_name=it.item_name,
                item_price=it.item_price
            )
        )

    db.commit()
    db.refresh(doc)
    return doc

"""The Function to delete document"""

def delete_document(db: Session, document_id: int):
    doc = db.query(models.Document).filter(models.Document.id == document_id).first()

    if not doc:
        return None

    db.delete(doc)
    db.commit()
    return doc