# Microservices E-Commerce Platform

> Production-grade microservices application with 3 independent Node.js services, NGINX API gateway, and a full Jenkins CI/CD pipeline deployed on AWS EC2.

---

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

---

## Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 18 | Microservices runtime |
| Docker | 26+ | Containerization |
| Docker Compose | v2 | Multi-service orchestration |
| NGINX | latest | API Gateway and traffic routing |
| Jenkins | 2.555+ | CI/CD automation |
| AWS EC2 | t2.medium | Cloud deployment |
| GitHub | — | Source control |
| Docker Hub | — | Container image registry |
| Slack | — | Pipeline notifications |

---

## Services

### Users Service — Port 3001

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/users` | List all users |
| GET | `/users/:id` | Get a single user |
| POST | `/users` | Create a new user |

### Products Service — Port 3002

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/products` | List all products |
| GET | `/products/:id` | Get a single product |
| POST | `/products` | Create a new product |

### Orders Service — Port 3003

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/orders` | List all orders |
| GET | `/orders/:id` | Get a single order |
| POST | `/orders` | Create a new order |

---

## Project Structure

```
microservices-ecommerce/
├── users-service/
│   ├── app.js
│   ├── Dockerfile
│   ├── .dockerignore
│   └── package.json
├── products-service/
│   ├── app.js
│   ├── Dockerfile
│   ├── .dockerignore
│   └── package.json
├── orders-service/
│   ├── app.js
│   ├── Dockerfile
│   ├── .dockerignore
│   └── package.json
├── nginx/
│   ├── nginx.conf
│   └── dashboard.html
├── scripts/
│   ├── rolling-deploy.sh
│   ├── canary-deploy.sh
│   └── rollback.sh
├── docker-compose.yml
├── Jenkinsfile
├── .gitignore
└── README.md
```

---

## How to Run Locally

### Prerequisites
- Docker Desktop installed and running
- Node.js 18+
- Git

### Steps

```bash
# Clone the repository
git clone https://github.com/CH-Nithin-Reddy/microservices-ecommerce.git
cd microservices-ecommerce

# Start all services
docker compose up --build

# Run in background
docker compose up --build -d
```

### Test the Services

```bash
# Through NGINX on port 80
curl http://localhost/users
curl http://localhost/products
curl http://localhost/orders

# View the dashboard
open http://localhost/dashboard
```

### Stop Everything

```bash
docker compose down
```

---

## CI/CD Pipeline

Every push to `main` triggers Jenkins automatically via GitHub webhook.

```
Push to GitHub
      ↓
Webhook triggers Jenkins
      ↓
Stage 1  →  Clone repository
Stage 2  →  Build all Docker images
Stage 3  →  Test all services through NGINX
Stage 4  →  Tag current images as :previous
Stage 5  →  Push images to Docker Hub
Stage 6  →  Rolling deployment
Stage 7  →  Canary deployment
Stage 8  →  Final health check
      ↓
Slack notification — success or failure
      ↓
Auto rollback if any stage fails
```

### PR Builds

When a Pull Request is opened, Jenkins runs only the build and test stages — no deployment. This catches bugs before they reach `main`.

---

## Deployment Strategies

### Rolling Deployment

Updates each service one at a time. While one service restarts, the others keep running. Zero downtime throughout the entire deployment.

```
Users ✅ → Products ✅ → Orders ✅
Each updated individually — traffic never fully drops
```

### Canary Deployment

Deploys the new version to a small canary container first. Monitors it for 60 seconds. If healthy it promotes to full deployment. If anything fails it rolls back instantly.

```
New version → 10% canary → Monitor 60s → Healthy? → Full deploy
                                        → Unhealthy? → Rollback
```

---

## Resilience Features

| Feature | How It Works |
|---------|-------------|
| Retry | Docker Hub push retries up to 3 times on network failure |
| Health checks | Docker checks each service endpoint every 10 seconds |
| Auto restart | Containers restart automatically if they crash |
| Previous image tag | Every deploy tags current image as `:previous` before updating |
| Rollback script | On pipeline failure — pulls `:previous` images and redeploys |
| Slack alerts | Instant notification on success, failure, or rollback |

---

## Pipeline Triggers

| Trigger | How | What Runs |
|---------|-----|-----------|
| Push to `main` | GitHub Webhook | Full pipeline including deploy |
| Pull Request opened | GitHub Webhook | Build and test only |
| Manual | Jenkins Build Now | Full pipeline |

---

## Dashboard

A live dashboard is available at:

```
http://YOUR_EC2_IP/dashboard
```

Shows real-time data from all 3 services with health status indicators. Auto refreshes every 30 seconds. Served directly through NGINX — no extra service required.

---

## Notifications

| Event | Alert |
|-------|-------|
| Pipeline success | ✅ Slack message with branch and build number |
| Pipeline failure | ❌ Slack alert with branch and build number |
| Rollback triggered | 🔄 Slack alert confirming previous version restored |

---

## Docker Hub Images

Images are automatically built and pushed to Docker Hub on every successful pipeline run:

```
nithinq/users-service:latest
nithinq/users-service:previous

nithinq/products-service:latest
nithinq/products-service:previous

nithinq/orders-service:latest
nithinq/orders-service:previous
```

---

## Manual Rollback

If you ever need to manually rollback to the previous version:

```bash
# SSH into EC2
ssh -i jenkins-key.pem ubuntu@YOUR_EC2_IP

# Run rollback script
bash /var/lib/jenkins/workspace/microservices-ecommerce/scripts/rollback.sh
```

---

## Resume Summary

> "Built a production-grade microservices e-commerce platform with 3 independent Node.js services behind an NGINX API gateway, deployed on AWS EC2 via Jenkins CI/CD pipeline with rolling and canary deployment strategies, GitHub webhook triggers, Slack notifications, and automatic rollback on failure."

---

## Skills Demonstrated

- Microservices architecture design
- API Gateway pattern with NGINX
- Docker containerization and Docker Compose orchestration
- CI/CD pipeline automation with Jenkins
- Rolling and Canary deployment strategies
- Docker Hub as a container image registry
- GitHub webhook integration for push and PR triggers
- Slack notifications integrated into the pipeline
- Resilience patterns — retry, health checks, auto restart, rollback
- Production deployment on AWS EC2

---

*Built by CH Nithin Reddy — Deployed on AWS EC2*
