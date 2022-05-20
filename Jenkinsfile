pipeline {
      environment {
        AWS_ACCOUNT_ID="394062158652"
        AWS_DEFAULT_REGION="us-east-1" 
        IMAGE_REPO_NAME="demo"
        IMAGE_TAG="$BUILD_NUMBER"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        DOCKERHUB_CREDENTIALS=credentials('docker_hub')
        TASK_FAMILY="demo"
        ECS_CLUSTER="demo"
        SERVICE_NAME="svc"
    }
agent any
    
    stages {
        stage('Checkout and war genrate') {
             agent { docker { image 'maven:3.3.3' } }
            steps {
                
                // Get some code from a GitHub repository
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/dardakunal/java.git'

                // Run Maven on a Unix agent.
                sh "mvn --version"
                sh "mvn clean package"
                 }
             post {
            // If Maven was able to run the tests, even if some of the test
            // failed, record the test results and archive the jar file.
            success {
               junit '**/target/surefire-reports/*.xml'
            }
         }
    
        }
        stage('Build Docker img') { 
            steps { 
                script{
                 sh "docker build -t demo:$IMAGE_TAG ."
                }
            }
        }   
        
        stage('Push to ECR') {

            steps {
                sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                       sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}"
                       sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
            }
        }
        
        stage('Deploy'){
            steps {
               sh '''
                ECR_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_FAMILY" --region "$AWS_DEFAULT_REGION")
NEW_TASK_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$ECR_IMAGE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities)')
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
