#!/bin/bash

# Clarvynn Demo Traffic Generator
# Generates HTTP requests to Flask services to create exemplars

set -e

echo "Clarvynn Demo Traffic Generator"
echo "==============================="
echo "Generating HTTP requests to create exemplars for demonstration"
echo ""

# Function to check if a service is accessible
check_service() {
    local service_name=$1
    local url=$2
    
    if ! curl -s "$url" > /dev/null 2>&1; then
        echo "ERROR: $service_name is not accessible at $url"
        return 1
    fi
    
    echo "$service_name is accessible"
}

echo "Checking Flask services..."
check_service "Server A (Main API)" "http://localhost:6000/"
check_service "Server B (Greeting Service)" "http://localhost:5001/greet"
check_service "Server C (Name Service)" "http://localhost:5002/name"

echo ""
echo "Starting traffic generation..."
echo "This will create HTTP requests with varying response times and sizes"
echo "to generate exemplars that connect metrics to distributed traces."
echo ""
echo "Watch for rhombus-shaped exemplar points in Grafana!"
echo "   Dashboard: http://localhost:3000 → 'Clarvynn Application Monitoring'"
echo ""

# Generate traffic in a loop
request_count=0
while true; do
    # Make requests to different endpoints
    curl -s "http://localhost:6000/" > /dev/null 2>&1 &
    curl -s "http://localhost:5001/greet" > /dev/null 2>&1 &
    curl -s "http://localhost:5002/name" > /dev/null 2>&1 &
    
    # Wait for requests to complete
    wait
    
    request_count=$((request_count + 3))
    
    # Print progress every 30 requests
    if [ $((request_count % 30)) -eq 0 ]; then
        echo "Generated $request_count requests... (exemplars should be visible in Grafana)"
    fi
    
    # Add some randomness to request timing
    sleep_time=$(echo "scale=2; $RANDOM/32767 * 2 + 0.5" | bc -l 2>/dev/null || echo "1")
    sleep "$sleep_time"
done 