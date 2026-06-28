start:
	docker run --rm \
		-v $$(pwd)/config.yaml:/etc/otelcol/config.yaml \
		-p 4317:4317 -p 4318:4318 -p 13133:13133 -p 55679:55679 \
		ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:latest \
		--config /etc/otelcol/config.yaml

stop-all:
	docker stop $$(docker ps -q)
