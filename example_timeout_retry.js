const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { BatchSpanProcessor } = require('@opentelemetry/sdk-trace-base');
const exporter = new OTLPTraceExporter({
  url: 'http://localhost:4318/v1/traces',
  timeoutMillis: 5000 // 5 seconds timeout
});
const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const provider = new NodeTracerProvider();
provider.addSpanProcessor(new BatchSpanProcessor(exporter));
provider.register();
