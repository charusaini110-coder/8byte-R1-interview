from fastapi import FastAPI
import os

app = FastAPI(title="8byte LLM Router API", version="1.0.0")

@app.get("/")
def read_root():
    return {"status": "healthy", "service": "LLM Router active"}