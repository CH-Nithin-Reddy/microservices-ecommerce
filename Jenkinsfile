pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'nithinq'
    }

    stages {

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
            steps {
                echo 'Tagging current images as previous...'
                sh '''
                    docker tag microservices-ecommerce-users-service:latest \
                        $DOCKER_HUB_USER/users-service:previous || true
                    docker tag microservices-ecommerce-products-service:latest \
                        $DOCKER_HUB_USER/products-service:previous || true
                    docker tag microservices-ecommerce-orders-service:latest \
                        $DOCKER_HUB_USER/orders-service:previous || true
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing images to Docker Hub...'
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

                        docker tag microservices-ecommerce-users-service:latest \
                            $DOCKER_USER/users-service:latest
                        docker tag microservices-ecommerce-products-service:latest \
                            $DOCKER_USER/products-service:latest
                        docker tag microservices-ecommerce-orders-service:latest \
                            $DOCKER_USER/orders-service:latest

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

        stage('Deploy to EC2') {
            steps {
                echo 'Deploying to EC2...'
                sh '''
                    cd /home/ubuntu/microservices-ecommerce
                    docker compose pull
                    docker compose up -d
                '''
            }
        }

        stage('Health Check') {
            steps {
                echo 'Running health checks...'
                sh 'sleep 10'
                sh 'curl -f http://localhost/users || exit 1'
                sh 'curl -f http://localhost/products || exit 1'
                sh 'curl -f http://localhost/orders || exit 1'
                echo 'All services healthy after deployment'
            }
        }

    }

    post {
    success {
        echo 'CD Pipeline completed successfully — all services deployed!'
    }
    failure {
        echo 'Pipeline failed — triggering rollback'
        sh '''
            docker compose -f /var/lib/jenkins/workspace/microservices-ecommerce/docker-compose.yml down || true
            docker compose -f /var/lib/jenkins/workspace/microservices-ecommerce/docker-compose.yml up -d || true
        '''
    }
}
}