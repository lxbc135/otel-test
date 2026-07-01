const { LoggerProvider, SimpleLogRecordProcessor } = require('@opentelemetry/sdk-logs');
const { OTLPLogExporter } = require('@opentelemetry/exporter-logs-otlp-grpc');
const { SeverityNumber } = require('@opentelemetry/api-logs');

// 1. Configure the OTLP Log Exporter pointing to the OpenTelemetry Collector
// Default OTLP gRPC endpoint is http://127.0.0.1:4317
const exporter = new OTLPLogExporter({
  url: 'http://127.0.0.1:4317',
});

// Alternative for HTTP:
// const { OTLPLogExporter } = require('@opentelemetry/exporter-logs-otlp-http');
// const exporter = new OTLPLogExporter({
//   url: 'http://127.0.0.1:4318/v1/logs',
// });

// 2. Initialize the Logger Provider with the processor
const loggerProvider = new LoggerProvider({
  processors: [new SimpleLogRecordProcessor(exporter)],
});

// 3. Get a logger instance from the provider
const logger = loggerProvider.getLogger('example-log-service');

async function sendLogs() {
  console.log("Emitting log signals to the OpenTelemetry Collector...");

  // Log 1: An INFO level log with custom structured attributes (Will pass through)
  logger.emit({
    severityNumber: SeverityNumber.INFO,
    severityText: 'INFO',
    body: 'User login completed successfully',
    attributes: {
      'event.type': 'user_activity',
      'user.id': 'user-12345',
      'user.role': 'admin',
      'session.id': 'sess-abc-987',
      'login.status': 'success',
      'http.method': 'POST',
    },
  });
  console.log("-> Sent INFO log: 'User login completed successfully'");

  // Log 2: An ERROR level log capturing failure attributes (Will pass through)
  logger.emit({
    severityNumber: SeverityNumber.ERROR,
    severityText: 'ERROR',
    body: 'Database connection failed',
    attributes: {
      'event.type': 'system_error',
      'db.system': 'postgresql',
      'db.name': 'production_users',
      'error.type': 'ConnectionTimeout',
      'retry.attempt': 3,
    },
  });
  console.log("-> Sent ERROR log: 'Database connection failed'");

  // Log 3: A DEBUG level log (Will be filtered/dropped by the Collector's filter processor if configured)
  logger.emit({
    severityNumber: SeverityNumber.DEBUG,
    severityText: 'DEBUG',
    body: 'Loading local configuration parameters',
    attributes: {
      'event.type': 'diagnostic',
      'config.path': '/etc/app/config.json',
      'cache.size': 256,
    },
  });
  console.log("-> Sent DEBUG log: 'Loading local configuration parameters' (Expect collector to drop this)");

  // Flush and shutdown to ensure all log records are fully sent
  setTimeout(async () => {
    await loggerProvider.shutdown();
    console.log("Logger Provider shut down. Done.");
  }, 2000);
}

sendLogs().catch(console.error);
