import time
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider as SDKTracerProvider
from opentelemetry.sdk.trace.export import SimpleSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# 1. Configure the OTLP trace exporter pointing to the local OTel Collector (gRPC default)
exporter = OTLPSpanExporter(
    endpoint="localhost:4317",
    insecure=True
)

# 2. Initialize the Tracer Provider with the configured span processor
provider = SDKTracerProvider()
span_processor = SimpleSpanProcessor(exporter)
provider.add_span_processor(span_processor)

# Register the provider as the global tracer provider
trace.set_tracer_provider(provider)

# 3. Get the tracer instance
tracer = trace.get_tracer("test-filter-tracer")

def send_spans():
    print("Sending spans...")

    # --- Span 1: A normal operational span (Should pass through) ---
    valid_span = tracer.start_span("api/v1/users")
    valid_span.set_attribute("http.target", "/api/v1/users")
    print("-> Started 'api/v1/users' span")
    time.sleep(0.1)  # Simulate work
    valid_span.end()
    print("-> Sent 'api/v1/users' span")

    # --- Span 2: The health check span (Should be filtered out) ---
    health_span = tracer.start_span("/health")
    health_span.set_attribute("http.target", "/health")
    print("-> Started '/health' span")
    time.sleep(0.05)  # Simulate work
    health_span.end()
    print("-> Sent '/health' span")

    # Clean shutdown to ensure all spans leave the application
    print("Flushing and shutting down tracer provider...")
    time.sleep(2)
    provider.shutdown()
    print("Done.")

if __name__ == "__main__":
    send_spans()
