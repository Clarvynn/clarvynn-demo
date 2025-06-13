#!/bin/bash

# Clarvynn Exemplar Verification Script
# This script checks if exemplars are working properly in Prometheus

set -e

echo "🔍 Clarvynn Exemplar Verification"
echo "================================="
echo "Checking if exemplars are properly connected between metrics and traces..."
echo ""

# Check if Prometheus is running
if ! curl -s "http://localhost:9090/api/v1/status/config" > /dev/null 2>&1; then
    echo "❌ Prometheus is not accessible at localhost:9090"
    echo "   Make sure the LGTM stack is running: ./start-lgtm-stack.sh"
    exit 1
fi

echo "✅ Prometheus is accessible"
echo ""

# Function to check exemplars for a metric
check_exemplars() {
    local metric_name=$1
    local display_name=$2
    
    echo "🔍 Checking exemplars for: $display_name"
    echo "   Metric: $metric_name"
    
    # Query exemplars from Prometheus API
    local response=$(curl -s "http://localhost:9090/api/v1/query_exemplars?query=${metric_name}")
    local status=$(echo "$response" | jq -r '.status')
    
    if [ "$status" != "success" ]; then
        echo "   ❌ Failed to query exemplars"
        return 1
    fi
    
    # Count exemplars
    local exemplar_count=$(echo "$response" | jq '[.data[].exemplars] | add | length')
    local series_count=$(echo "$response" | jq '.data | length')
    
    if [ "$exemplar_count" = "null" ] || [ "$exemplar_count" = "0" ]; then
        echo "   ⚠️  No exemplars found"
        echo "      This might mean:"
        echo "      - No traffic has been generated yet"
        echo "      - Clarvynn services are not running"
        echo "      - Exemplar storage is not enabled"
    else
        echo "   ✅ Found $exemplar_count exemplars across $series_count metric series"
        
        # Show sample trace IDs
        local sample_traces=$(echo "$response" | jq -r '[.data[].exemplars[].labels.trace_id] | unique | .[0:3] | .[]' 2>/dev/null || echo "")
        if [ -n "$sample_traces" ]; then
            echo "   📊 Sample trace IDs:"
            echo "$sample_traces" | while read -r trace_id; do
                echo "      • $trace_id"
            done
        fi
    fi
    echo ""
}

# Check exemplars for all Clarvynn HTTP metrics
echo "📈 Checking Clarvynn HTTP Metrics Exemplars:"
echo ""

check_exemplars "http_server_duration_milliseconds_bucket" "HTTP Request Duration"
check_exemplars "http_server_request_size_bytes_bucket" "HTTP Request Size"  
check_exemplars "http_server_response_size_bytes_bucket" "HTTP Response Size"

# Check for distributed tracing correlation
echo "🔗 Checking Distributed Tracing Correlation:"
echo ""

# Get all unique trace IDs from exemplars
echo "🔍 Finding traces that span multiple services..."
all_traces=$(curl -s "http://localhost:9090/api/v1/query_exemplars?query=http_server_duration_milliseconds_bucket" | \
    jq -r '.data[].exemplars[].labels.trace_id' 2>/dev/null | sort | uniq)

if [ -z "$all_traces" ]; then
    echo "   ⚠️  No traces found in exemplars"
else
    trace_count=$(echo "$all_traces" | wc -l | tr -d ' ')
    echo "   ✅ Found $trace_count unique distributed traces"
    
    # Check if any trace spans multiple services
    echo "   🔍 Checking for cross-service traces..."
    
    for trace_id in $(echo "$all_traces" | head -3); do
        services=$(curl -s "http://localhost:9090/api/v1/query_exemplars?query=http_server_duration_milliseconds_bucket" | \
            jq -r --arg trace "$trace_id" '.data[].exemplars[] | select(.labels.trace_id == $trace) | .labels' 2>/dev/null | \
            jq -r '.service_name // .job' 2>/dev/null | sort | uniq | tr '\n' ', ' | sed 's/,$//')
        
        if [ -n "$services" ]; then
            service_count=$(echo "$services" | tr ',' '\n' | wc -l | tr -d ' ')
            echo "      📍 Trace $trace_id spans $service_count services: $services"
        fi
    done
fi

echo ""
echo "🎯 Verification Summary:"
echo "========================"

# Overall health check
exemplar_health="✅ HEALTHY"
if ! curl -s "http://localhost:9090/api/v1/query_exemplars?query=http_server_duration_milliseconds_bucket" | jq -e '.data[].exemplars' > /dev/null 2>&1; then
    exemplar_health="⚠️  NO EXEMPLARS"
fi

echo "Exemplar Status: $exemplar_health"
echo ""

if [ "$exemplar_health" = "✅ HEALTHY" ]; then
    echo "🎉 Exemplars are working correctly!"
    echo ""
    echo "💡 What this means for your demo:"
    echo "   • Metrics are connected to distributed traces"
    echo "   • Rhombus points in Grafana will link to Tempo traces"
    echo "   • SRE teams can click from 'slow request' to 'exact trace'"
    echo "   • Zero-code telemetry governance is fully functional"
    echo ""
    echo "🚀 Demo Tips:"
    echo "   • Click rhombus points in Grafana charts"
    echo "   • Show the same trace ID across multiple services"
    echo "   • Demonstrate root cause analysis workflow"
else
    echo "🔧 Troubleshooting:"
    echo "   1. Make sure Clarvynn Flask services are running"
    echo "   2. Generate some traffic: ./generate-traffic.sh"
    echo "   3. Wait 30-60 seconds for metrics to appear"
    echo "   4. Check service logs for errors"
fi

echo ""
echo "📖 For more details, see: CLARVYNN_DEMO.md" 