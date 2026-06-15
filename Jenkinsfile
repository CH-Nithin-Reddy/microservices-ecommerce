pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'nithinq'
        IS_PR = "${env.CHANGE_ID ? 'true' : 'false'}"
    }

    stages {

        stage('PR Check') {
            when {
                expression { env.CHANGE_ID != null }
            }
            steps {
                echo "Running pipeline for PR #${env.CHANGE_ID}"
                echo "Source branch: ${env.CHANGE_BRANCH}"
                echo "Target branch: ${env.CHANGE_TARGET}"
            }
        }

        stage('Clone') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }

        stage('Build All Services') {
            steps {
                echo 'Building all Docker images...'
                sh 'docker compose build'
            }
        }

        stage('Test All Services') {
            steps {
                echo 'Starting services for testing...'
                sh 'docker compose up -d'
                sh 'sleep 10'
                echo 'Testing Users Service...'
                sh 'curl -f http://localhost/users || exit 1'
                echo 'Testing Products Service...'
                sh 'curl -f http://localhost/products || exit 1'
                echo 'Testing Orders Service...'
                sh 'curl -f http://localhost/orders || exit 1'
                echo 'All services passed'
                sh 'docker compose down'
            }
        }

        stage('Tag Previous Images') {
            when {
                expression { env.CHANGE_ID == null }
            }
            steps {
                echo 'Tagging current images as previous...'
                sh '''
                    docker tag microservices-ecommerce-users-service:latest nithinq/users-service:previous || true
                    docker tag microservices-ecommerce-products-service:latest nithinq/products-service:previous || true
                    docker tag microservices-ecommerce-orders-service:latest nithinq/orders-service:previous || true
                '''
            }
        }

        stage('Push to Docker Hub') {
            when {
                expression { env.CHANGE_ID == null }
            }
            steps {
                echo 'Pushing images to Docker Hub...'
                retry(3) {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker tag microservices-ecommerce-users-service:latest $DOCKER_USER/users-service:latest
                            docker tag microservices-ecommerce-products-service:latest $DOCKER_USER/products-service:latest
                            docker tag microservices-ecommerce-orders-service:latest $DOCKER_USER/orders-service:latest
                            docker push $DOCKER_USER/users-service:latest
                            docker push $DOCKER_USER/products-service:latest
                            docker push $DOCKER_USER/orders-service:latest
                            docker push $DOCKER_USER/users-service:previous || true
                            docker push $DOCKER_USER/products-service:previous || true
                            docker push $DOCKER_USER/orders-service:previous || true
                        '''
                    }
                }
            }
        }

        stage('Deploy - Rolling') {
            when {
                expression { env.CHANGE_ID == null }
            }
            steps {
                echo 'Running rolling deployment...'
                retry(3) {
                    sh 'chmod +x /var/lib/jenkins/workspace/microservices-ecommerce/scripts/rolling-deploy.sh'
                    sh 'bash /var/lib/jenkins/workspace/microservices-ecommerce/scripts/rolling-deploy.sh'
                }
            }
        }

        stage('Deploy - Canary') {
            when {
                expression { env.CHANGE_ID == null }
            }
            steps {
                echo 'Running canary deployment for users-service...'
                sh 'chmod +x /var/lib/jenkins/workspace/microservices-ecommerce/scripts/canary-deploy.sh'
                sh 'bash /var/lib/jenkins/workspace/microservices-ecommerce/scripts/canary-deploy.sh'
            }
        }

        stage('Health Check') {
            when {
                expression { env.CHANGE_ID == null }
            }
            steps {
                echo 'Running final health checks...'
                sh 'sleep 5'
                sh 'curl -f http://localhost/users || exit 1'
                sh 'curl -f http://localhost/products || exit 1'
                sh 'curl -f http://localhost/orders || exit 1'
                echo 'All services healthy'
            }
        }

    }

    post {
        success {
            echo 'Pipeline completed successfully!'
            withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_URL')]) {
                sh """
                    curl -X POST -H 'Content-type: application/json' \
                    --data '{"text":" *Pipeline SUCCESS* — microservices-ecommerce\\nBranch: ${env.BRANCH_NAME}\\nBuild: #${env.BUILD_NUMBER}\\nAll services deployed successfully"}' \
                    \$SLACK_URL
                """
            }
        }
        failure {
            echo 'Pipeline failed — triggering rollback'
            sh 'chmod +x /var/lib/jenkins/workspace/microservices-ecommerce/scripts/rollback.sh || true'
            sh 'bash /var/lib/jenkins/workspace/microservices-ecommerce/scripts/rollback.sh || true'
            withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_URL')]) {
                sh """
                    curl -X POST -H 'Content-type: application/json' \
                    --data '{"text":" *ROLLBACK triggered* — microservices-ecommerce\\nBranch: ${env.BRANCH_NAME}\\nBuild: #${env.BUILD_NUMBER}\\nPrevious version restored"}' \
                    \$SLACK_URL
                """
            }
        }
    }
}

/* This `Jenkinsfile` defines an automated **CI/CD (Continuous Integration and Continuous Deployment) pipeline**. Think of it as a smart assembly line for your software. Every time a developer pushes new code to GitHub, Jenkins wakes up and runs these steps automatically to build, test, and deploy the application safely without human intervention.

Here is a clear, step-by-step breakdown of how this automated factory works from start to finish.

---

## 1. The Global Setup (The Environment)

At the very top, the script sets up a couple of global settings:

* **`agent any`:** Tells Jenkins it can run this pipeline on any available worker machine (runner).
* **`DOCKER_HUB_USER = 'nithinq'`:** Sets a variable pointing to your Docker Hub registry profile.
* **`IS_PR`:** Automatically checks if this code run was triggered by someone opening a Pull Request (a code review proposal) or a direct code push to `main`.

---

## 2. The Core Stages (The Assembly Line)

The pipeline executes its work sequentially through several "stages." If any stage fails, the entire pipeline stops immediately to prevent broken code from going live.

### Stage 1: PR Check

* **What it does:** If the pipeline is running because of a Pull Request, it prints a message showing the PR number, the branch the code came from, and where it's trying to go.

### Stage 2: Clone

* **What it does:** Jenkins downloads the absolute latest version of the code from your GitHub repository onto the build server so it has the files it needs to work with.

### Stage 3: Build All Services

* **What it does:** Runs `docker compose build`. Jenkins reads your configurations and compiles your three Node.js microservices (`users`, `products`, and `orders`) into individual, isolated **Docker images** (executable software packages).

### Stage 4: Test All Services (The Quality Gate)

* **What it does:** This is where the application undergoes initial testing before it's allowed to leave the build environment:
1. Jenkins spins up the newly built services and the NGINX gateway locally in the background (`docker compose up -d`).
2. It pauses for 10 seconds to let the databases and servers fully start up (`sleep 10`).
3. It uses `curl -f` to send test web requests to each service through the NGINX gateway (`http://localhost/users`, etc.).
4. **The Safety Switch:** If any service replies with an error (like a 404 or 500), the command `|| exit 1` forces the stage to fail, completely stopping the pipeline before broken code can reach your users. If they all reply successfully, it shuts down the test environment (`docker compose down`).



### Stage 5: Tag Previous Images

* **What it does:** *This only runs if the code is being merged directly to main (not a PR).* Before uploading the new version, Jenkins finds the current working version on the server and re-labels it as `:previous`. This acts as a backup bookmark in case things go wrong later.

### Stage 6: Push to Docker Hub

* **What it does:** Jenkins logs into your personal Docker Hub account using secure hidden credentials (`dockerhub-creds`). It uploads both the brand new `:latest` versions of your microservices and the backup `:previous` versions to the cloud registry. It tries up to 3 times (`retry(3)`) just in case the internet hitches.

### Stage 7: Deploy - Rolling

* **What it does:** Jenkins triggers a script (`rolling-deploy.sh`) on your production EC2 server. A rolling deployment replaces old containers with new containers one by one. This ensures that the application never goes offline during an update because there is always at least one container alive handling web traffic.

### Stage 8: Deploy - Canary

* **What it does:** Jenkins kicks off a second script (`canary-deploy.sh`). A canary deployment routes a tiny fraction of real user traffic (e.g., 10%) to a new version of the code while keeping 90% of users on the old version. It acts like a "canary in a coal mine" to see if the new version breaks under real conditions without impacting everyone.

### Stage 9: Health Check (The Final Verification)

* **What it does:** Now that the code is live on the server, Jenkins waits 5 seconds and tests the live production endpoints one last time using `curl`. If the live endpoints respond successfully, the deployment is officially deemed a success.

---

## 3. Post-Deployment Actions (The Final Reporting)

Once the stages finish, Jenkins looks at the final result of the entire run and executes one of two concluding blocks:

* **`success`:** If every single stage passed flawlessly, Jenkins posts a message to your linked **Slack channel** announcing that the pipeline completed successfully, letting the development team know the new features are live.
* **`failure`:** If *anything* failed (a test broke, a container crashed, or a health check failed), Jenkins immediately triggers a fallback script (`rollback.sh`). This script pulls down the broken code and reinstates the backup images tagged `:previous`, instantly restoring the website to its last working state. It then fires an urgent message to **Slack** alerting the team that an automated rollback was triggered.*/
