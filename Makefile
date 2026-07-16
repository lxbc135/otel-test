nerd:
	nerdctl run --rm \
		--add-host host.docker.internal:host-gateway \
		-v $$(pwd)/config.yaml:/etc/otelcol/config.yaml \
		-v $$HOME/logs:/var/log/myapp \
		-p 4317:4317 -p 4318:4318 \
		ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:latest \
		--config /etc/otelcol/config.yaml

# Define default configuration file name
CONFIG ?= config.yaml

# make start [CONFIG=another.yaml]
start: log-dir
	docker run --rm \
		--add-host host.docker.internal:host-gateway \
		-v $$(pwd)/$(CONFIG):/etc/otelcol/config.yaml \
		-v $$HOME/logs:/var/log/otelcol \
		-p 4317:4317 -p 4318:4318 \
		ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:latest \
		--config /etc/otelcol/config.yaml

log-dir:
	mkdir -p $$HOME/logs

# Create user-defined network for collector proxy -> backend pipeline
network:
	docker network create otel-network 2>/dev/null || true

# Start proxy collector (sender) in collector pipeline
start-proxy: log-dir network
	docker run --rm \
		--network otel-network \
		--name collector_proxy \
		-v $$(pwd)/config_proxy.yaml:/etc/otelcol/config.yaml \
		-v $$HOME/logs:/var/log/otelcol \
		-p 4317:4317 -p 4318:4318 \
		ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:latest \
		--config /etc/otelcol/config.yaml

# Start backend collector (receiver) in collector pipeline
start-backend: log-dir network
	docker run --rm \
		--network otel-network \
		--name collector_backend \
		-v $$(pwd)/config_backend.yaml:/etc/otelcol/config.yaml \
		-v $$HOME/logs:/var/log/otelcol \
		-p 14317:14317 -p 14318:14318 \
		ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:latest \
		--config /etc/otelcol/config.yaml

stop:
	docker stop $$(docker ps -q)

health:
	curl http://127.0.0.1:13133/health

test-metrics:
	uv run python example_custom_metrics.py

# Output log entry for filelog reciver test
filelog:
	echo "$$(date +%Y-%m-%dT%H:%M:%S) DEBUG test debug message" >> $$HOME/logs/test.log
	echo "$$(date +%Y-%m-%dT%H:%M:%S) INFO test info message" >> $$HOME/logs/test.log
	echo "$$(date +%Y-%m-%dT%H:%M:%S) ERROR test error message" >> $$HOME/logs/test.log
