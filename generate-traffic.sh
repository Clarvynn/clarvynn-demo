#!/bin/bash

# Clarvynn Demo Traffic Generator
# Generates HTTP traffic to demonstrate exemplars in action

set -e

echo "🚀 Clarvynn Demo Traffic Generator"
echo "=================================="
echo "Generating HTTP traffic to demonstrate exemplars connecting metrics to traces"
echo ""

# Check if Flask services are running
check_service() {
    local service_name=$1
    local url=$2
    
    if ! curl -s "$url" > /dev/null 2>&1; then
        echo "❌ $service_name is not accessible at $url"
        echo "   Make sure the Flask service is running with Clarvynn instrumentation"
        return 1
    fi
    echo "✅ $service_name is accessible"
}

echo "🔍 Checking Flask services..."
check_service "Server A (Main API)" "http://localhost:6000/"
check_service "Server B (Greeting Service)" "http://localhost:5001/greet"
check_service "Server C (Name Service)" "http://localhost:5002/name"
echo ""

echo "📊 Starting traffic generation..."
echo "This will generate requests to:"
echo "   • Server A: http://localhost:6000/ (calls other services)"
echo "   • Server B: http://localhost:5001/greet (greeting service)"
echo "   • Server C: http://localhost:5002/name (name service)"
echo ""
echo "💎 Watch for rhombus-shaped exemplar points in Grafana!"
echo "   Dashboard: http://localhost:3000 → '🚀 Clarvynn Application Monitoring'"
echo ""
echo "Press Ctrl+C to stop traffic generation..."
echo ""

# Traffic generation loop
request_count=0
while true; do
    request_count=$((request_count + 1))
    
    # Main endpoint (Server A) - this calls other services internally
    curl -s http://localhost:6000/ > /dev/null
    
    # Direct service calls for additional metrics
    curl -s http://localhost:5001/greet > /dev/null
    curl -s http://localhost:5002/name > /dev/null
    
    # Progress indicator
    if [ $((request_count % 10)) -eq 0 ]; then
        echo "📈 Generated $request_count requests... (exemplars should be visible in Grafana)"
    fi
    
    # Wait between requests to simulate realistic traffic
    sleep 2
done 