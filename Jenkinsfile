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
        DOCKER_CRED_ID  = 'dockerHub-creds' 

        MINIKUBE_HOST   = '172.31.42.27'
        MINIKUBE_USER   = 'ubuntu'
        MINIKUBE_CRED_ID = 'SingaporeKey'
    }

    stages {
        stage('Pull from Public GitHub') {
            steps {
                git url: "${GITHUB_REPO_URL}",
                    branch: "${BRANCH_NAME}"
            }
        }
	stage('Trivy Filesystem Scan') {
            steps {
	           sh "trivy fs --exit-code 1 --severity HIGH,CRITICAL ."
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

	stage('Trivy Image Scan') {
            steps {
                sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
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
         stage('Deploy to Minikube') {
            steps {
                script {
        
                    sh """
                        sed -i 's/IMAGE_TAG/${IMAGE_TAG}/g' k8s/deploy.yaml
                    """
        
                    sshagent(credentials: ["${MINIKUBE_CRED_ID}"]) {
        
                        sh """                          
                            scp -o StrictHostKeyChecking=no k8s/*.yaml ${MINIKUBE_USER}@${MINIKUBE_HOST}:/home/ubuntu
        
                            ssh -o StrictHostKeyChecking=no ${MINIKUBE_USER}@${MINIKUBE_HOST} '
                                    kubectl apply -f /home/ubuntu/deploy.yaml &&
                                    kubectl apply -f /home/ubuntu/service.yaml
                                '
                        """
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
