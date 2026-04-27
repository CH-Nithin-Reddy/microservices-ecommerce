#!/bin/bash

COMPOSE_FILE="/var/lib/jenkins/workspace/microservices-ecommerce/docker-compose.yml"
DOCKER_HUB_USER="nithinq"

echo "ROLLBACK triggered — restoring previous images..."

# Pull previous tagged images
docker pull $DOCKER_HUB_USER/users-service:previous
docker pull $DOCKER_HUB_USER/products-service:previous
docker pull $DOCKER_HUB_USER/orders-service:previous

# Re-tag previous as latest locally
docker tag $DOCKER_HUB_USER/users-service:previous $DOCKER_HUB_USER/users-service:latest
docker tag $DOCKER_HUB_USER/products-service:previous $DOCKER_HUB_USER/products-service:latest
docker tag $DOCKER_HUB_USER/orders-service:previous $DOCKER_HUB_USER/orders-service:latest

# Restart all services with previous images
docker compose -f $COMPOSE_FILE down
docker compose -f $COMPOSE_FILE up -d

echo "Rollback complete — previous version is now live"