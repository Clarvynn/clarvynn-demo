#!/bin/bash

# Demo Script: Run Flask App with OTEL Auto-Instrumentation
# This same script works for both vanilla OTEL and Clarvynn

echo "Starting Payment Service with OTEL"
echo "======================================"
echo ""

# Set OTEL configuration
export OTEL_SERVICE_NAME="payment-service"
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"
export OTEL_EXPORTER_OTLP_PROTOCOL="grpc"
export OTEL_TRACES_EXPORTER="otlp"
export OTEL_METRICS_EXPORTER="otlp"
export OTEL_LOGS_EXPORTER="otlp"

# Enable Python logging auto-instrumentation
export OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED="true"
export OTEL_PYTHON_LOG_CORRELATION="true"

# Check if Clarvynn is enabled
if [ "$CLARVYNN_ENABLED" = "true" ]; then
    echo "Clarvynn: ENABLED"
    echo "   Policy: $CLARVYNN_POLICY_PATH"
    echo "   Expected: ~15% traces exported (85% cost savings)"
else
    echo "Clarvynn: DISABLED (vanilla OTEL)"
    echo "   Expected: 100% traces exported"
fi
echo ""

echo "Starting Flask application..."
echo "API available at: http://localhost:8000"
echo ""
echo "📊 Open Grafana dashboard: http://localhost:3000"
echo "   Import: grafana-comprehensive-dashboard.json"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Run with OTEL auto-instrumentation
cd "$(dirname "$0")/../apps/payment-service"
opentelemetry-instrument python app.py
