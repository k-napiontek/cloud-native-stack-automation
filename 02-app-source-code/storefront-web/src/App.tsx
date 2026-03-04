import { useState, useEffect } from "react";

interface ApiResponse {
  data: {
    product: { id: number; name: string; price: number };
    stock: number | string;
  };
  architectureMetrics: {
    traceId: string;
    bff: { service: string; podName: string; version: string };
    downstream: Array<{
      service: string;
      status: string;
      podName: string;
      version: string;
      error?: string;
    }>;
  };
}

export default function App() {
  const [appData, setAppData] = useState<ApiResponse | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch("/api/storefront/products/1");
      if (!response.ok) throw new Error("Failed to fetch data from BFF");

      const data: ApiResponse = await response.json();
      setAppData(data);
    } catch (err) {
      setError((err as Error).message || "An unknown error occurred");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  return (
    <div className="min-h-screen p-8 text-gray-800 font-sans">
      <div className="max-w-6xl mx-auto">
        <header className="mb-8 flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold">
              E-commerce Store (Demo Architecture)
            </h1>
            <p className="text-gray-500">
              React + Node.js BFF + Microservices EKS
            </p>
          </div>
          <button
            onClick={fetchData}
            className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg shadow transition-colors font-medium"
          >
            {loading ? "Refreshing..." : "Refresh Request"}
          </button>
        </header>

        {error && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
            <strong>Connection Error: </strong> {error}
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <section className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <h2 className="text-xl font-semibold mb-4 text-gray-700 border-b pb-2">
              User View (Frontend)
            </h2>

            {loading && !appData ? (
              <div className="animate-pulse flex flex-col space-y-4">
                <div className="h-64 bg-gray-200 rounded-lg"></div>
                <div className="h-6 bg-gray-200 w-3/4 rounded"></div>
              </div>
            ) : (
              appData && (
                <div className="flex flex-col">
                  <img
                    src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=800"
                    alt="Nike"
                    className="w-full h-64 object-cover rounded-xl mb-6 shadow-sm"
                  />
                  <div className="flex justify-between items-start">
                    <div>
                      <h3 className="text-2xl font-bold">
                        {appData.data.product?.name || "Product not available"}
                      </h3>
                      <p className="text-xl text-gray-600 mt-1">
                        ${appData.data.product?.price || "---"}
                      </p>
                    </div>

                    <div
                      className={`px-4 py-2 rounded-full text-sm font-bold ${
                        appData.data.stock === "Unknown"
                          ? "bg-yellow-100 text-yellow-800"
                          : Number(appData.data.stock) > 0
                            ? "bg-green-100 text-green-800"
                            : "bg-red-100 text-red-800"
                      }`}
                    >
                      {appData.data.stock === "Unknown"
                        ? "Unknown (Failure)"
                        : `In stock: ${appData.data.stock} units`}
                    </div>
                  </div>
                  <button className="mt-8 bg-black text-white py-3 rounded-lg font-bold hover:bg-gray-800 transition">
                    Add to Cart
                  </button>
                </div>
              )
            )}
          </section>

          <section className="bg-slate-900 p-6 rounded-2xl shadow-sm border border-slate-700 text-slate-300">
            <div className="flex justify-between items-center border-b border-slate-700 pb-2 mb-4">
              <h2 className="text-xl font-semibold text-white">
                Architect Console
              </h2>
              {appData && (
                <span className="text-xs font-mono bg-slate-800 text-slate-400 px-2 py-1 rounded">
                  Trace ID: {appData.architectureMetrics.traceId}
                </span>
              )}
            </div>

            {!appData || loading ? (
              <div className="text-slate-500 font-mono text-sm mt-10 text-center animate-pulse">
                Listening to network...
              </div>
            ) : (
              <div className="space-y-6 font-mono text-sm">
                <div className="border border-blue-500/50 bg-blue-900/20 p-4 rounded-lg relative">
                  <span className="absolute -top-3 left-4 bg-blue-600 text-white text-xs px-2 py-1 rounded">
                    BFF (API Gateway)
                  </span>
                  <div className="mt-2 text-blue-200 grid grid-cols-2 gap-2">
                    <div>
                      <span className="text-slate-500">Service:</span>{" "}
                      {appData.architectureMetrics.bff.service}
                    </div>
                    <div>
                      <span className="text-slate-500">Version:</span>{" "}
                      {appData.architectureMetrics.bff.version}
                    </div>
                    <div className="col-span-2">
                      <span className="text-slate-500">Pod ID:</span>{" "}
                      <span className="text-green-400">
                        {appData.architectureMetrics.bff.podName}
                      </span>
                    </div>
                  </div>
                </div>

                <div className="flex justify-center text-slate-600">
                  <svg
                    className="w-6 h-6"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M19 14l-7 7m0 0l-7-7m7 7V3"
                    ></path>
                  </svg>
                </div>

                <div className="grid grid-cols-1 xl:grid-cols-2 gap-4">
                  {appData.architectureMetrics.downstream.map(
                    (service: any, idx: number) => (
                      <div
                        key={idx}
                        className={`border p-4 rounded-lg relative ${
                          service.status === "SUCCESS"
                            ? "border-green-500/50 bg-green-900/10"
                            : "border-red-500/50 bg-red-900/10"
                        }`}
                      >
                        <span
                          className={`absolute -top-3 left-4 text-white text-xs px-2 py-1 rounded flex items-center gap-2 ${
                            service.status === "SUCCESS"
                              ? "bg-green-600"
                              : "bg-red-600"
                          }`}
                        >
                          {service.service}
                        </span>
                        <span
                          className={`absolute -top-3 right-4 text-xs px-2 py-1 rounded-full font-bold ${
                            service.latencyMs < 50
                              ? "bg-green-500/20 text-green-400"
                              : "bg-yellow-500/20 text-yellow-400"
                          }`}
                        >
                          {service.latencyMs} ms
                        </span>

                        <div className="mt-2 text-slate-300 space-y-1">
                          <div>
                            <span className="text-slate-500">Status:</span>
                            <span
                              className={
                                service.status === "SUCCESS"
                                  ? "text-green-400"
                                  : "text-red-400"
                              }
                            >
                              {" "}
                              {service.status}
                            </span>
                          </div>
                          <div className="truncate">
                            <span className="text-slate-500">Pod ID:</span>{" "}
                            <span className="text-yellow-400">
                              {service.podName}
                            </span>
                          </div>
                          <div>
                            <span className="text-slate-500">Version:</span>{" "}
                            {service.version}
                          </div>
                        </div>
                      </div>
                    ),
                  )}
                </div>
              </div>
            )}
          </section>
        </div>
      </div>
    </div>
  );
}
