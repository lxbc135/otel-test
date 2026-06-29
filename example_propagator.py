"""Use W3C Trace Context and Baggage propagators, which are the OpenTelemetry defaults."""
from opentelemetry import trace, propagate, baggage
from opentelemetry.sdk.trace import TracerProvider
# from opentelemetry.sdk.trace.export import BatchSpanProcessor
# from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)  # Inject baggage
context = baggage.set_baggage("user_id", "alice")

# Propagate context with span
with tracer.start_as_current_span("parent-span", context=context) as parent_span:
    print("Trace ID:", parent_span.get_span_context().trace_id)
    print("Baggage user_id:", baggage.get_baggage("user_id", context))

    # Simulate outbound request: inject context (with active span and baggage) into headers
    headers: dict[str, str] = {}
    current_context = trace.set_span_in_context(parent_span, context)
    propagate.inject(headers, context=current_context)
    print("Injected headers:", headers)

# Simulate incoming request: extract context from headers
new_context = propagate.extract(headers)
with tracer.start_as_current_span("child-span", context=new_context) as child_span:
    print("Child Trace ID:", child_span.get_span_context().trace_id)
    print("Baggage in child:", baggage.get_baggage("user_id", new_context))
