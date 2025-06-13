#!/bin/bash

echo "🛑 Stopping Clarvynn Demo LGTM Stack..."

# Stop the LGTM container
if docker ps --format "table {{.Names}}" | grep -q "^lgtm$"; then
    echo "   Stopping LGTM stack..."
    docker stop lgtm
    echo "   ✅ LGTM stack stopped"
else
    echo "   ℹ️  LGTM stack is not running"
fi

# Clean up any leftover containers
docker container prune -f > /dev/null 2>&1

echo ""
echo "✅ Demo cleanup completed!"
echo ""
echo "🚀 To restart the demo, run: ./start-lgtm-stack.sh" 