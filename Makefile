start:
	docker run --rm \
		--add-host host.docker.internal:host-gateway \
		-v $$(pwd)/config.yaml:/etc/otelcol/config.yaml \
		-v /home/joseph/logs:/var/log/myapp \
		-p 4317:4317 -p 4318:4318 \
		ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:latest \
		--config /etc/otelcol/config.yaml

# Start gateway/proxy collector (sender) in collector pipeline
start-gateway:
	docker network create otel-network 2>/dev/null || true
	docker run --rm \
		--network otel-network \
		--name collector_gateway \
		-v $$(pwd)/config_gateway.yaml:/etc/otelcol/config.yaml \
		-v /home/joseph/logs:/var/log/myapp \
		-p 4317:4317 -p 4318:4318 \
		ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:latest \
		--config /etc/otelcol/config.yaml

# Start backend collector (receiver) in collector pipeline
start-backend:
	docker network create otel-network 2>/dev/null || true
	docker run --rm \
		--network otel-network \
		--name collector_backend \
		-v $$(pwd)/config_backend.yaml:/etc/otelcol/config.yaml \
		-v /home/joseph/logs:/var/log/myapp \
		-p 14317:14317 -p 14318:14318 \
		ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:latest \
		--config /etc/otelcol/config.yaml

stop-all:
	docker stop $$(docker ps -q)

health:
	curl http://localhost:13133/health

send-metrics:
	uv run python example_custom_metrics.py

# Output log entry for filelog reciver test
test-log:
	echo "$$(date +%Y-%m-%dT%H:%M:%S) DEBUG test debug message" >> $$HOME/logs/test.log
	echo "$$(date +%Y-%m-%dT%H:%M:%S) INFO test info message" >> $$HOME/logs/test.log
	echo "$$(date +%Y-%m-%dT%H:%M:%S) ERROR test error message" >> $$HOME/logs/test.log
