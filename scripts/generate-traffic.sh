#!/bin/bash

# Traffic Generator for Demo
# Bounded by TOTAL REQUESTS, not time

echo "🚦 Generating Demo Traffic"
echo "==========================="
echo ""

URL="http://localhost:8000"
TOTAL_REQUESTS=5000      # Fixed number of requests
REQUESTS_PER_SECOND=20   # 20 RPS is reasonable for any laptop

# Seed RANDOM for deterministic behavior (same error count every run)
RANDOM=42

echo "Target: $URL"
echo "Total requests: $TOTAL_REQUESTS"
echo "Rate: $REQUESTS_PER_SECOND requests/second"
echo "Estimated duration: ~$((TOTAL_REQUESTS / REQUESTS_PER_SECOND)) seconds"
echo ""
echo "Traffic pattern:"
echo "  - 70% success (200) - /api/users"
echo "  - 10% slow requests - /api/slow"
echo "  - 10% client errors (404) - /api/notfound"
echo "  - 10% server errors (500) - /api/error"
echo ""
echo "Press Ctrl+C to stop early"
echo ""

COUNT=0
START_TIME=$(date +%s)

while [ $COUNT -lt $TOTAL_REQUESTS ]; do
    # Generate traffic for 1 second (batch of REQUESTS_PER_SECOND)
    BATCH_SIZE=$REQUESTS_PER_SECOND
    
    # Don't exceed total
    REMAINING=$((TOTAL_REQUESTS - COUNT))
    if [ $BATCH_SIZE -gt $REMAINING ]; then
        BATCH_SIZE=$REMAINING
    fi
    
    for i in $(seq 1 $BATCH_SIZE); do
        # Random selection of endpoints
        RAND=$((RANDOM % 100))
        
        if [ $RAND -lt 70 ]; then
            # 70%: Fast successful request
            curl -s -o /dev/null "$URL/api/users" &
        elif [ $RAND -lt 80 ]; then
            # 10%: Slow request
            curl -s -o /dev/null "$URL/api/slow" &
        elif [ $RAND -lt 90 ]; then
            # 10%: Client error (404)
            curl -s -o /dev/null "$URL/api/notfound" &
        else
            # 10%: Server error (500)
            curl -s -o /dev/null "$URL/api/error" &
        fi
        
        COUNT=$((COUNT + 1))
    done
    
    # Print progress every 10 seconds
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    if [ $((ELAPSED % 10)) -eq 0 ] && [ $ELAPSED -gt 0 ]; then
        PERCENT=$((COUNT * 100 / TOTAL_REQUESTS))
        echo "⏱️  Progress: ${ELAPSED}s - ${COUNT}/${TOTAL_REQUESTS} requests (${PERCENT}%)"
    fi
    
    # Wait before next batch
    sleep 1
done

# Wait for background curls to finish
wait

CURRENT_TIME=$(date +%s)
ELAPSED=$((CURRENT_TIME - START_TIME))

echo ""
echo "✅ Traffic generation complete!"
echo "Total requests sent: $COUNT"
echo "Duration: ${ELAPSED} seconds"
echo ""
echo "📊 Check Grafana dashboard for results:"
echo "   http://localhost:3000"
