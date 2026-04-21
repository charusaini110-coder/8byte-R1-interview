from fastapi import FastAPI, Header, HTTPException
import os

app = FastAPI(title="8byte LLM Router API", version="1.0.0")

# Simulating the DB connection string provided by Terraform/EC2 environment
# DB_USER = os.getenv("DB_USERNAME", "default_user")
# DB_HOST = os.getenv("DB_HOST", "localhost")

@app.get("/")
def read_root():
    return {"status": "healthy", "service": "LLM Router active"}