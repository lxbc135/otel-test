const api = require('@opentelemetry/api');
const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { SimpleSpanProcessor } = require('@opentelemetry/sdk-trace-base');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');

// 1. Configure the OTLP exporter pointing to your local OTel Collector (default gRPC port)
const exporter = new OTLPTraceExporter({
  url: 'http://localhost:4317',
});

// 2. Initialize the Tracer Provider with the configured span processor
const provider = new NodeTracerProvider({
  spanProcessors: [new SimpleSpanProcessor(exporter)]
});

provider.register();

const tracer = api.trace.getTracer('test-filter-tracer');

async function sendSpans() {
  console.log("Sending spans...");

  // --- Span 1: A normal operational span (Should pass through) ---
  const validSpan = tracer.startSpan('api/v1/users');
  validSpan.setAttribute('http.target', '/api/v1/users');
  await new Promise((resolve) => setTimeout(resolve, 100)); // Simulate work
  validSpan.end();
  console.log("-> Sent 'api/v1/users' span");

  // --- Span 2: The health check span (Should be filtered out) ---
  const healthSpan = tracer.startSpan('/health');
  healthSpan.setAttribute('http.target', '/health');
  await new Promise((resolve) => setTimeout(resolve, 50)); // Simulate work
  healthSpan.end();
  console.log("-> Sent '/health' span");

  // Flush and shutdown cleanly to ensure spans leave the JS application
  setTimeout(async () => {
    await provider.shutdown();
    console.log("Done.");
  }, 2000);
}

sendSpans();
