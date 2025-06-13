#!/bin/bash

# Clarvynn Application Monitoring Demo Setup
# This script demonstrates exemplars in action with realistic HTTP metrics

set -e

echo "🚀 Clarvynn Demo - LGTM Stack"
echo "=================================="
echo "Starting the observability stack for Clarvynn Flask applications"
echo "This provides Grafana, Prometheus, Tempo, and OpenTelemetry Collector"
echo ""

# Function to check if a service is ready
check_service() {
    local service_name=$1
    local url=$2
    local timeout=60
    local count=0
    
    echo "⏳ Waiting for $service_name to be ready..."
    while [ $count -lt $timeout ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo "✅ $service_name is ready!"
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    
    echo "❌ $service_name failed to start within $timeout seconds"
    return 1
}

# Step 1: Start the LGTM stack
echo "📦 Starting Grafana LGTM stack..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if LGTM container is already running
if docker ps --format "table {{.Names}}" | grep -q "^lgtm$"; then
    echo "   ✅ LGTM stack already running!"
else
    echo "   🐳 Starting LGTM stack in Docker..."
    echo "   This may take a moment to download the image..."
    
    # Create container directories for data persistence
    mkdir -p container/grafana container/prometheus container/loki
    
    # Create proper Grafana provisioning structure
    mkdir -p container/grafana-provisioning/dashboards
    mkdir -p container/grafana-provisioning/datasources
    
    # Copy our custom dashboard to the provisioning directory
    cp docker/grafana-dashboard-clarvynn-app-monitoring.json container/grafana-provisioning/dashboards/
    
    # Create dashboard provisioning config
    cat > container/grafana-provisioning/dashboards/dashboards.yml << EOF
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF
    
    # Start LGTM stack with proper provisioning mounted
    docker run \
        --name lgtm \
        -p 3000:3000 \
        -p 4317:4317 \
        -p 4318:4318 \
        -p 9090:9090 \
        -p 3200:3200 \
        --rm \
        -d \
        -v "$PWD"/container/grafana:/data/grafana \
        -v "$PWD"/container/prometheus:/data/prometheus \
        -v "$PWD"/container/loki:/data/loki \
        -v "$PWD"/container/grafana-provisioning:/etc/grafana/provisioning \
        -e GF_PATHS_DATA=/data/grafana \
        -e GF_PATHS_PROVISIONING=/etc/grafana/provisioning \
        docker.io/grafana/otel-lgtm:latest > /tmp/lgtm-startup.log 2>&1
    
    LGTM_PID=$!
    
    # Wait for services to be ready
    echo "   ⏳ Waiting for services to start..."
    sleep 15
    
    check_service "Grafana" "http://localhost:3000/api/health"
    check_service "OpenTelemetry Collector" "http://localhost:4318/v1/traces"
fi

echo ""
echo "✅ LGTM Stack is ready!"
echo ""
echo "🌐 Available Services:"
echo "   📊 Grafana:     http://localhost:3000 (admin/admin)"
echo "   📈 Prometheus:  http://localhost:9090"
echo "   🔍 Tempo:       http://localhost:3200"
echo "   📡 OTEL Collector: localhost:4317 (gRPC), localhost:4318 (HTTP)"
echo ""
echo "🎯 Next Steps:"
echo "   1. Set up Flask environment: ./setup-python-env.sh"
echo "   2. Install Clarvynn binary (download from releases)"
echo "   3. Run Flask services with Clarvynn instrumentation"
echo "   4. Generate traffic: ./generate-traffic.sh"
echo ""
echo "📖 See CLARVYNN_DEMO.md for complete instructions"
echo ""

# For macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    open "http://localhost:3000"
# For Linux with GUI
elif command -v xdg-open &> /dev/null; then
    xdg-open "http://localhost:3000"
else
    echo "   Please manually open: http://localhost:3000"
fi

echo "🚀 The observability stack is now ready for your Clarvynn Flask applications!"
echo ""
echo "ℹ️  To stop the stack later, run: ./stop-lgtm-stack.sh" 