#!/bin/bash

# Clarvynn Exemplar Verification Script
# Checks if exemplars are properly connected between metrics and traces

set -e

echo "Clarvynn Exemplar Verification"
echo "==============================="
echo "Checking if exemplars are properly connected between metrics and traces..."
echo ""

# Check if Prometheus is accessible
if ! curl -s "http://localhost:9090/-/healthy" > /dev/null 2>&1; then
    echo "ERROR: Prometheus is not accessible at localhost:9090"
    echo "Make sure the LGTM stack is running: ./start-lgtm-stack.sh"
    exit 1
fi

echo "Prometheus is accessible"
echo ""

# Function to check exemplars for a specific metric
check_exemplars() {
    local metric_name=$1
    local display_name=$2
    
    echo "Checking exemplars for: $display_name"
    echo "   Metric: $metric_name"
    
    # Query exemplars from Prometheus
    local response
    if ! response=$(curl -s "http://localhost:9090/api/v1/query_exemplars?query=${metric_name}" 2>/dev/null); then
        echo "   ERROR: Failed to query exemplars"
        return 1
    fi
    
    # Parse the response to count exemplars
    local exemplar_count=0
    local series_count=0
    local trace_ids=()
    
    # Count exemplars and extract trace IDs
    if echo "$response" | grep -q '"status":"success"'; then
        exemplar_count=$(echo "$response" | jq -r '.data[] | .exemplars[]?' 2>/dev/null | wc -l | tr -d ' ')
        series_count=$(echo "$response" | jq -r '.data | length' 2>/dev/null)
        
        # Extract first few trace IDs for display
        mapfile -t trace_ids < <(echo "$response" | jq -r '.data[].exemplars[]?.labels.traceID' 2>/dev/null | head -3)
    fi
    
    if [ "$exemplar_count" -gt 0 ]; then
        echo "   Found $exemplar_count exemplars across $series_count metric series"
        
        if [ ${#trace_ids[@]} -gt 0 ]; then
            echo "   Sample trace IDs:"
            for trace_id in "${trace_ids[@]}"; do
                if [ -n "$trace_id" ] && [ "$trace_id" != "null" ]; then
                    echo "      • $trace_id"
                fi
            done
        fi
    else
        echo "   No exemplars found"
        return 1
    fi
    
    echo ""
}

echo "Checking Clarvynn HTTP Metrics Exemplars:"
echo ""

# Check exemplars for each HTTP metric
check_exemplars "http_server_duration_milliseconds_bucket" "HTTP Request Duration"
check_exemplars "http_server_request_size_bytes_bucket" "HTTP Request Size"
check_exemplars "http_server_response_size_bytes_bucket" "HTTP Response Size"

echo "Checking Distributed Tracing Correlation:"
echo ""

# Get all trace IDs from exemplars
echo "Finding traces that span multiple services..."
all_trace_ids=$(curl -s "http://localhost:9090/api/v1/query_exemplars?query=http_server_duration_milliseconds_bucket" | \
    jq -r '.data[].exemplars[]?.labels.traceID' 2>/dev/null | \
    grep -v null | sort | uniq)

if [ -n "$all_trace_ids" ]; then
    trace_count=$(echo "$all_trace_ids" | wc -l | tr -d ' ')
    echo "   Found $trace_count unique distributed traces"
    echo ""
    echo "   Checking for cross-service traces..."
    
    # Check a few traces to see if they span multiple services
    echo "$all_trace_ids" | head -3 | while read -r trace_id; do
        if [ -n "$trace_id" ]; then
            # Query for services in this trace (simplified check)
            services=$(curl -s "http://localhost:9090/api/v1/query_exemplars?query=http_server_duration_milliseconds_bucket" | \
                jq -r ".data[].exemplars[] | select(.labels.traceID == \"$trace_id\") | .labels.service_name" 2>/dev/null | \
                sort | uniq | tr '\n' ', ' | sed 's/,$//')
            
            service_count=$(echo "$services" | tr ',' '\n' | grep -v '^$' | wc -l | tr -d ' ')
            echo "      Trace $trace_id spans $service_count services: $services"
        fi
    done
else
    echo "   No trace IDs found in exemplars"
fi

echo ""
echo "Verification Summary:"
echo "========================"

# Determine overall health
exemplar_health="HEALTHY"
if ! curl -s "http://localhost:9090/api/v1/query_exemplars?query=http_server_duration_milliseconds_bucket" | grep -q '"status":"success"'; then
    exemplar_health="UNHEALTHY"
fi

echo "Exemplar Status: $exemplar_health"
echo ""

if [ "$exemplar_health" = "HEALTHY" ]; then
    echo "Exemplars are working correctly!"
    echo ""
    echo "What this means for your demo:"
    echo "   • Metrics are connected to distributed traces"
    echo "   • Rhombus points in Grafana will link to Tempo traces"
    echo "   • SRE teams can click from 'slow request' to 'exact trace'"
    echo "   • Zero-code observability is fully functional"
    echo ""
    echo "Demo Tips:"
    echo "   • Click rhombus points in Grafana charts"
    echo "   • Show the same trace ID across multiple services"
    echo "   • Demonstrate root cause analysis workflow"
else
    echo "Troubleshooting:"
    echo "   1. Ensure all Flask services are running with Clarvynn"
    echo "   2. Generate traffic: ./generate-traffic.sh"
    echo "   3. Wait 30-60 seconds for metrics to appear"
    echo "   4. Check LGTM stack: docker ps"
fi

echo ""
echo "For more details, see: CLARVYNN_DEMO.md" 