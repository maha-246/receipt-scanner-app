"""
Purpose of main.py: Connect FastAPI to my database and expose my CRUD operations to the API routes

main.py is basically the entry path to my backend. It does the following:
1. Creating FastAPI app
2. Creating database tables
3. Defining API routes
4. Connecting routes to CRUD operations

Imports:
1. FastAPI - to create app
2 Depends - for dependency injection so in our app, it tells FastAPI to give this route a db
  session from get_db
3. HTTPExceptions - to handle API errors, like if document not found, it will return 404 error
4. Session - to import db session
5. Base - to import the parent class used by my models
6. Engine - to import the db connection manager
7. get_db - this  is the function that creates and closes db sessions per request

APP Routes:
1. GET / -> simple root message
2. GET /health -> health check
3. POST /documents -> Create document
4. GET /documents -> read many docs
5. PUT /documents/{id} -> update by id
6. DELETE /documents/{id} -> delete by id

To run:
1. Bash -> uvicorn app.main:app --reload
2. Open -> http://127.0.0.1:8000/docs
"""

from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import Base, engine, get_db
from app import schemas, crud

# Make tables for all models connected to base if their tables doesn't exists in db
Base.metadata.create_all(bind=engine)

# Create the Fast API App
# app is a server backend object
app = FastAPI(title="Receipt Tracker API")

# this is root route
# run this function if someone sends a get request 
# FastAPI automatically convets the dictionary into a JSON 
@app.get("/")
def root():
    return {"message":"Receipt Tracker API is running" }

# common backend route to check if server is running and alive
@app.get("/health")
def health():
    return {"status": "ok"}

# Run this function when client sends POST request and response should follow strcuture of DocumentOut schema
# The request body must martch DocumentCreate schema
# FastAPI needs to call get_db() to create and close sessions per request
# we send the db session and validated payload into the crud operation
@app.post("/documents", response_model = schemas.DocumentOut)
def create_document(payload: schemas.DocumentCreate, db: Session = Depends(get_db)):
    return crud.create_document(db, payload)

# Run this function when client wants to read multiple documentss
@app.get("/documents", response_model = list[schemas.DocumentOut])
def get_documents(db: Session = Depends(get_db), limit: int = 50):
    return crud.list_documents(db,limit=limit)

# Run funtion when client wants  to update document
# This function calls crud operations, store the result and if doc found, updates doc. 
@app.put("/documents/{document_id}", response_model=schemas.DocumentUpdate)
def update_document(
    document_id: int,
    payload: schemas.DocumentUpdate,
    db: Session = Depends(get_db)
):
    doc = crud.update_document(db, document_id, payload)
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    
    return doc

# Run function to delete document by id
@app.delete("/documents/{document_id}")
def delete_document(document_id: int, db: Session = Depends(get_db)):
    doc = crud.delete_document(db, document_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    
    return {"message": f"Document {document_id} successfully deleted"}

