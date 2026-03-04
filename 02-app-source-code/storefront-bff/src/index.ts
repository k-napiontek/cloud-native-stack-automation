import express, { type Request, type Response } from "express";
import axios from "axios";
import cors from "cors";
import * as os from "os";
import { performance } from "perf_hooks";
import crypto from "crypto";

const app = express();
const PORT = process.env.PORT || 8080;

const CATALOG_SERVICE_URL =
  process.env.CATALOG_SERVICE_URL || "http://localhost:8081";
const INVENTORY_SERVICE_URL =
  process.env.INVENTORY_SERVICE_URL || "http://localhost:8082";

const bffMeta = {
  service: "storefront-bff",
  podName: os.hostname(),
  version: process.env.APP_VERSION || "v1.0.0",
};

app.use(cors());
app.use(express.json());

app.get("/api/storefront/products/:id", async (req: Request, res: Response) => {
  const productId = req.params.id;
  const traceId = `trace-${crypto.randomBytes(4).toString("hex")}`;

  const startCatalog = performance.now();
  const catalogResult = await axios
    .get(`${CATALOG_SERVICE_URL}/api/products/${productId}`)
    .catch((e) => e.response || e);
  const catalogLatency = Math.round(performance.now() - startCatalog);

  const startInventory = performance.now();
  const inventoryResult = await axios
    .get(`${INVENTORY_SERVICE_URL}/api/inventory/${productId}`)
    .catch((e) => e.response || e);
  const inventoryLatency = Math.round(performance.now() - startInventory);

  const catalogData = catalogResult.data || {};
  const inventoryData = inventoryResult.data || {};

  res.json({
    data: {
      product: catalogData.item || { name: "Product loading error", price: 0 },
      stock:
        inventoryData.stockCount !== undefined
          ? inventoryData.stockCount
          : "Unknown",
    },
    architectureMetrics: {
      traceId: traceId,
      bff: bffMeta,
      downstream: [
        {
          service: "catalog-service",
          status: catalogResult.status === 200 ? "SUCCESS" : "FAILED",
          podName: catalogData._meta?.podName || "unknown",
          version: catalogData._meta?.version || "unknown",
          latencyMs: catalogLatency,
        },
        {
          service: "inventory-service",
          status: inventoryResult.status === 200 ? "SUCCESS" : "FAILED",
          podName: inventoryData._meta?.podName || "unknown",
          version: inventoryData._meta?.version || "unknown",
          latencyMs: inventoryLatency,
        },
      ],
    },
  });
});

if (process.env.NODE_ENV !== "test") {
  app.listen(PORT, () => console.log(`BFF running on port ${PORT}`));
}

export { app };
