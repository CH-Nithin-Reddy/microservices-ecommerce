# Microservices E-Commerce Platform

Production-grade microservices application with full CI/CD pipeline deployed on AWS EC2.

## Architecture

```
Developer pushes code
        ↓
    GitHub Repo
        ↓
  GitHub Webhook
        ↓
 Jenkins Pipeline
        ↓
┌───────────────────────────────┐
│   Build → Test → Docker Push  │
└───────────────────────────────┘
        ↓
   AWS EC2 Server
        ↓
┌──────────────────────────────────────┐
│           NGINX (Port 80)            │
│         API Gateway / Router         │
└───────┬──────────┬───────────┬───────┘
        ↓          ↓           ↓
   ┌─────────┐ ┌─────────┐ ┌─────────┐
   │  Users  │ │Products │ │ Orders  │
   │ :3001   │ │ :3002   │ │ :3003   │
   └─────────┘ └─────────┘ └─────────┘
```

## Tech Stack

| Tool | Purpose |
|------|---------|
| Node.js 18 | Microservices runtime |
| Docker | Containerization |
| Docker Compose | Multi-service orchestration |
| NGINX | API Gateway |
| Jenkins | CI/CD automation |
| AWS EC2 | Cloud deployment |
| GitHub | Source control |
| Docker Hub | Image registry |
| Slack | Notifications |

## Services

| Service | Port | Endpoints |
|---------|------|-----------|
| Users | 3001 | GET /users, GET /users/:id, POST /users |
| Products | 3002 | GET /products, GET /products/:id, POST /products |
| Orders | 3003 | GET /orders, GET /orders/:id, POST /orders |

## How to Run Locally

```bash
git clone https://github.com/CH-Nithin-Reddy/microservices-ecommerce.git
cd microservices-ecommerce
docker compose up --build
```

Test the services:
```bash
curl http://localhost/users
curl http://localhost/products
curl http://localhost/orders
```

## CI/CD Pipeline

Every push to main triggers Jenkins automatically:

1. Clone repository
2. Build all Docker images
3. Test all services through NGINX
4. Tag current images as previous (for rollback)
5. Push images to Docker Hub
6. Rolling deployment — updates one service at a time
7. Canary deployment — 10% traffic test before full rollout
8. Health check all services
9. Slack notification on success or failure

## Deployment Strategies

**Rolling Deployment** — updates each service one at a time so there is always a version running. Zero downtime.

**Canary Deployment** — deploys to a small container first, monitors for 60 seconds, then promotes to full deployment if healthy. Instant rollback if it fails.

## Resilience Features

| Feature | How It Works |
|---------|-------------|
| Retry | Docker Hub push retries up to 3 times on failure |
| Auto restart | Containers restart automatically if they crash |
| Health checks | Docker monitors each service every 10 seconds |
| Rollback | Previous image restored automatically on pipeline failure |
| Slack alerts | Instant notification on success, failure or rollback |

## Triggers

| Trigger | How |
|---------|-----|
| Push to main | GitHub Webhook → full pipeline including deploy |
| Pull Request | GitHub Webhook → build and test only, no deploy |
| Manual | Jenkins Build Now button |
```
---


