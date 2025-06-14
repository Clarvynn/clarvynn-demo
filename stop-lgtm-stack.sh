#!/bin/bash

echo "Stopping Clarvynn Demo LGTM Stack..."

# Stop and remove the LGTM container
if docker ps -q -f name=lgtm | grep -q .; then
    docker stop lgtm
    docker rm lgtm
    echo "   LGTM stack stopped"
else
    echo "   LGTM stack was not running"
fi

# Clean up any orphaned containers
docker container prune -f > /dev/null 2>&1

# Clean up any dangling images (optional)
# docker image prune -f > /dev/null 2>&1

echo "Demo cleanup completed!"
echo ""
echo "To restart the demo, run: ./start-lgtm-stack.sh" 