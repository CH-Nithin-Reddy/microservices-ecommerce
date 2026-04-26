pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'YOUR_DOCKERHUB_USERNAME'
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

                echo 'All services passed health check'
                sh 'docker compose down'
            }
        }

    }

    post {
        success {
            echo 'CI Pipeline passed successfully!'
        }
        failure {
            echo 'CI Pipeline failed — check logs above'
            sh 'docker compose down || true'
        }
    }
}