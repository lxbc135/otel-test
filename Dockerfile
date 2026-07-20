# Stage 1: Get the official OTel Collector Contrib image
FROM otel/opentelemetry-collector-contrib:0.130.0 AS otelcol

# Stage 2: Build our runtime container
FROM alpine:3.20

# Install standard dependencies for dynamic binaries (like libc compatibility)
RUN apk add --no-cache ca-certificates gcompat

# Copy the OTel Collector binary from Stage 1
COPY --from=otelcol /otelcol-contrib /usr/local/bin/otelcol-contrib

# Download the matching version of the OpAMP Supervisor
# (Ensure your architecture, e.g., linux_amd64 or linux_arm64, matches your host)
ARG SUPERVISOR_VERSION=0.130.0
ARG ARCH=linux_amd64
ADD https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/cmd%2Fopampsupervisor%2Fv${SUPERVISOR_VERSION}/opampsupervisor_${SUPERVISOR_VERSION}_${ARCH} /usr/local/bin/opampsupervisor

RUN chmod +x /usr/local/bin/opampsupervisor

# Set up configuration directories
RUN mkdir -p /etc/otelcol /var/lib/otelcol
COPY supervisor.yaml /etc/otelcol/supervisor.yaml
COPY fallback-config.yaml /etc/otelcol/fallback-config.yaml

# Run the Supervisor as the entrypoint instead of the collector
ENTRYPOINT ["/usr/local/bin/opampsupervisor"]
CMD ["--config", "/etc/otelcol/supervisor.yaml"]
