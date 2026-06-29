import grpc
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider as SDKTracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

provider = SDKTracerProvider(
    resource=Resource.create({"service.name": "sample-python-service"})
)
otlp_exporter = OTLPSpanExporter(
    endpoint="localhost:4317",  # Collector OTLP gRPC endpoint
    insecure=True,              # Use insecure if no TLS
    timeout=5,                  # Custom timeout in seconds
    retryable_error_codes=[     # Custom retryable gRPC error codes
        grpc.StatusCode.UNAVAILABLE,
        grpc.StatusCode.DEADLINE_EXCEEDED
    ]
)
span_processor = BatchSpanProcessor(otlp_exporter)
provider.add_span_processor(span_processor)
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)

# Emit a test span
with tracer.start_as_current_span("test-span-timeout-retry"):
    print("Test span emitted")

# Ensure all spans are flushed and sent before exiting
provider.shutdown()
