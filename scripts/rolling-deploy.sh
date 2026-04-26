#!/bin/bash

set -e

SERVICES=("users-service" "products-service" "orders-service")
COMPOSE_FILE="/var/lib/jenkins/workspace/microservices-ecommerce/docker-compose.yml"

echo "Starting rolling deployment..."

for SERVICE in "${SERVICES[@]}"; do
    echo ""
    echo "Updating $SERVICE..."

    # Pull latest image for this service
    docker compose -f $COMPOSE_FILE pull $SERVICE

    # Restart only this service, keep others running
    docker compose -f $COMPOSE_FILE up -d --no-deps $SERVICE

    # Wait for it to start
    sleep 8

    # Health check — derive the route from service name
    ROUTE=$(echo $SERVICE | sed 's/-service/s/')

    echo "Health checking /$ROUTE..."
    if curl -f http://localhost/$ROUTE > /dev/null 2>&1; then
        echo "$SERVICE is healthy ✅"
    else
        echo "$SERVICE health check failed ❌ — stopping rollout"
        exit 1
    fi

done

echo ""
echo "Rolling deployment complete — all services updated successfully"