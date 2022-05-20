pipeline {
    
	agent any
	
	
	
    environment {
        AWS_ACCOUNT_ID="394062158652"
        AWS_DEFAULT_REGION="us-east-1" 
        IMAGE_REPO_NAME="demo"
        IMAGE_TAG="$BUILD_NUMBER"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    //    DOCKERHUB_CREDENTIALS=credentials('docker_hub')
        TASK_FAMILY="demo"
        ECS_CLUSTER="demo"
        SERVICE_NAME="demo"
    }
	
    stages{
        stage('checkout') {
            steps{
                git branch: 'main', credentialsId: 'git', url: 'https://github.com/dardakunal/java.git'
            }
        }
        stage('CODE ANALYSIS with SONARQUBE'){
            tools { jdk 'java11' }
            steps {
               sh '''
               /opt/sonar-scanner/bin/sonar-scanner -Dsonar.projectKey=dardakunal_java  -Dsonar.host.url=https://sonarcloud.io \
               -Dsonar.login=900ed1bcb90aebd21aef1390af9acbdacba4adbe  -Dsonar.organization=demojava \
               -Dsonar.sources=src/  -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
               -Dsonar.junit.reportsPath=target/surefire-reports/ -Dsonar.jacoco.reportsPath=target/jacoco.exec \
               -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
               '''
            }
            post {
                success {
                    echo 'Sonar Analysis Done'
                    
                }
            }
        }
        
        stage('Build Project'){
            tools { jdk 'java8' }
            steps {
                sh '''
                mvn clean
                mvn clean package
                '''
            }
            post {
                success {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
            
        }
       
     stage('Build Docker img') { 
            steps { 
               
                 sh "docker build -t demo:$BUILD_NUMBER ."
               
            }
        }
     stage('Push to ECR') {

            steps {
                sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                       sh "docker tag ${IMAGE_REPO_NAME}:$BUILD_NUMBER ${REPOSITORY_URI}:$BUILD_NUMBER"
                       sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:$BUILD_NUMBER"
            }
        }
     stage('Deploy'){
            steps {
               sh '''
                ECR_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:$BUILD_NUMBER"
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_FAMILY" --region "$AWS_DEFAULT_REGION")
NEW_TASK_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$ECR_IMAGE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.registeredBy)| del(.registeredAt)| del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities)')
NEW_TASK_INFO=$(aws ecs register-task-definition --region "$AWS_DEFAULT_REGION" --cli-input-json "$NEW_TASK_DEFINTIION")
NEW_REVISION=$(echo $NEW_TASK_INFO | jq '.taskDefinition.revision')
aws ecs update-service --cluster ${ECS_CLUSTER} \
                       --service ${SERVICE_NAME} \
                       --task-definition ${TASK_FAMILY}:${NEW_REVISION}
                '''
                 }
        }     
     
    }


}
