import time
from opentelemetry.sdk._logs import LoggerProvider
from opentelemetry.sdk._logs.export import SimpleLogRecordProcessor
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter
from opentelemetry._logs.severity import SeverityNumber

# 1. Initialize the Logger Provider
logger_provider = LoggerProvider()

# 2. Configure the OTLP Log Exporter pointing to the OpenTelemetry Collector
# Default OTLP gRPC endpoint is 127.0.0.1:4317
exporter = OTLPLogExporter(
    endpoint="127.0.0.1:4317",
    insecure=True
)

# Alternative for HTTP:
# from opentelemetry.exporter.otlp.proto.http._log_exporter import OTLPLogExporter
# exporter = OTLPLogExporter(
#     endpoint="http://127.0.0.1:4318/v1/logs"
# )

# 3. Add the processor with the configured exporter to the provider
logger_provider.add_log_record_processor(SimpleLogRecordProcessor(exporter))

# 4. Get a logger instance from the provider
logger = logger_provider.get_logger("example-log-service")

def send_logs():
    print("Emitting log signals to the OpenTelemetry Collector...")

    # Log 1: An INFO level log with custom structured attributes (Will pass through)
    logger.emit(
        severity_number=SeverityNumber.INFO,
        severity_text="INFO",
        body="User login completed successfully",
        attributes={
            "event.type": "user_activity",
            "user.id": "user-12345",
            "user.role": "admin",
            "session.id": "sess-abc-987",
            "login.status": "success",
            "http.method": "POST",
        }
    )
    print("-> Sent INFO log: 'User login completed successfully'")

    # Log 2: An ERROR level log capturing failure attributes (Will pass through)
    logger.emit(
        severity_number=SeverityNumber.ERROR,
        severity_text="ERROR",
        body="Database connection failed",
        attributes={
            "event.type": "system_error",
            "db.system": "postgresql",
            "db.name": "production_users",
            "error.type": "ConnectionTimeout",
            "retry.attempt": 3,
        }
    )
    print("-> Sent ERROR log: 'Database connection failed'")

    # Log 3: A DEBUG level log (Will be filtered/dropped by the Collector's filter processor if configured)
    logger.emit(
        severity_number=SeverityNumber.DEBUG,
        severity_text="DEBUG",
        body="Loading local configuration parameters",
        attributes={
            "event.type": "diagnostic",
            "config.path": "/etc/app/config.json",
            "cache.size": 256,
        }
    )
    print("-> Sent DEBUG log: 'Loading local configuration parameters' (Expect collector to drop this)")

    # Flush and shutdown to ensure all log records are fully sent
    print("Flushing and shutting down logger provider...")
    time.sleep(2)
    logger_provider.shutdown()
    print("Logger Provider shut down. Done.")

if __name__ == "__main__":
    send_logs()
