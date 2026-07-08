
docker run --rm `
    --name otelcol
    --add-host host.docker.internal:host-gateway `
    -v "$(Get-Location)/config.yaml:/etc/otelcol/config.yaml" `
    -v "$env:USERPROFILE/logs:/var/log/myapp" `
    -p 4317:4317 -p 4318:4318 `
    ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:latest `
    --config /etc/otelcol/config.yaml
