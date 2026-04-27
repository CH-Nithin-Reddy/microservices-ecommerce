#!/bin/bash

set -e

COMPOSE_FILE="/var/lib/jenkins/workspace/microservices-ecommerce/docker-compose.yml"
DOCKER_HUB_USER="nithinq"
CANARY_SERVICE="users-service"
CANARY_CONTAINER="users-service-canary"

echo "Starting canary deployment for $CANARY_SERVICE..."

# Step 1 — Start canary container on a different port
echo "Starting canary container..."
docker run -d \
    --name $CANARY_CONTAINER \
    --network microservices-ecommerce_ecommerce-net \
    $DOCKER_HUB_USER/$CANARY_SERVICE:latest

sleep 5

# Step 2 — Verify canary container is healthy directly
echo "Verifying canary container health..."
CANARY_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CANARY_CONTAINER)

if curl -f http://$CANARY_IP:3001/users > /dev/null 2>&1; then
    echo "Canary container is healthy ✅"
else
    echo "Canary container failed health check ❌ — rolling back"
    docker stop $CANARY_CONTAINER && docker rm $CANARY_CONTAINER
    exit 1
fi

# Step 3 — Monitor for 60 seconds
echo "Monitoring canary for 60 seconds..."
sleep 60

# Step 4 — Check again after monitoring period
echo "Re-checking canary after monitoring period..."
if curl -f http://$CANARY_IP:3001/users > /dev/null 2>&1; then
    echo "Canary still healthy after 60s ✅ — promoting to 100%"

    # Step 5 — Promote — stop canary and deploy full rolling update
    docker stop $CANARY_CONTAINER && docker rm $CANARY_CONTAINER

    # Full deploy
    docker compose -f $COMPOSE_FILE pull $CANARY_SERVICE
    docker compose -f $COMPOSE_FILE up -d --no-deps $CANARY_SERVICE

    echo "Canary promoted to 100% successfully ✅"
else
    echo "Canary failed after monitoring ❌ — rolling back"
    docker stop $CANARY_CONTAINER && docker rm $CANARY_CONTAINER
    exit 1
fi