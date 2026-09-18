pipeline {
    agent any

    tools {
        
        maven 'maven-3.9.12'
    }

    environment {
        
        GITHUB_REPO_URL = 'https://github.com/achintyah9895/Java-Devops.git'
        BRANCH_NAME     = 'main' 

        DOCKER_USER     = 'jishnudev9895'
        IMAGE_NAME      = 'java-webapp'
        IMAGE_TAG       = "${env.BUILD_NUMBER}" // Uses Jenkins build number as tag
        DOCKER_CRED_ID  = 'dockerHub-creds' // Required for pushing
    }

    stages {
        stage('Pull from Public GitHub') {
            steps {
                git url: "${GITHUB_REPO_URL}",
                    branch: "${BRANCH_NAME}"
            }
        }

        stage('Maven Build') {
            steps {
                echo 'Running Maven clean package...'
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    // Builds the image using the Dockerfile in the root workspace
                    dockerImage = docker.build("${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}")
                    
                    // Creates a secondary 'latest' tag
                    sh "docker tag ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Authenticates securely to Docker Hub and pushes both tags
                    docker.withRegistry('https://docker.io', DOCKER_CRED_ID) {
                        echo "Pushing build-specific tag..."
                        dockerImage.push()
                        
                        echo "Pushing latest tag..."
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Cleanup Local Images') {
            steps {
                // Removes local image copies to save disk space on your Jenkins node
                sh "docker rmi ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker rmi ${DOCKER_USER}/${IMAGE_NAME}:latest"
            }
        }
    }

    post {
        always {
            cleanWs() // Completely clears the workspace directory after the run
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
