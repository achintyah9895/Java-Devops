pipeline {
    agent any

    tools {
        maven 'maven-3.9'
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
                        dockerImage = docker.build("${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}")
                        sh "docker tag ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_USER}/${IMAGE_NAME}:latest"
                         
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withDockerRegistry( 
                        credentialsId: "${DOCKER_CRED_ID}",
                         url: 'https://index.docker.io/v1/' ) 
                                { 
                                  sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}" 
                                  sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:latest" 
                      }
                }
            }
        }

        stage('Cleanup Local Images') {
            steps {
                
                sh "docker rmi ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker rmi ${DOCKER_USER}/${IMAGE_NAME}:latest"
            }
        }
    }

    post {
        always {
            cleanWs() 
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
