#!/bin/bash

# Clarvynn Demo - LGTM Stack Startup Script
# Starts Grafana, Prometheus, Tempo, and OpenTelemetry Collector

set -e

echo "Clarvynn Demo - LGTM Stack"
echo "=================================="
echo "Starting the observability stack for Clarvynn Flask applications"
echo "This provides Grafana, Prometheus, Tempo, and OpenTelemetry Collector"
echo ""

# Function to wait for a service to be ready
wait_for_service() {
    local service_name=$1
    local url=$2
    local timeout=${3:-60}
    local count=0
    
    echo "Waiting for $service_name to be ready..."
    while [ $count -lt $timeout ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo "$service_name is ready!"
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    
    echo "ERROR: $service_name failed to start within $timeout seconds"
    return 1
}

echo "Starting Grafana LGTM stack..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if container is already running
if docker ps --format "table {{.Names}}" | grep -q "lgtm"; then
    echo "   LGTM stack already running!"
    echo ""
    echo "Available Services:"
    echo "   Grafana:     http://localhost:3000 (admin/admin)"
    echo "   Prometheus:  http://localhost:9090"
    echo "   Tempo:       http://localhost:3200"
    echo "   OTEL Collector: localhost:4317 (gRPC), localhost:4318 (HTTP)"
    echo ""
    echo "Next Steps:"
    echo "   1. Set up Flask environment: ./setup-python-env.sh"
    echo "   2. Install Clarvynn binary (download from releases)"
    echo "   3. Run Flask services with Clarvynn instrumentation"
    echo "   4. Generate traffic: ./generate-traffic.sh"
    echo ""
    echo "See CLARVYNN_DEMO.md for complete instructions"
    echo ""
    echo "The observability stack is now ready for your Clarvynn Flask applications!"
    exit 0
fi

# Create custom dashboard directory if it doesn't exist
mkdir -p docker/dashboards

# Copy our custom dashboard to the dashboards directory
if [ -f "docker/grafana-dashboard-clarvynn-app-monitoring.json" ]; then
    cp docker/grafana-dashboard-clarvynn-app-monitoring.json docker/dashboards/
fi

# Start the LGTM stack
echo "   Starting LGTM stack in Docker..."
echo "   This may take a moment to download the image..."

# Use docker run with volume mounts for custom configuration
# Remove any existing container to ensure fresh start
docker rm -f lgtm 2>/dev/null || true

docker run -d \
    --name lgtm \
    -p 3000:3000 \
    -p 9090:9090 \
    -p 3200:3200 \
    -p 4317:4317 \
    -p 4318:4318 \
    -v "$(pwd)/docker/otelcol-config.yaml:/otel-lgtm/otelcol-config.yaml" \
    -v "$(pwd)/docker/grafana-dashboard-clarvynn-app-monitoring.json:/otel-lgtm/grafana-dashboard-clarvynn-app-monitoring.json" \
    -v "$(pwd)/docker/grafana-dashboards.yaml:/etc/grafana/provisioning/dashboards/dashboards.yaml" \
    -v "$(pwd)/docker/grafana-dashboards.yaml:/otel-lgtm/grafana/conf/provisioning/dashboards/grafana-dashboards.yaml" \
    -v "$(pwd)/custom.yaml:/app/custom.yaml" \
    grafana/otel-lgtm:latest

echo "   Waiting for services to start..."

# Wait for services to be ready
wait_for_service "Grafana" "http://localhost:3000/api/health" 120
wait_for_service "OpenTelemetry Collector" "http://localhost:4318" 60

echo ""
echo "LGTM Stack is ready!"
echo ""
echo "Available Services:"
echo "   Grafana:     http://localhost:3000 (admin/admin)"
echo "   Prometheus:  http://localhost:9090"
echo "   Tempo:       http://localhost:3200"
echo "   OTEL Collector: localhost:4317 (gRPC), localhost:4318 (HTTP)"
echo ""
echo "Next Steps:"
echo "   1. Set up Flask environment: ./setup-python-env.sh"
echo "   2. Install Clarvynn binary (download from releases)"
echo "   3. Run Flask services with Clarvynn instrumentation"
echo "   4. Generate traffic: ./generate-traffic.sh"
echo ""
echo "See CLARVYNN_DEMO.md for complete instructions"
echo ""

# Add a note about the custom dashboard
if [ -f "docker/grafana-dashboard-clarvynn-app-monitoring.json" ]; then
    echo "Custom Clarvynn dashboard has been loaded into Grafana."
    echo "Look for 'Clarvynn Application Monitoring' in the Dashboards section."
    echo ""
fi

echo "The observability stack is now ready for your Clarvynn Flask applications!" 