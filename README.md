# 🔥 Project 2 — Full Design

## Project Title
**Microservices E-Commerce App — Production Grade CI/CD**

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

## Full Phase Breakdown

| Phase | Topic | What We Cover |
|---|---|---|
| **1** | App Development | Build 3 microservices |
| **2** | Dockerize | Dockerfile per service |
| **3** | Docker Compose | Run all services together |
| **4** | NGINX Gateway | Route traffic to services |
| **5** | GitHub Setup | Mono repo + structure |
| **6** | Jenkins Setup | Fresh install on new EC2 |
| **7** | CI Pipeline | Build + Test per service |
| **8** | CD Pipeline | Deploy to EC2 |
| **9** | Rolling Deployment | Zero downtime rolling update |
| **10** | Canary Deployment | 10% traffic → 100% |
| **11** | PR Trigger | Auto trigger on Pull Request |
| **12** | Notifications | Slack/Email on success/fail |
| **13** | Resilience | Retry, rollback, health checks |
| **14** | Final Polish | README + Resume writeup |

---

## Microservices Detail

### Service 1 — Users Service (Port 3001)
```
GET  /users          → list all users
GET  /users/:id      → get one user
POST /users          → create user
```

### Service 2 — Products Service (Port 3002)
```
GET  /products       → list all products
GET  /products/:id   → get one product
POST /products       → create product
```

### Service 3 — Orders Service (Port 3003)
```
GET  /orders         → list all orders
GET  /orders/:id     → get one order
POST /orders         → create order
```

---

## File Structure
```
microservices-ecommerce/
├── users-service/
│   ├── app.js
│   ├── package.json
│   └── Dockerfile
├── products-service/
│   ├── app.js
│   ├── package.json
│   └── Dockerfile
├── orders-service/
│   ├── app.js
│   ├── package.json
│   └── Dockerfile
├── nginx/
│   └── nginx.conf
├── docker-compose.yml
├── Jenkinsfile
└── README.md
```

---

## CI/CD Pipeline Stages

```
Push to GitHub
      ↓
Webhook triggers Jenkins
      ↓
┌─────────────────────────────────────┐
│ Stage 1: Clone                       │
│ Stage 2: Build All Services          │
│ Stage 3: Test All Services           │
│ Stage 4: Docker Build per Service    │
│ Stage 5: Docker Push to Docker Hub   │
│ Stage 6: Deploy (Rolling/Canary)     │
│ Stage 7: Health Check All Services   │
│ Stage 8: Notify (Slack/Email)        │
└─────────────────────────────────────┘
      ↓
Auto Rollback if any stage fails
```

---

## Deployment Strategies We'll Use

### Rolling Deployment
```
Update service one by one:
Users ✅ → Products ✅ → Orders ✅
Never take all down at once
Zero downtime
```

### Canary Deployment
```
Deploy new version to 10% traffic
      ↓
Monitor health
      ↓
If healthy → push to 100%
If fails   → rollback instantly
```

---

## Resilience Features

| Feature | Implementation |
|---|---|
| Retry | retry(3) on build + deploy |
| Rollback | Auto on any failure |
| Health Checks | curl each service after deploy |
| Previous Version | Always tag :previous before deploy |

---

## Triggers We'll Cover

| Trigger | How |
|---|---|
| Push to main | GitHub Webhook |
| Pull Request | GitHub PR Webhook |
| Manual | Build Now button |

---

## Notifications

| Event | Notification |
|---|---|
| Pipeline Success | Slack message + Email |
| Pipeline Failure | Slack alert + Email |
| Rollback triggered | Slack alert |

---

## Tech Stack — Complete

| Tool | Version | Purpose |
|---|---|---|
| Node.js | 18 | Microservices |
| Docker | 26+ | Containerization |
| Docker Compose | v2 | Multi service orchestration |
| NGINX | latest | API Gateway |
| Jenkins | 2.555+ | CI/CD Automation |
| AWS EC2 | t2.medium | Cloud server |
| GitHub | - | Source control |
| Docker Hub | - | Image registry |
| Slack | - | Notifications |

---

