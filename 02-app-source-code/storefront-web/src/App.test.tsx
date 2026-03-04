import "@testing-library/jest-dom/vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { describe, it, expect, vi, beforeEach } from "vitest";
import App from "./App";

globalThis.fetch = vi.fn();

describe("App Component", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should render loading state initially", () => {
    (globalThis.fetch as any).mockImplementationOnce(
      () => new Promise(() => {}),
    );

    render(<App />);
    expect(screen.getByText("Listening to network...")).toBeInTheDocument();
    expect(screen.getByText("Refreshing...")).toBeInTheDocument();
  });

  it("should render product data and architecture metrics on successful fetch", async () => {
    const mockApiResponse = {
      ok: true,
      json: async () => ({
        data: {
          product: { id: 1, name: "Nike Air Max 90", price: 120.99 },
          stock: 42,
        },
        architectureMetrics: {
          traceId: "trace-1234",
          bff: {
            service: "storefront-bff",
            podName: "bff-pod-1",
            version: "v1.0",
          },
          downstream: [
            {
              service: "catalog-service",
              status: "SUCCESS",
              podName: "catalog-pod-1",
              version: "v1.2",
              latencyMs: 15,
            },
            {
              service: "inventory-service",
              status: "SUCCESS",
              podName: "inventory-pod-1",
              version: "v1.0",
              latencyMs: 12,
            },
          ],
        },
      }),
    };

    (globalThis.fetch as any).mockResolvedValueOnce(mockApiResponse);

    render(<App />);

    await waitFor(() => {
      expect(screen.getByText("Nike Air Max 90")).toBeInTheDocument();
    });

    expect(screen.getByText("$120.99")).toBeInTheDocument();
    expect(screen.getByText("In stock: 42 units")).toBeInTheDocument();

    expect(screen.getByText("Trace ID: trace-1234")).toBeInTheDocument();
    expect(screen.getByText("bff-pod-1")).toBeInTheDocument();
  });

  it("should display error message on API failure", async () => {
    (globalThis.fetch as any).mockRejectedValueOnce(new Error("API is down"));

    render(<App />);

    await waitFor(() => {
      expect(screen.getByText(/Connection Error:/)).toBeInTheDocument();
    });

    expect(screen.getByText("API is down")).toBeInTheDocument();
  });
});
