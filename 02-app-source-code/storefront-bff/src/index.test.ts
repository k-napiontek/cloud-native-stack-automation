import request from "supertest";
import axios from "axios";
import { app } from "./index";

jest.mock("axios");
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe("Storefront BFF API", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("should return aggregated product and inventory data on success", async () => {
    mockedAxios.get.mockResolvedValueOnce({
      status: 200,
      data: {
        item: { id: "1", name: "Nike Air Max 90", price: 120.99 },
        _meta: { podName: "catalog-pod-1", version: "v1.2.0" },
      },
    });

    mockedAxios.get.mockResolvedValueOnce({
      status: 200,
      data: {
        stockCount: 42,
        _meta: { podName: "inventory-pod-1", version: "v1.0.5" },
      },
    });

    const response = await request(app).get("/api/storefront/products/1");

    expect(response.status).toBe(200);
    expect(response.body.data.product.name).toBe("Nike Air Max 90");
    expect(response.body.data.stock).toBe(42);
    expect(response.body.architectureMetrics.downstream[0].status).toBe(
      "SUCCESS",
    );
    expect(response.body.architectureMetrics.downstream[1].status).toBe(
      "SUCCESS",
    );
  });

  it("should handle downstream failures gracefully (partial degradation)", async () => {
    mockedAxios.get.mockResolvedValueOnce({
      status: 404,
      data: { detail: "Product not found" },
    });

    mockedAxios.get.mockResolvedValueOnce({
      status: 200,
      data: {
        stockCount: 0,
        _meta: { podName: "inventory-pod-1", version: "v1.0.5" },
      },
    });

    const response = await request(app).get("/api/storefront/products/999");

    expect(response.status).toBe(200);
    expect(response.body.data.product.name).toBe("Product loading error");
    expect(response.body.data.stock).toBe(0);
    expect(response.body.architectureMetrics.downstream[0].status).toBe(
      "FAILED",
    );
    expect(response.body.architectureMetrics.downstream[1].status).toBe(
      "SUCCESS",
    );
  });
});
