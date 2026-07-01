const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { SimpleSpanProcessor } = require('@opentelemetry/sdk-trace-base');
const { trace, context } = require('@opentelemetry/api');
const exporter = new OTLPTraceExporter({
  url: 'http://127.0.0.1:4318/v1/traces', // OTLP HTTP endpoint
});
const provider = new NodeTracerProvider({
  spanProcessors: [new SimpleSpanProcessor(exporter)]
});
provider.register();
const tracer = trace.getTracer('sample-node-service');
const span = tracer.startSpan('test-span');
span.end();
console.log('Test span emitted');
