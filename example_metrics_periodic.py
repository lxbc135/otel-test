from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.metrics import set_meter_provider

exporter = OTLPMetricExporter(endpoint="127.0.0.1:4317", insecure=True)
reader = PeriodicExportingMetricReader(exporter, export_interval_millis=5000)
provider = MeterProvider(metric_readers=[reader])
set_meter_provider(provider)
meter = provider.get_meter("custom-metrics-demo")
order_counter = meter.create_counter("orders_processed", unit="1", description="Number of processed orders")
order_counter.add(1, {"status": "success"})
order_counter.add(2, {"status": "failed"})
print("Custom metrics emitted.")

