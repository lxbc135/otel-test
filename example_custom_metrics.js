const { MeterProvider, PeriodicExportingMetricReader } = require('@opentelemetry/sdk-metrics');
const { OTLPMetricExporter } = require('@opentelemetry/exporter-metrics-otlp-http');

const exporter = new OTLPMetricExporter({ url: 'http://localhost:4318/v1/metrics' });
const reader = new PeriodicExportingMetricReader({ exporter, exportIntervalMillis: 5000 });
const meterProvider = new MeterProvider({ readers: [reader] });

const meter = meterProvider.getMeter('custom-metrics-demo');
const orderCounter = meter.createCounter('orders_processed', { description: 'Number of processed orders' });

orderCounter.add(1, { status: 'success' });
orderCounter.add(2, { status: 'failed' });

console.log("Custom metrics emitted.");

setTimeout(() => process.exit(0), 6000); // Allow time for export
