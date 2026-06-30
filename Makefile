start:
	docker run --rm \
		-v $$(pwd)/config.yaml:/etc/otelcol/config.yaml \
		-v /home/joseph/logs:/var/log/myapp \
		-p 4317:4317 -p 4318:4318 -p 13133:13133 -p 55679:55679 \
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
