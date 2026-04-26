#!/bin/bash

set -e

SERVICES=("users-service" "products-service" "orders-service")
COMPOSE_FILE="/var/lib/jenkins/workspace/microservices-ecommerce/docker-compose.yml"

echo "Starting rolling deployment..."

# Make sure NGINX is running first
docker compose -f $COMPOSE_FILE up -d nginx
sleep 5

for SERVICE in "${SERVICES[@]}"; do
    echo ""
    echo "Updating $SERVICE..."

    # Pull latest image for this service
    docker compose -f $COMPOSE_FILE pull $SERVICE

    # Restart only this service, keep others running
    docker compose -f $COMPOSE_FILE up -d --no-deps $SERVICE

    # Wait for it to start
    sleep 8

    # Map service to route
    case $SERVICE in
        users-service)    ROUTE="users" ;;
        products-service) ROUTE="products" ;;
        orders-service)   ROUTE="orders" ;;
    esac

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