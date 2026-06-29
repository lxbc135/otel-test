const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { W3CTraceContextPropagator, W3CBaggagePropagator, CompositePropagator } = require('@opentelemetry/core');
const { context, trace, propagation } = require('@opentelemetry/api');

const provider = new NodeTracerProvider();
provider.register({
  propagator: new CompositePropagator({
    propagators: [
      new W3CTraceContextPropagator(),
      new W3CBaggagePropagator(),
    ],
  }),
});
const tracer = trace.getTracer('sample-node-service');
const bag = propagation.createBaggage({ user_id: { value: "alice" } });
let ctx = propagation.setBaggage(context.active(), bag);
const parentSpan = tracer.startSpan('parent-span', undefined, ctx);
console.log("Trace ID:", parentSpan.spanContext().traceId);
const carrier = {};
propagation.inject(trace.setSpan(ctx, parentSpan), carrier);
console.log("Injected headers:", carrier);
const extractedContext = propagation.extract(context.active(), carrier);
const childSpan = tracer.startSpan('child-span', undefined, extractedContext);
console.log("Child Trace ID:", childSpan.spanContext().traceId);
const extractedBaggage = propagation.getBaggage(extractedContext);
console.log("Baggage in child:", extractedBaggage.getEntry("user_id").value);
childSpan.end();  parentSpan.end();
