from fastapi.testclient import TestClient
from main import app  

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    
    assert response.status_code == 200
    assert response.json()["status"] == "UP"
    assert "pod" in response.json()

def test_get_product_success():
    response = client.get("/api/products/1")
    
    assert response.status_code == 200
    data = response.json()
    assert data["item"]["name"] == "Nike Air Max 90"
    assert data["item"]["price"] == 120.99
    assert data["_meta"]["service"] == "catalog-service"

def test_get_product_not_found():
    response = client.get("/api/products/999")
    
    assert response.status_code == 404
    assert response.json() == {"detail": "Product not found"}