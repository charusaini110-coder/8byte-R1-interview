from fastapi import FastAPI, Header, HTTPException
import os

app = FastAPI(title="8byte LLM Router API", version="1.0.0")

# Simulating the DB connection string provided by Terraform/EC2 environment
DB_USER = os.getenv("DB_USERNAME", "default_user")
DB_HOST = os.getenv("DB_HOST", "localhost")

@app.get("/")
def read_root():
    return {"status": "healthy", "service": "LLM Router active"}

@app.get("/health")
def health_check():
    # A standard health check endpoint for your AWS Application Load Balancer
    return {"status": "ok", "db_configured_for": DB_USER}

@app.post("/route-query")
def route_llm_query(query: str):
    """
    Simulates intelligent routing of a user query to the appropriate LLM
    based on the domain (e.g., Financial Services).
    """
    query_lower = query.lower()
    
    if "finance" in query_lower or "bank" in query_lower:
        routed_model = "fin-bert-v2"
        confidence = 0.98
    else:
        routed_model = "general-gpt-model"
        confidence = 0.75
        
    return {
        "original_query": query,
        "routed_to": routed_model,
        "routing_confidence": confidence,
        "status": "success"
    }