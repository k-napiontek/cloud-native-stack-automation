import os

from fastapi import FastAPI, HTTPException

app = FastAPI(title="Catalog Service")

POD_NAME = os.getenv("HOSTNAME", "python-local-dev")
APP_VERSION = os.getenv("APP_VERSION", "v1.2.0")

PRODUCTS_DB = {
    "1": {"id": 1, "name": "Nike Air Max 90", "price": 120.99},
    "2": {"id": 2, "name": "Adidas Ultraboost", "price": 180.00},
}


@app.get("/health")
def health_check():
    return {"status": "UP", "pod": POD_NAME}


@app.get("/api/products/{product_id}")
def get_product(product_id: str):
    product = PRODUCTS_DB.get(product_id)

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    return {
        "item": product,
        "_meta": {
            "service": "catalog-service",
            "podName": POD_NAME,
            "version": APP_VERSION,
            "language": "Python 3/FastAPI",
        },
    }
