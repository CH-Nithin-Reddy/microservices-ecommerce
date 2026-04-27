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

        stage('Deploy - Rolling') {
            when {
                expression { env.CHANGE_ID == null }
            }
            steps {
                echo 'Running rolling deployment...'
                sh 'chmod +x /var/lib/jenkins/workspace/microservices-ecommerce/scripts/rolling-deploy.sh'
                sh 'bash /var/lib/jenkins/workspace/microservices-ecommerce/scripts/rolling-deploy.sh'
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
                    --data '{"text":"✅ *Pipeline SUCCESS* — microservices-ecommerce\\nBranch: ${env.BRANCH_NAME}\\nBuild: #${env.BUILD_NUMBER}\\nAll services deployed successfully"}' \
                    \$SLACK_URL
                """
            }
        }
        failure {
            echo 'Pipeline failed — triggering rollback'
            sh 'docker compose -f /var/lib/jenkins/workspace/microservices-ecommerce/docker-compose.yml down || true'
            sh 'docker compose -f /var/lib/jenkins/workspace/microservices-ecommerce/docker-compose.yml up -d || true'
            withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_URL')]) {
                sh """
                    curl -X POST -H 'Content-type: application/json' \
                    --data '{"text":"❌ *Pipeline FAILED* — microservices-ecommerce\\nBranch: ${env.BRANCH_NAME}\\nBuild: #${env.BUILD_NUMBER}\\nCheck Jenkins logs immediately"}' \
                    \$SLACK_URL
                """
            }
        }
    }
}