from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy", "service": "LLM Router active"}

# def test_health_check():
#     response = client.get("/health")
#     assert response.status_code == 200
#     assert response.json()["status"] == "ok"

# def test_route_query_finance():
#     response = client.post("/route-query?query=Tell me about the bank rates")
#     assert response.status_code == 200
#     assert response.json()["routed_to"] == "fin-bert-v2"