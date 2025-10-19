# **Strapi Internship Tasks: From Local Setup to Automated Deployment**

[GitHub Repository](https://github.com/mrsid743/Internship-strapi-task7)

This repository documents the process of setting up, containerizing, deploying, and automating a Strapi application. The project covers local setup, Dockerization, orchestration with Docker Compose, infrastructure provisioning on AWS with Terraform, and setting up a CI/CD pipeline using GitHub Actions.

## **📋 Table of Contents**

* [Prerequisites](https://www.google.com/search?q=%23%EF%B8%8F-prerequisites)  
* [Task 1: Local Strapi Setup](https://www.google.com/search?q=%23-task-1-local-strapi-setup)  
* [Task 2: Dockerizing the Strapi Application](https://www.google.com/search?q=%23-task-2-dockerizing-the-strapi-application)  
* [Task 3: Multi-Container Setup with Docker Compose](https://www.google.com/search?q=%23-task-3-multi-container-setup-with-docker-compose)  
* [Task 4: Deploying to AWS EC2 with Terraform](https://www.google.com/search?q=%23-task-4-deploying-to-aws-ec2-with-terraform)  
* [Task 5: Automating Deployment with GitHub Actions (CI/CD)](https://www.google.com/search?q=%23-task-5-automating-deployment-with-github-actions-cicd)  
* [Task 6: Deploying to AWS ECS Fargate with Terraform](https://www.google.com/search?q=%23-task-6-deploying-to-aws-ecs-fargate-with-terraform)  
* [Task 7: Fully Automated CI/CD for ECS Fargate](https://www.google.com/search?q=%23-task-7-fully-automated-cicd-for-ecs-fargate)  
* [Task 8: Add CloudWatch Monitoring to ECS Deployment](https://www.google.com/search?q=%23-task-8-add-cloudwatch-monitoring-to-ecs-deployment)  
* [Task 9: Optimize Costs with Fargate Spot](https://www.google.com/search?q=%23-task-9-optimize-costs-with-fargate-spot)  
* [Task 10: Configure AWS Resources for Blue/Green Deployment](https://www.google.com/search?q=%23-task-10-configure-aws-resources-for-bluegreen-deployment)  
* [Task 11: Set up a GitHub Actions Workflow for Blue/Green Deployment](https://www.google.com/search?q=%23-task-11-set-up-a-github-actions-workflow-for-bluegreen-deployment)  
* [Task 12: Documentation: Docker Swarm: Architecture, AWS Setup, and Commands](https://www.google.com/search?q=%23-task-12-documentation-docker-swarm-architecture-aws-setup-and-commands)  
* [Task 13: Documentation: Unleash Feature Flag Integration in a Local React Application](https://www.google.com/search?q=%23-task-13-documentation-unleash-feature-flag-integration-in-a-local-react-application)  
* [Task 14: Documentation: Reducing Docker Image Size: A Guide to Faster Deployments and Lower Costs](https://www.google.com/search?q=%23-task-14-documentation-reducing-docker-image-size-a-guide-to-faster-deployments-and-lower-costs)  
* [Task 15: Documentation: A Comprehensive Analysis of the Kubernetes Orchestration Platform](https://www.google.com/search?q=%23-task-15-documentation-a-comprehensive-analysis-of-the-kubernetes-orchestration-platform)  
* [Task 16: Build a Kubernetes Cluster Locally with Minikube](https://www.google.com/search?q=%23-task-16-build-a-kubernetes-cluster-locally-with-minikube)  
* [Task 17: Resource Monitoring, Alerting, and Log Management Automation](https://www.google.com/search?q=%23-task-17-resource-monitoring-alerting-and-log-management-automation)

## **🛠️ Prerequisites**

Before you begin, ensure you have the following installed and configured:

* Node.js (v18 or later)  
* npm or yarn  
* Docker and Docker Compose  
* Terraform  
* An AWS Account with programmatic access (Access Key ID and Secret Access Key)  
* A Docker Hub Account  
* A GitHub Account  
* AWS CLI

## **✅ Task 1: Local Strapi Setup**

### **Steps**

1. Clone the Strapi Repository  
   You can create a new Strapi project using the create-strapi-app command.  
   npx create-strapi-app@latest my-strapi-project \--quickstart

2. **Navigate to the Project Directory**  
   cd my-strapi-project

3. Run Strapi in Development Mode  
   The \--quickstart flag will automatically start the development server. If it doesn't, use the following command:  
   npm run develop  
   \# or  
   yarn develop

4. Create Your First Admin User  
   Once the server starts, navigate to http://localhost:1337/admin. You'll be prompted to create the first administrator account. Fill in the details to access the Admin Panel.  
5. **Create a Sample Content Type**  
   * In the Admin Panel, go to **Content-Type Builder** \> **Create new collection type**.  
   * Enter a Display name (e.g., "Article").  
   * Add fields like title (Text) and content (Rich Text).  
   * Click **Save** and wait for the server to restart.  
   * You can now add content to your new "Article" collection type\!  
6. Push to GitHub  
   Initialize a Git repository, commit your changes, and push it to your GitHub account.  
   git init  
   git add .  
   git commit \-m "Initial Strapi setup"  
   git branch \-M main  
   git remote add origin \[https://github.com/\](https://github.com/)\<your-username\>/\<your-repo-name\>.git  
   git push \-u origin main

## **✅ Task 2: Dockerizing the Strapi Application**

### **Steps**

1. Create a Dockerfile  
   In the root of your Strapi project, create a file named Dockerfile with the following content:  
   \# Use the official Node.js 18 image as a base  
   FROM node:18-alpine

   \# Set the working directory inside the container  
   WORKDIR /opt/app

   \# Copy package.json and package-lock.json (or yarn.lock)  
   COPY ./package.json ./  
   COPY ./yarn.lock ./

   \# Install dependencies  
   RUN yarn install \--frozen-lockfile

   \# Copy the rest of the application source code  
   COPY ./ .

   \# Build the Strapi admin panel  
   ENV NODE\_ENV=production  
   RUN yarn build

   \# Expose the port Strapi runs on  
   EXPOSE 1337

   \# Start the Strapi application  
   CMD \["yarn", "start"\]

2. Build the Docker Image  
   Open your terminal in the project root and run the following command to build the image. Replace \<your-dockerhub-username\> with your actual Docker Hub username.  
   docker build \-t \<your-dockerhub-username\>/strapi-app .

3. Run the Docker Container  
   Run the container to test if the image works correctly.  
   docker run \-p 1337:1337 \<your-dockerhub-username\>/strapi-app

   You should now be able to access your Strapi application at http://localhost:1337.

## **✅ Task 3: Multi-Container Setup with Docker Compose**

### **Project Structure**

.  
├── nginx/  
│   └── nginx.conf  
├── src/  
│   └── (Your Strapi app files)  
├── .env  
├── docker-compose.yml  
└── Dockerfile

### **Steps**

1. Create docker-compose.yml  
   This file defines the services: strapi, postgres, and nginx.  
   version: '3.8'

   services:  
     strapi:  
       container\_name: strapi  
       build: .  
       image: \<your-dockerhub-username\>/strapi-app  
       environment:  
         DATABASE\_CLIENT: postgres  
         DATABASE\_HOST: postgres  
         DATABASE\_PORT: 5432  
         DATABASE\_NAME: ${DATABASE\_NAME}  
         DATABASE\_USERNAME: ${DATABASE\_USERNAME}  
         DATABASE\_PASSWORD: ${DATABASE\_PASSWORD}  
         HOST: 0.0.0.0  
         PORT: 1337  
       volumes:  
         \- ./src:/opt/app  
       ports:  
         \- "1337:1337"  
       depends\_on:  
         \- postgres  
       networks:  
         \- strapi-net

     postgres:  
       container\_name: postgres  
       image: postgres:14-alpine  
       environment:  
         POSTGRES\_DB: ${DATABASE\_NAME}  
         POSTGRES\_USER: ${DATABASE\_USERNAME}  
         POSTGRES\_PASSWORD: ${DATABASE\_PASSWORD}  
       volumes:  
         \- strapi-data:/var/lib/postgresql/data  
       ports:  
         \- "5432:5432"  
       networks:  
         \- strapi-net

     nginx:  
       container\_name: nginx  
       image: nginx:1.21-alpine  
       volumes:  
         \- ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf  
       ports:  
         \- "80:80"  
       depends\_on:  
         \- strapi  
       networks:  
         \- strapi-net

   volumes:  
     strapi-data:

   networks:  
     strapi-net:  
       driver: bridge

2. Configure Nginx as a Reverse Proxy  
   Create nginx/nginx.conf to forward requests from port 80 to the Strapi container on port 1337\.  
   server {  
       listen 80;  
       server\_name localhost;

       location / {  
           proxy\_pass http://strapi:1337;  
           proxy\_set\_header Host $host;  
           proxy\_set\_header X-Real-IP $remote\_addr;  
           proxy\_set\_header X-Forwarded-For $proxy\_add\_x\_forwarded\_for;  
           proxy\_set\_header X-Forwarded-Proto $scheme;  
       }  
   }

3. **Create .env file for credentials.**  
   DATABASE\_NAME=strapi\_db  
   DATABASE\_USERNAME=strapi\_user  
   DATABASE\_PASSWORD=strapi\_password

4. Run the Environment  
   From your project root, run:  
   docker-compose up \--build

   You can now access the Strapi admin panel at http://localhost/admin. 🎉

## **✅ Task 4: Deploying to AWS EC2 with Terraform**

### **Steps**

1. Push Your Docker Image to Docker Hub  
   First, log in and push the image you built in Task 2\.  
   docker login  
   docker push \<your-dockerhub-username\>/strapi-app:latest

2. Create Terraform Configuration Files  
   Create a file named main.tf. This file will define the AWS provider, a security group to allow HTTP and SSH traffic, and the EC2 instance itself.  
   terraform {  
     required\_providers {  
       aws \= {  
         source  \= "hashicorp/aws"  
         version \= "\~\> 5.0"  
       }  
     }  
   }

   provider "aws" {  
     region \= "us-east-1" \# Or your preferred region  
   }

   resource "aws\_security\_group" "strapi\_sg" {  
     name        \= "strapi-sg"  
     description \= "Allow HTTP and SSH inbound traffic"

     ingress {  
       from\_port   \= 80  
       to\_port     \= 80  
       protocol    \= "tcp"  
       cidr\_blocks \= \["0.0.0.0/0"\]  
     }

     ingress {  
       from\_port   \= 22  
       to\_port     \= 22  
       protocol    \= "tcp"  
       cidr\_blocks \= \["0.0.0.0/0"\] \# For production, restrict this to your IP  
     }

     egress {  
       from\_port   \= 0  
       to\_port     \= 0  
       protocol    \= "-1"  
       cidr\_blocks \= \["0.0.0.0/0"\]  
     }  
   }

   resource "aws\_instance" "strapi\_server" {  
     ami           \= "ami-0c55b159cbfafe1f0" \# Amazon Linux 2 AMI (us-east-1)  
     instance\_type \= "t2.micro"  
     security\_groups \= \[aws\_security\_group.strapi\_sg.name\]

     user\_data \= \<\<-EOF  
                 \#\!/bin/bash  
                 sudo yum update \-y  
                 sudo yum install \-y docker  
                 sudo service docker start  
                 sudo usermod \-a \-G docker ec2-user  
                 docker pull \<your-dockerhub-username\>/strapi-app:latest  
                 docker run \-d \-p 80:1337 \--restart always \<your-dockerhub-username\>/strapi-app:latest  
                 EOF

     tags \= {  
       Name \= "Strapi-Instance"  
     }  
   }

   output "public\_ip" {  
     value \= aws\_instance.strapi\_server.public\_ip  
   }

3. Initialize and Apply Terraform  
   Run the following commands in the directory containing your main.tf file.  
   \# Initialize Terraform  
   terraform init

   \# Preview the changes  
   terraform plan

   \# Apply the changes to create the infrastructure  
   terraform apply \--auto-approve

4. Verify Deployment  
   After terraform apply completes, it will output the public IP address of the EC2 instance. Access your Strapi app by navigating to http://\<your-ec2-public-ip\>.

## **✅ Task 5: Automating Deployment with GitHub Actions (CI/CD)**

### **Prerequisites**

Add the following secrets to your GitHub repository (**Settings \> Secrets and variables \> Actions**):

* AWS\_ACCESS\_KEY\_ID: Your AWS access key.  
* AWS\_SECRET\_ACCESS\_KEY: Your AWS secret key.  
* DOCKERHUB\_USERNAME: Your Docker Hub username.  
* DOCKERHUB\_TOKEN: Your Docker Hub access token.

### **1\. CI Workflow: Build and Push Docker Image**

Create .github/workflows/ci.yml to automatically build and push the Docker image to Docker Hub.

name: CI \- Build and Push Docker Image

on:  
  push:  
    branches:  
      \- main

jobs:  
  build-and-push:  
    runs-on: ubuntu-latest  
    outputs:  
      image\_tag: ${{ steps.meta.outputs.version }}  
    steps:  
      \- name: Checkout code  
        uses: actions/checkout@v3

      \- name: Log in to Docker Hub  
        uses: docker/login-action@v2  
        with:  
          username: ${{ secrets.DOCKERHUB\_USERNAME }}  
          password: ${{ secrets.DOCKERHUB\_TOKEN }}

      \- name: Extract metadata (tags, labels) for Docker  
        id: meta  
        uses: docker/metadata-action@v4  
        with:  
          images: ${{ secrets.DOCKERHUB\_USERNAME }}/strapi-app  
          tags: |  
            type=sha,prefix=,format=short

      \- name: Build and push Docker image  
        uses: docker/build-push-action@v4  
        with:  
          context: .  
          push: true  
          tags: ${{ steps.meta.outputs.tags }}  
          labels: ${{ steps.meta.outputs.labels }}

### **2\. CD Workflow: Deploy with Terraform**

Create .github/workflows/terraform.yml to manually trigger the deployment.

name: CD \- Deploy to EC2 with Terraform

on:  
  workflow\_dispatch:  
    inputs:  
      image\_tag:  
        description: 'Image tag to deploy (e.g., latest or commit SHA)'  
        required: true  
        default: 'latest'

jobs:  
  deploy:  
    runs-on: ubuntu-latest  
    steps:  
      \- name: Checkout code  
        uses: actions/checkout@v3

      \- name: Configure AWS Credentials  
        uses: aws-actions/configure-aws-credentials@v2  
        with:  
          aws-access-key-id: ${{ secrets.AWS\_ACCESS\_KEY\_ID }}  
          aws-secret-access-key: ${{ secrets.AWS\_SECRET\_ACCESS\_KEY }}  
          aws-region: us-east-1

      \- name: Setup Terraform  
        uses: hashicorp/setup-terraform@v2

      \- name: Terraform Init  
        run: terraform init

      \- name: Terraform Plan  
        run: terraform plan \-var="image\_tag=${{ github.event.inputs.image\_tag }}"

      \- name: Terraform Apply  
        run: terraform apply \-auto-approve \-var="image\_tag=${{ github.event.inputs.image\_tag }}"

### **Update main.tf for Dynamic Image Tags**

Modify your main.tf to accept the image tag as a variable.

\# ... (provider and security group config) ...

variable "image\_tag" {  
  description \= "The Docker image tag to deploy"  
  type        \= string  
  default     \= "latest"  
}

resource "aws\_instance" "strapi\_server" {  
  \# ... (ami, instance\_type, etc.) ...

  user\_data \= \<\<-EOF  
                \#\!/bin/bash  
                sudo yum update \-y  
                sudo yum install \-y docker  
                sudo service docker start  
                sudo usermod \-a \-G docker ec2-user  
                docker pull \<your-dockerhub-username\>/strapi-app:${var.image\_tag}  
                \# Stop and remove old container if it exists  
                docker stop $(docker ps \-q \--filter "ancestor=\<your-dockerhub-username\>/strapi-app") || true  
                docker rm $(docker ps \-aq \--filter "ancestor=\<your-dockerhub-username\>/strapi-app") || true  
                docker run \-d \-p 80:1337 \--restart always \<your-dockerhub-username\>/strapi-app:${var.image\_tag}  
                EOF  
    
  \# ... (tags) ...  
}

\# ... (output) ...

Now, your complete CI/CD pipeline is set up\! 🚀

## **✅ Task 6: Deploying to AWS ECS Fargate with Terraform**

### **Steps**

1. Create an ECR Repository with Terraform  
   First, we need a private registry to store our Docker image. Create a file named ecr.tf and add the following code to define an AWS ECR repository.  
   resource "aws\_ecr\_repository" "strapi\_ecr\_repo" {  
     name                 \= "strapi-app"  
     image\_tag\_mutability \= "MUTABLE"

     image\_scanning\_configuration {  
       scan\_on\_push \= true  
     }  
   }

2. Build and Push the Docker Image to ECR  
   Before creating the rest of the infrastructure, you must push your application's Docker image to the new ECR repository.  
   First, apply the Terraform configuration to create the repository:  
   terraform init  
   terraform apply \-target=aws\_ecr\_repository.strapi\_ecr\_repo \--auto-approve

   Next, run the following commands to authenticate Docker with ECR, then build, tag, and push your image.  
   \# Set environment variables for your AWS Account ID and Region  
   export AWS\_ACCOUNT\_ID=$(aws sts get-caller-identity \--query Account \--output text)  
   export AWS\_REGION=us-east-1 \# Or your preferred region  
   export ECR\_REPO\_URI="${AWS\_ACCOUNT\_ID}.dkr.ecr.${AWS\_REGION}\[.amazonaws.com/strapi-app\](https://.amazonaws.com/strapi-app)"

   \# 1\. Authenticate Docker to your ECR registry  
   aws ecr get-login-password \--region $AWS\_REGION | docker login \--username AWS \--password-stdin $ECR\_REPO\_URI

   \# 2\. Build the Docker image (ensure Dockerfile is in the current directory)  
   docker build \-t strapi-app .

   \# 3\. Tag the image for ECR  
   docker tag strapi-app:latest $ECR\_REPO\_URI:latest

   \# 4\. Push the image to ECR  
   docker push $ECR\_REPO\_URI:latest

3. Write Terraform Code for ECS Fargate Infrastructure  
   Create a new file, ecs.tf, to define the cluster, load balancer, security groups, task definition, and service. This configuration uses the default VPC for simplicity.  
   \# Fetch default VPC and subnets to deploy resources into them  
   data "aws\_vpc" "default" {  
     default \= true  
   }

   data "aws\_subnets" "default" {  
     filter {  
       name   \= "vpc-id"  
       values \= \[data.aws\_vpc.default.id\]  
     }  
   }

   \# Security Group for the Application Load Balancer (allows public HTTP traffic)  
   resource "aws\_security\_group" "alb\_sg" {  
     name        \= "strapi-alb-sg"  
     description \= "Allow HTTP inbound traffic for ALB"  
     vpc\_id      \= data.aws\_vpc.default.id

     ingress {  
       from\_port   \= 80  
       to\_port     \= 80  
       protocol    \= "tcp"  
       cidr\_blocks \= \["0.0.0.0/0"\]  
     }

     egress {  
       from\_port   \= 0  
       to\_port     \= 0  
       protocol    \= "-1"  
       cidr\_blocks \= \["0.0.0.0/0"\]  
     }  
   }

   \# Security Group for the Fargate Service (only allows traffic from our ALB)  
   resource "aws\_security\_group" "fargate\_sg" {  
     name        \= "strapi-fargate-sg"  
     description \= "Allow inbound traffic from ALB for Fargate"  
     vpc\_id      \= data.aws\_vpc.default.id

     ingress {  
       from\_port       \= 1337  
       to\_port         \= 1337  
       protocol        \= "tcp"  
       security\_groups \= \[aws\_security\_group.alb\_sg.id\]  
     }

     egress {  
       from\_port   \= 0  
       to\_port     \= 0  
       protocol    \= "-1"  
       cidr\_blocks \= \["0.0.0.0/0"\]  
     }  
   }

   \# Application Load Balancer (ALB) to route traffic to the service  
   resource "aws\_lb" "strapi\_alb" {  
     name               \= "strapi-alb"  
     internal           \= false  
     load\_balancer\_type \= "application"  
     security\_groups    \= \[aws\_security\_group.alb\_sg.id\]  
     subnets            \= data.aws\_subnets.default.ids  
   }

   resource "aws\_lb\_target\_group" "strapi\_tg" {  
     name        \= "strapi-tg"  
     port        \= 1337  
     protocol    \= "HTTP"  
     vpc\_id      \= data.aws\_vpc.default.id  
     target\_type \= "ip"  
     health\_check {  
       path                \= "/\_health"  
       healthy\_threshold   \= 2  
       unhealthy\_threshold \= 2  
       timeout             \= 3  
       interval            \= 30  
     }  
   }

   resource "aws\_lb\_listener" "strapi\_listener" {  
     load\_balancer\_arn \= aws\_lb.strapi\_alb.arn  
     port              \= 80  
     protocol          \= "HTTP"

     default\_action {  
       type             \= "forward"  
       target\_group\_arn \= aws\_lb\_target\_group.strapi\_tg.arn  
     }  
   }

   \# ECS Cluster  
   resource "aws\_ecs\_cluster" "strapi\_cluster" {  
     name \= "strapi-cluster"  
   }

   \# ECS Task Definition  
   resource "aws\_ecs\_task\_definition" "strapi\_task" {  
     family                   \= "strapi-task"  
     network\_mode             \= "awsvpc"  
     requires\_compatibilities \= \["FARGATE"\]  
     cpu                      \= "256"  \# 0.25 vCPU  
     memory                   \= "512"  \# 512 MB  
     execution\_role\_arn       \= aws\_iam\_role.ecs\_task\_execution\_role.arn

     container\_definitions \= jsonencode(\[  
       {  
         name      \= "strapi"  
         image     \= "${aws\_ecr\_repository.strapi\_ecr\_repo.repository\_url}:latest"  
         essential \= true  
         portMappings \= \[  
           {  
             containerPort \= 1337  
             hostPort      \= 1337  
           }  
         \]  
         \# NOTE: For a production setup, database credentials should be injected  
         \# securely using AWS Secrets Manager, not hardcoded.  
         environment \= \[  
           { name \= "HOST", value \= "0.0.0.0" },  
           { name \= "PORT", value \= "1337" }  
         \]  
       }  
     \])  
   }

   \# ECS Service  
   resource "aws\_ecs\_service" "strapi\_service" {  
     name            \= "strapi-service"  
     cluster         \= aws\_ecs\_cluster.strapi\_cluster.id  
     task\_definition \= aws\_ecs\_task\_definition.strapi\_task.arn  
     launch\_type     \= "FARGATE"  
     desired\_count   \= 1

     network\_configuration {  
       subnets         \= data.aws\_subnets.default.ids  
       security\_groups \= \[aws\_security\_group.fargate\_sg.id\]  
       assign\_public\_ip \= true \# Required for Fargate to pull the ECR image  
     }

     load\_balancer {  
       target\_group\_arn \= aws\_lb\_target\_group.strapi\_tg.arn  
       container\_name   \= "strapi"  
       container\_port   \= 1337  
     }

     depends\_on \= \[aws\_lb\_listener.strapi\_listener\]  
   }

   \# IAM Role for ECS Task Execution  
   resource "aws\_iam\_role" "ecs\_task\_execution\_role" {  
     name \= "ecs\_task\_execution\_role"  
     assume\_role\_policy \= jsonencode({  
       Version \= "2012-10-17",  
       Statement \= \[{  
         Action \= "sts:AssumeRole",  
         Effect \= "Allow",  
         Principal \= {  
           Service \= "ecs-tasks.amazonaws.com"  
         }  
       }\]  
     })  
   }

   resource "aws\_iam\_role\_policy\_attachment" "ecs\_task\_execution\_role\_policy" {  
     role       \= aws\_iam\_role.ecs\_task\_execution\_role.name  
     policy\_arn \= "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"  
   }

   \# Output the public URL of the ALB  
   output "strapi\_url" {  
     description \= "Public URL of the Strapi application"  
     value       \= "http://${aws\_lb.strapi\_alb.dns\_name}"  
   }

4. Initialize and Deploy the Infrastructure  
   Now, run Terraform to deploy the entire ECS stack.  
   terraform init  
   terraform plan  
   terraform apply \--auto-approve

5. Verify Deployment  
   Once terraform apply is complete, it will output the strapi\_url. Navigate to this URL in your browser to access your Strapi application, now running scalably on ECS Fargate\!

## **✅ Task 7: Fully Automated CI/CD for ECS Fargate**

### **Prerequisites**

* Ensure your ECS Fargate infrastructure from Task 6 is deployed and running.  
* Add the following secrets to your GitHub repository (**Settings \> Secrets and variables \> Actions**):  
  * AWS\_ACCESS\_KEY\_ID: Your AWS access key.  
  * AWS\_SECRET\_ACCESS\_KEY: Your AWS secret key.

### **GitHub Actions Workflow**

Create a new workflow file at .github/workflows/deploy-to-ecs.yml. This single workflow handles the entire CI/CD process.

name: CI/CD \- Build and Deploy to ECS Fargate

on:  
  push:  
    branches:  
      \- main

env:  
  AWS\_REGION: us-east-1              \# Your AWS Region  
  ECR\_REPOSITORY: strapi-app         \# Your ECR repository name from Task 6  
  ECS\_SERVICE: strapi-service        \# Your ECS service name from ecs.tf  
  ECS\_CLUSTER: strapi-cluster        \# Your ECS cluster name from ecs.tf  
  ECS\_TASK\_DEFINITION: strapi-task   \# Your ECS task definition family from ecs.tf  
  CONTAINER\_NAME: strapi             \# The container name defined in your task definition

jobs:  
  deploy:  
    name: Build and Deploy  
    runs-on: ubuntu-latest  
    steps:  
      \- name: Checkout code  
        uses: actions/checkout@v3

      \- name: Configure AWS Credentials  
        uses: aws-actions/configure-aws-credentials@v2  
        with:  
          aws-access-key-id: ${{ secrets.AWS\_ACCESS\_KEY\_ID }}  
          aws-secret-access-key: ${{ secrets.AWS\_SECRET\_ACCESS\_KEY }}  
          aws-region: ${{ env.AWS\_REGION }}

      \- name: Login to Amazon ECR  
        id: login-ecr  
        uses: aws-actions/amazon-ecr-login@v1

      \- name: Build, tag, and push image to Amazon ECR  
        id: build-image  
        env:  
          ECR\_REGISTRY: ${{ steps.login-ecr.outputs.registry }}  
          IMAGE\_TAG: ${{ github.sha }}  
        run: |  
          docker build \-t $ECR\_REGISTRY/$ECR\_REPOSITORY:$IMAGE\_TAG .  
          docker push $ECR\_REGISTRY/$ECR\_REPOSITORY:$IMAGE\_TAG  
          \# Set the image URI as an output for the next step  
          echo "image=$ECR\_REGISTRY/$ECR\_REPOSITORY:$IMAGE\_TAG" \>\> $GITHUB\_OUTPUT

      \- name: Download current task definition  
        run: |  
          aws ecs describe-task-definition \--task-definition ${{ env.ECS\_TASK\_DEFINITION }} \--query taskDefinition \> task-definition.json

      \- name: Fill in the new image ID in the Amazon ECS task definition  
        id: task-def  
        uses: aws-actions/amazon-ecs-render-task-definition@v1  
        with:  
          task-definition: task-definition.json  
          container-name: ${{ env.CONTAINER\_NAME }}  
          image: ${{ steps.build-image.outputs.image }}

      \- name: Deploy Amazon ECS task definition  
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1  
        with:  
          task-definition: ${{ steps.task-def.outputs.task-definition }}  
          service: ${{ env.ECS\_SERVICE }}  
          cluster: ${{ env.ECS\_CLUSTER }}  
          wait-for-service-stability: true

### **How It Works**

* **Trigger**: The workflow starts automatically whenever you push a commit to the main branch.  
* **AWS & ECR Login**: It securely logs into your AWS account and ECR registry using the provided GitHub Secrets.  
* **Build & Push**: It builds a new Docker image from your Dockerfile and tags it with the unique commit SHA. This ensures every version is traceable. The new image is then pushed to your ECR repository.  
* **Update Task Definition**: The workflow fetches the latest active task definition for your service. It then creates a new revision of this definition in memory, replacing the old image URI with the URI of the new image it just pushed.  
* **Deploy New Revision**: Finally, it registers this new task definition with ECS and updates the strapi-service, which triggers a new deployment. ECS handles the rolling update gracefully, draining old tasks and starting new ones with the updated image. The wait-for-service-stability: true flag ensures the workflow only succeeds if the new version deploys successfully.

### **Verification**

To verify, simply make a small change to your Strapi application, commit it, and push it to the main branch. Go to the "Actions" tab in your GitHub repository to watch the workflow run. Once it completes, your changes will be live at the ALB URL provided by your Terraform output.

## **✅ Task 8: Add CloudWatch Monitoring to ECS Deployment**

### **Prerequisites**

* A functioning ECS Fargate deployment as set up in Task 6\.  
* Your Terraform code for the ECS infrastructure (ecs.tf).

### **Steps**

1. Update Terraform to Create a CloudWatch Log Group  
   Add the following resource to your ecs.tf file. This creates a dedicated log group where all logs from your Strapi container will be sent.  
   \# Add this to ecs.tf  
   resource "aws\_cloudwatch\_log\_group" "strapi\_logs" {  
     name \= "/ecs/strapi"

     tags \= {  
       Application \= "Strapi"  
       Environment \= "Production"  
     }  
   }

2. Update the ECS Task Definition to Send Logs  
   Modify the aws\_ecs\_task\_definition resource in ecs.tf. Specifically, you need to add the logConfiguration block inside the container\_definitions. This tells the ECS agent to use the awslogs driver and send logs to the group you just created.  
   \# Modify this existing resource in ecs.tf  
   resource "aws\_ecs\_task\_definition" "strapi\_task" {  
     family                   \= "strapi-task"  
     network\_mode             \= "awsvpc"  
     requires\_compatibilities \= \["FARGATE"\]  
     cpu                      \= "256"  
     memory                   \= "512"  
     execution\_role\_arn       \= aws\_iam\_role.ecs\_task\_execution\_role.arn

     container\_definitions \= jsonencode(\[  
       {  
         name      \= "strapi"  
         image     \= "${aws\_ecr\_repository.strapi\_ecr\_repo.repository\_url}:latest"  
         essential \= true  
         portMappings \= \[  
           {  
             containerPort \= 1337  
             hostPort      \= 1337  
           }  
         \]  
         \# \--- Add this logConfiguration block \---  
         logConfiguration \= {  
           logDriver \= "awslogs"  
           options \= {  
             "awslogs-group"         \= aws\_cloudwatch\_log\_group.strapi\_logs.name  
             "awslogs-region"        \= "us-east-1" \# Or your AWS region  
             "awslogs-stream-prefix" \= "ecs"  
           }  
         }  
         \# \------------------------------------  
         environment \= \[  
           { name \= "HOST", value \= "0.0.0.0" },  
           { name \= "PORT", value \= "1337" }  
         \]  
       }  
     \])  
   }

3. (Optional) Create a CloudWatch Alarm for High CPU  
   To proactively monitor performance, you can add alarms. Add the following resource to ecs.tf to create an alarm that triggers if the average CPU utilization of the ECS service exceeds 75% for 5 minutes.  
   \# Add this to ecs.tf for proactive monitoring  
   resource "aws\_cloudwatch\_metric\_alarm" "high\_cpu\_alarm" {  
     alarm\_name          \= "strapi-high-cpu-utilization"  
     comparison\_operator \= "GreaterThanOrEqualToThreshold"  
     evaluation\_periods  \= "1"  
     metric\_name         \= "CPUUtilization"  
     namespace           \= "AWS/ECS"  
     period              \= "300" \# 5 minutes  
     statistic           \= "Average"  
     threshold           \= "75"  
     alarm\_description   \= "This alarm triggers if the Strapi service CPU utilization is over 75%."

     dimensions \= {  
       ClusterName \= aws\_ecs\_cluster.strapi\_cluster.name  
       ServiceName \= aws\_ecs\_service.strapi\_service.name  
     }

     \# In a real-world scenario, you would configure an action,  
     \# like sending a notification to an SNS topic.  
     \# alarm\_actions \= \[aws\_sns\_topic.your\_topic.arn\]  
   }

4. Apply and Verify the Monitoring Setup  
   Run terraform apply to create the new CloudWatch resources and update your ECS task definition. Terraform will automatically register a new revision and trigger a service deployment.  
   terraform plan  
   terraform apply \--auto-approve

### **How to View Logs and Metrics**

* **To View Logs**:  
  1. Go to the AWS CloudWatch console.  
  2. In the navigation pane, click on **Log groups**.  
  3. Find and click on the /ecs/strapi log group.  
  4. You will see log streams from your running tasks. Click on one to view the application logs in real-time.  
* **To View Metrics**:  
  1. Go to the AWS CloudWatch console and click on **All metrics**.  
  2. In the AWS/ECS namespace, select "Per-Service Metrics".  
  3. Find metrics like CPUUtilization and MemoryUtilization for your cluster and service to view performance graphs.  
  4. Alternatively, go to the ECS console, select your cluster, and click on the "Metrics" tab for a pre-built dashboard.

## **✅ Task 9: Optimize Costs with Fargate Spot**

**Objective**: Modify the existing ECS Fargate deployment to use Fargate Spot instances for running tasks, significantly reducing compute costs. We will configure a capacity provider strategy that prioritizes Spot while keeping on-demand Fargate as a fallback for reliability.

### **Prerequisites**

* A fully functional ECS Fargate deployment as configured in Task 8\.

### **Steps**

1. Update the ECS Cluster to Use Capacity Providers  
   Modify the aws\_ecs\_cluster resource in your ecs.tf file and add a new aws\_ecs\_cluster\_capacity\_providers resource. This defines Fargate and Fargate Spot as the available capacity providers for the cluster.  
   \# Modify this existing resource in ecs.tf  
   resource "aws\_ecs\_cluster" "strapi\_cluster" {  
     name \= "strapi-cluster"

     setting {  
       name  \= "containerInsights"  
       value \= "enabled"  
     }  
   }

   \# Add this new resource to ecs.tf  
   resource "aws\_ecs\_cluster\_capacity\_providers" "strapi\_cluster\_providers" {  
     cluster\_name \= aws\_ecs\_cluster.strapi\_cluster.name

     capacity\_providers \= \["FARGATE", "FARGATE\_SPOT"\]

     default\_capacity\_provider\_strategy {  
       capacity\_provider \= "FARGATE\_SPOT"  
       weight            \= 1  
     }  
   }

2. Update the ECS Service to Use the Spot Strategy  
   Now, modify the aws\_ecs\_service resource in ecs.tf. The key change is to remove the launch\_type argument and replace it with a capacity\_provider\_strategy. This tells the service to prioritize Fargate Spot.  
   \# Modify this existing resource in ecs.tf  
   resource "aws\_ecs\_service" "strapi\_service" {  
     name            \= "strapi-service"  
     cluster         \= aws\_ecs\_cluster.strapi\_cluster.id  
     task\_definition \= aws\_ecs\_task\_definition.strapi\_task.arn  
     desired\_count   \= 1  
     \# REMOVE the launch\_type \= "FARGATE" line

     \# ADD a capacity provider strategy block to prioritize SPOT  
     capacity\_provider\_strategy {  
       capacity\_provider \= "FARGATE\_SPOT"  
       weight            \= 1  
     }

     network\_configuration {  
       subnets         \= data.aws\_subnets.default.ids  
       security\_groups \= \[aws\_security\_group.fargate\_sg.id\]  
       assign\_public\_ip \= true  
     }

     load\_balancer {  
       target\_group\_arn \= aws\_lb\_target\_group.strapi\_tg.arn  
       container\_name   \= "strapi"  
       container\_port   \= 1337  
     }

     depends\_on \= \[aws\_lb\_listener.strapi\_listener, aws\_ecs\_cluster\_capacity\_providers.strapi\_cluster\_providers\]  
   }

   **Note on Strategy**: This simple strategy tells ECS to always try to place tasks on FARGATE\_SPOT first. If Spot capacity is unavailable, ECS will automatically use on-demand FARGATE because it is registered with the cluster.  
3. Apply and Verify the Changes  
   Run terraform apply to update your ECS cluster and service configuration.  
   terraform plan  
   terraform apply \--auto-approve

### **How to Verify**

1. Navigate to the AWS ECS Console and select your cluster.  
2. Click on your strapi-service.  
3. Go to the **Tasks** tab.  
4. Click on a running task and look at the **Capacity provider** field in the configuration details. It should now show FARGATE\_SPOT.

## **✅ Task 10: Configure AWS resources for Blue/Green deployment of the Strapi app**

This task modifies our existing Terraform setup to support a blue/green deployment strategy managed by AWS CodeDeploy. This approach minimizes downtime and risk by shifting traffic incrementally to a new version of the application.

### **Steps**

1. Update the ALB and Create a Second Target Group  
   In ecs.tf, we need two target groups (blue and green) and a second listener rule for test traffic. The production listener will point to the blue group initially.  
   \# Modify ecs.tf

   \# Blue Target Group (current production)  
   resource "aws\_lb\_target\_group" "strapi\_blue\_tg" {  
     name        \= "strapi-blue-tg"  
     port        \= 1337  
     protocol    \= "HTTP"  
     vpc\_id      \= data.aws\_vpc.default.id  
     target\_type \= "ip"  
     health\_check {  
       path \= "/\_health"  
     }  
   }

   \# Green Target Group (for new versions)  
   resource "aws\_lb\_target\_group" "strapi\_green\_tg" {  
     name        \= "strapi-green-tg"  
     port        \= 1337  
     protocol    \= "HTTP"  
     vpc\_id      \= data.aws\_vpc.default.id  
     target\_type \= "ip"  
     health\_check {  
       path \= "/\_health"  
     }  
   }

   \# Production Listener (Port 80\) \-\> Points to Blue TG  
   resource "aws\_lb\_listener" "strapi\_prod\_listener" {  
     load\_balancer\_arn \= aws\_lb.strapi\_alb.arn  
     port              \= 80  
     protocol          \= "HTTP"

     default\_action {  
       type             \= "forward"  
       target\_group\_arn \= aws\_lb\_target\_group.strapi\_blue\_tg.arn  
     }  
   }

   \# Test Listener (e.g., Port 8080\) \-\> Points to Green TG for testing before traffic shift  
   resource "aws\_lb\_listener" "strapi\_test\_listener" {  
     load\_balancer\_arn \= aws\_lb.strapi\_alb.arn  
     port              \= 8080  
     protocol          \= "HTTP"

     default\_action {  
       type             \= "forward"  
       target\_group\_arn \= aws\_lb\_target\_group.strapi\_green\_tg.arn  
     }  
   }

2. Update the ECS Service for CodeDeploy  
   Modify the aws\_ecs\_service resource in ecs.tf to hand over deployment control to CodeDeploy.  
   \# Modify this existing resource in ecs.tf  
   resource "aws\_ecs\_service" "strapi\_service" {  
     name            \= "strapi-service"  
     cluster         \= aws\_ecs\_cluster.strapi\_cluster.id  
     task\_definition \= aws\_ecs\_task\_definition.strapi\_task.arn  
     desired\_count   \= 1  
     launch\_type     \= "FARGATE"

     \# This block tells ECS that CodeDeploy will manage deployments  
     deployment\_controller {  
       type \= "CODE\_DEPLOY"  
     }

     network\_configuration {  
       subnets         \= data.aws\_subnets.default.ids  
       security\_groups \= \[aws\_security\_group.fargate\_sg.id\]  
       assign\_public\_ip \= true  
     }

     \# The load\_balancer block is now managed by CodeDeploy's deployment group  
     \# and can be removed from here to avoid conflicts.  
     \# We keep a placeholder here during initial creation.  
     load\_balancer {  
        target\_group\_arn \= aws\_lb\_target\_group.strapi\_blue\_tg.arn  
        container\_name   \= "strapi"  
        container\_port   \= 1337  
     }

     \# We no longer depend on the listener directly  
     depends\_on \= \[aws\_lb.strapi\_alb\]  
   }

3. Create CodeDeploy Resources and IAM Role  
   Create a new file, codedeploy.tf, to define the CodeDeploy application, deployment group, and the necessary IAM role.  
   \# Create codedeploy.tf

   \# IAM Role for CodeDeploy  
   resource "aws\_iam\_role" "codedeploy\_role" {  
     name \= "ecs-codedeploy-role"

     assume\_role\_policy \= jsonencode({  
       Version \= "2012-10-17",  
       Statement \= \[{  
         Action \= "sts:AssumeRole",  
         Effect \= "Allow",  
         Principal \= {  
           Service \= "codedeploy.amazonaws.com"  
         }  
       }\]  
     })  
   }

   resource "aws\_iam\_role\_policy\_attachment" "codedeploy\_policy" {  
     role       \= aws\_iam\_role.codedeploy\_role.name  
     policy\_arn \= "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"  
   }

   \# CodeDeploy Application  
   resource "aws\_codedeploy\_app" "strapi\_app" {  
     compute\_platform \= "ECS"  
     name             \= "strapi-codedeploy-app"  
   }

   \# CodeDeploy Deployment Group  
   resource "aws\_codedeploy\_deployment\_group" "strapi\_dg" {  
     app\_name               \= aws\_codedeploy\_app.strapi\_app.name  
     deployment\_group\_name  \= "strapi-deployment-group"  
     deployment\_config\_name \= "CodeDeployDefault.ECSCanary10Percent5Minutes"  
     service\_role\_arn       \= aws\_iam\_role.codedeploy\_role.arn

     ecs\_service {  
       cluster\_name \= aws\_ecs\_cluster.strapi\_cluster.name  
       service\_name \= aws\_ecs\_service.strapi\_service.name  
     }

     deployment\_style {  
       deployment\_option \= "WITH\_TRAFFIC\_CONTROL"  
       deployment\_type   \= "BLUE\_GREEN"  
     }

     auto\_rollback\_configuration {  
       enabled \= true  
       events  \= \["DEPLOYMENT\_FAILURE"\]  
     }

     blue\_green\_deployment\_config {  
       deployment\_ready\_option {  
         action\_on\_timeout \= "CONTINUE\_DEPLOYMENT"  
       }  
       terminate\_blue\_instances\_on\_deployment\_success {  
         action                           \= "TERMINATE"  
         termination\_wait\_time\_in\_minutes \= 5  
       }  
     }

     load\_balancer\_info {  
       target\_group\_pair\_info {  
         prod\_traffic\_route {  
           listener\_arns \= \[aws\_lb\_listener.strapi\_prod\_listener.arn\]  
         }  
         target\_group {  
           name \= aws\_lb\_target\_group.strapi\_blue\_tg.name  
         }  
         target\_group {  
           name \= aws\_lb\_target\_group.strapi\_green\_tg.name  
         }  
         test\_traffic\_route {  
           listener\_arns \= \[aws\_lb\_listener.strapi\_test\_listener.arn\]  
         }  
       }  
     }  
   }

4. Apply Terraform Changes  
   Run terraform apply to create and update all the necessary resources for the blue/green setup.  
   terraform init  
   terraform plan  
   terraform apply \--auto-approve

## **✅ Task 11: Set up a GitHub Actions workflow to handle deployment**

This workflow automates the blue/green deployment process by interacting with CodeDeploy.

### **Steps**

1. Create appspec.yml and taskdef.json files  
   CodeDeploy needs an AppSpec file to understand how to deploy the ECS service. We also use a template for our task definition. Create these in your repository root.  
   **appspec.yml**:  
   version: 0.0  
   Resources:  
     \- TargetService:  
         Type: AWS::ECS::Service  
         Properties:  
           TaskDefinition: "\<TASK\_DEFINITION\>"  
           LoadBalancerInfo:  
             ContainerName: "strapi"  
             ContainerPort: 1337

   **taskdef.json** (This is a template; the ECR image URI will be injected by the workflow):  
   {  
       "ipcMode": null,  
       "executionRoleArn": "arn:aws:iam::\<AWS\_ACCOUNT\_ID\>:role/ecs\_task\_execution\_role",  
       "containerDefinitions": \[  
           {  
               "name": "strapi",  
               "image": "\<IMAGE1\_NAME\>",  
               "essential": true,  
               "portMappings": \[  
                   {  
                       "hostPort": 1337,  
                       "protocol": "tcp",  
                       "containerPort": 1337  
                   }  
               \],  
               "logConfiguration": {  
                   "logDriver": "awslogs",  
                   "options": {  
                       "awslogs-group": "/ecs/strapi",  
                       "awslogs-region": "us-east-1",  
                       "awslogs-stream-prefix": "ecs"  
                   }  
               }  
           }  
       \],  
       "requiresCompatibilities": \[  
           "FARGATE"  
       \],  
       "networkMode": "awsvpc",  
       "cpu": "256",  
       "memory": "512",  
       "family": "strapi-task"  
   }

   *Note: Replace \<AWS\_ACCOUNT\_ID\> with your actual AWS Account ID in taskdef.json.*  
2. Create the GitHub Actions Workflow  
   Create a new workflow file at .github/workflows/deploy-blue-green.yml. This workflow builds the image, updates the task definition, and triggers CodeDeploy.  
   name: CI/CD \- Blue/Green Deploy to ECS

   on:  
     push:  
       branches:  
         \- main

   env:  
     AWS\_REGION: us-east-1  
     ECR\_REPOSITORY: strapi-app  
     CODEDEPLOY\_APP\_NAME: strapi-codedeploy-app  
     CODEDEPLOY\_DEPLOYMENT\_GROUP: strapi-deployment-group  
     CONTAINER\_NAME: strapi

   jobs:  
     deploy:  
       name: Build and Deploy  
       runs-on: ubuntu-latest  
       steps:  
         \- name: Checkout code  
           uses: actions/checkout@v3

         \- name: Configure AWS Credentials  
           uses: aws-actions/configure-aws-credentials@v2  
           with:  
             aws-access-key-id: ${{ secrets.AWS\_ACCESS\_KEY\_ID }}  
             aws-secret-access-key: ${{ secrets.AWS\_SECRET\_ACCESS\_KEY }}  
             aws-region: ${{ env.AWS\_REGION }}

         \- name: Login to Amazon ECR  
           id: login-ecr  
           uses: aws-actions/amazon-ecr-login@v1

         \- name: Build, tag, and push image to Amazon ECR  
           id: build-image  
           env:  
             ECR\_REGISTRY: ${{ steps.login-ecr.outputs.registry }}  
             IMAGE\_TAG: ${{ github.sha }}  
           run: |  
             docker build \-t $ECR\_REGISTRY/$ECR\_REPOSITORY:$IMAGE\_TAG .  
             docker push $ECR\_REGISTRY/$ECR\_REPOSITORY:$IMAGE\_TAG  
             echo "image=$ECR\_REGISTRY/$ECR\_REPOSITORY:$IMAGE\_TAG" \>\> $GITHUB\_OUTPUT

         \- name: Create new task definition revision  
           id: task-def  
           run: |  
             \# Read the taskdef.json template and replace the \<IMAGE1\_NAME\> placeholder  
             TASK\_DEF\_TEMPLATE=$(cat taskdef.json)  
             NEW\_TASK\_DEF\_CONTENT=$(echo "$TASK\_DEF\_TEMPLATE" | sed "s|\<IMAGE1\_NAME\>|${{ steps.build-image.outputs.image }}|g")

             \# Register the new task definition with ECS  
             NEW\_TASK\_INFO=$(aws ecs register-task-definition \--cli-input-json "$NEW\_TASK\_DEF\_CONTENT")

             \# Extract the new task definition ARN  
             NEW\_TASK\_DEF\_ARN=$(echo "$NEW\_TASK\_INFO" | jq \-r '.taskDefinition.taskDefinitionArn')  
             echo "task\_def\_arn=$NEW\_TASK\_DEF\_ARN" \>\> $GITHUB\_OUTPUT

         \- name: Create CodeDeploy Deployment  
           id: deploy  
           run: |  
             \# Read the appspec.yml template and replace the \<TASK\_DEFINITION\> placeholder  
             APPSPEC\_TEMPLATE=$(cat appspec.yml)  
             NEW\_APPSPEC\_CONTENT=$(echo "$APPSPEC\_TEMPLATE" | sed "s|\<TASK\_DEFINITION\>|${{ steps.task-def.outputs.task\_def\_arn }}|g")

             \# Trigger the deployment  
             DEPLOYMENT\_ID=$(aws deploy create-deployment \\  
               \--application-name ${{ env.CODEDEPLOY\_APP\_NAME }} \\  
               \--deployment-group-name ${{ env.CODEDEPLOY\_DEPLOYMENT\_GROUP }} \\  
               \--revision "{\\"revisionType\\":\\"AppSpecContent\\",\\"appSpecContent\\":{\\"content\\":\\"$NEW\_APPSPEC\_CONTENT\\"}}" \\  
               \--query '\[deploymentId\]' \--output text)  
             echo "deployment\_id=$DEPLOYMENT\_ID" \>\> $GITHUB\_OUTPUT

         \- name: Monitor Deployment Status  
           run: |  
             echo "Waiting for deployment ${{ steps.deploy.outputs.deployment\_id }} to complete..."  
             aws deploy wait deployment-successful \--deployment-id ${{ steps.deploy.outputs.deployment\_id }}  
             echo "Deployment successful\!"

### **How It Works**

1. **Trigger**: The workflow runs on every push to the main branch.  
2. **Build & Push**: It builds and pushes a new Docker image to ECR, tagged with the unique commit SHA.  
3. **Update Task Definition**: It takes the taskdef.json template, injects the new ECR image URI, and registers a brand new task definition revision with ECS.  
4. **Trigger CodeDeploy**: It then takes the appspec.yml template, injects the ARN of the new task definition, and uses the AWS CLI to create a new deployment in CodeDeploy.  
5. **CodeDeploy Takes Over**: From here, CodeDeploy manages the entire blue/green process: it provisions new "green" tasks, runs health checks, and shifts traffic via the ALB listeners based on the ECSCanary10Percent5Minutes strategy.  
6. **Monitor**: The final step in the workflow waits for the CodeDeploy deployment to report success. If CodeDeploy initiates a rollback due to failed health checks, this step will fail, causing the workflow to fail and alerting the team.

## **✅ Task 16: Build a Kubernetes Cluster Locally with Minikube**

**Objective**: Get hands-on experience with Kubernetes by deploying, managing, and scaling a sample application on a local cluster.

### **Prerequisites**

* **Docker**: Minikube runs a Kubernetes cluster inside a Docker container.  
* **Minikube**: [Install Minikube](https://minikube.sigs.k8s.io/docs/start/) for your operating system.  
* **kubectl**: [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/), the Kubernetes command-line tool.

### **Steps**

1. Start Your Local Cluster  
   Open your terminal and run the minikube start command. This will download the necessary images and start a single-node Kubernetes cluster.  
   minikube start

2. Create a Deployment Manifest  
   A Deployment tells Kubernetes how to create and update instances of your application. Create a file named deployment.yaml. For this example, we'll use a simple Nginx web server.  
   \# deployment.yaml  
   apiVersion: apps/v1  
   kind: Deployment  
   metadata:  
     name: nginx-deployment  
   spec:  
     replicas: 2 \# Start with 2 instances of our application  
     selector:  
       matchLabels:  
         app: nginx  
     template:  
       metadata:  
         labels:  
           app: nginx  
       spec:  
         containers:  
         \- name: nginx  
           image: nginx:1.25 \# Use a specific version of the public Nginx image  
           ports:  
           \- containerPort: 80

3. Create a Service Manifest  
   A Service exposes your application to be accessible. We'll use the NodePort type, which makes the service accessible on a specific port on the Minikube node's IP. Create a file named service.yaml.  
   \# service.yaml  
   apiVersion: v1  
   kind: Service  
   metadata:  
     name: nginx-service  
   spec:  
     selector:  
       app: nginx  
     type: NodePort \# Exposes the service on the node's IP at a static port  
     ports:  
       \- protocol: TCP  
         port: 80       \# Port for other services inside the cluster to use  
         targetPort: 80 \# Port on the pod that the service forwards traffic to

4. Apply Manifests and Verify the Deployment  
   Use kubectl apply to send the configurations to your cluster.  
   kubectl apply \-f deployment.yaml  
   kubectl apply \-f service.yaml

   Now, check the status of your Pods and Service.  
   \# Check that the pods are running  
   kubectl get pods

   \# Check that the service is created  
   kubectl get services

   You should see your two Nginx pods in a "Running" state.  
5. Access Your Application  
   Minikube provides a handy command to get the URL for your service.  
   minikube service nginx-service

   This will automatically open the Nginx welcome page in your default web browser.  
6. Scale Your Application  
   You can easily scale the number of pods in your deployment up or down. Let's scale up to 4 replicas.  
   \# Scale the deployment to 4 replicas  
   kubectl scale deployment nginx-deployment \--replicas=4

   \# Verify that you now have 4 pods running  
   kubectl get pods

7. Inspect and Debug  
   If something goes wrong, you can inspect your resources and view logs.  
   \# Get detailed information about a pod (replace \<pod-name\> with a real pod name)  
   kubectl describe pod \<pod-name\>

   \# View the logs from a specific pod  
   kubectl logs \<pod-name\>

### **Outcome**

By completing this task, you will have a fundamental understanding of core Kubernetes concepts like Deployments, Pods, and Services, and you'll be comfortable using kubectl to manage applications in a cluster.

## **✅ Task 17: Resource Monitoring, Alerting, and Log Management Automation**

**Objective**: Develop automated Bash scripts to monitor system health and manage log files, ensuring system reliability and maintainability.

### **Part 1: Resource Monitoring & Alert System**

**Goal**: Create a Bash script that monitors key system resources (CPU, RAM, disk, load) and sends an email alert when any predefined threshold is breached.

#### **Prerequisites**

* A Linux-based system.  
* A configured mail client like mailx or sendmail. To install on Debian/Ubuntu: sudo apt-get install mailutils.

#### **Steps**

1. Create the Monitoring Script  
   Create a file named resource\_monitor.sh and add the following code. This script captures usage data, compares it against set thresholds, and sends a formatted email if any threshold is exceeded.  
   \#\!/bin/bash

   \# \--- Configuration \---  
   \# Email settings  
   RECIPIENT\_EMAIL="your-email@example.com"  
   EMAIL\_SUBJECT="CRITICAL: System Resource Alert on $(hostname)"

   \# Thresholds (in percentage, except for load average)  
   CPU\_THRESHOLD=80  
   MEM\_THRESHOLD=75  
   DISK\_THRESHOLD=85  
   LOAD\_AVG\_THRESHOLD=5.0

   \# \--- Data Collection \---  
   \# Get current timestamp  
   TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

   \# Get CPU usage (percentage of non-idle time)  
   CPU\_USAGE=$(top \-bn1 | grep "Cpu(s)" | sed "s/.\*, \*\\(\[0-9.\]\*\\)%\* id.\*/\\1/" | awk '{print 100 \- $1}')

   \# Get Memory usage  
   MEM\_FREE=$(free \-m | awk 'NR==2{printf "%.2f", $3\*100/$2 }')

   \# Get Disk usage for the root partition ('/')  
   DISK\_USAGE=$(df \-h / | awk 'NR==2{print $5}' | sed 's/%//')

   \# Get 1-minute load average  
   LOAD\_AVG=$(uptime | awk \-F'load average:' '{print $2}' | cut \-d, \-f1 | xargs)

   \# \--- Alert Logic \---  
   ALERT\_MESSAGE=""

   \# Check if CPU usage exceeds the threshold  
   if (( $(echo "$CPU\_USAGE \> $CPU\_THRESHOLD" | bc \-l) )); then  
       ALERT\_MESSAGE+="CPU Usage is at ${CPU\_USAGE}%, which exceeds the threshold of ${CPU\_THRESHOLD}%.\\n"  
   fi

   \# Check if Memory usage exceeds the threshold  
   if (( $(echo "$MEM\_FREE \> $MEM\_THRESHOLD" | bc \-l) )); then  
       ALERT\_MESSAGE+="Memory Usage is at ${MEM\_FREE}%, which exceeds the threshold of ${MEM\_THRESHOLD}%.\\n"  
   fi

   \# Check if Disk usage exceeds the threshold  
   if \[ "$DISK\_USAGE" \-gt "$DISK\_THRESHOLD" \]; then  
       ALERT\_MESSAGE+="Disk Usage is at ${DISK\_USAGE}%, which exceeds the threshold of ${DISK\_THRESHOLD}%.\\n"  
   fi

   \# Check if Load Average exceeds the threshold  
   if (( $(echo "$LOAD\_AVG \> $LOAD\_AVG\_THRESHOLD" | bc \-l) )); then  
       ALERT\_MESSAGE+="System Load Average is ${LOAD\_AVG}, which exceeds the threshold of ${LOAD\_AVG\_THRESHOLD}.\\n"  
   fi

   \# \--- Send Email Alert \---  
   \# If any alert message was generated, send the email  
   if \[ \-n "$ALERT\_MESSAGE" \]; then  
       \# Construct the email body  
       EMAIL\_BODY=$(cat \<\<EOF  
   System Resource Alert  
   \---------------------------------  
   Hostname: $(hostname)  
   Timestamp: $TIMESTAMP

   The following resource thresholds have been breached:

   $ALERT\_MESSAGE

   \--- Current System Status \---  
   CPU Usage: ${CPU\_USAGE}%  
   Memory Usage: ${MEM\_FREE}%  
   Disk Usage: ${DISK\_USAGE}%  
   System Load Average: $LOAD\_AVG  
   EOF  
       )

       \# Send the email  
       echo \-e "$EMAIL\_BODY" | mailx \-s "$EMAIL\_SUBJECT" "$RECIPIENT\_EMAIL"  
       echo "Alert email sent to $RECIPIENT\_EMAIL"  
   fi

   echo "Resource check completed at $TIMESTAMP"

2. **Make the Script Executable**  
   chmod \+x resource\_monitor.sh

3. Schedule with a Cron Job  
   To run the script automatically every 10 minutes, open your crontab editor:  
   crontab \-e

   Then, add the following line (make sure to use the full path to your script):  
   \*/10 \* \* \* \* /path/to/your/resource\_monitor.sh

#### **Deliverables**

* **Bash script**: resource\_monitor.sh (as provided above).  
* **Sample Email Output**:  
  Subject: CRITICAL: System Resource Alert on my-server

  System Resource Alert  
  \---------------------------------  
  Hostname: my-server  
  Timestamp: 2025-10-26 19:30:01

  The following resource thresholds have been breached:

  CPU Usage is at 85.5%, which exceeds the threshold of 80%.  
  Disk Usage is at 91%, which exceeds the threshold of 85%.

  \--- Current System Status \---  
  CPU Usage: 85.5%  
  Memory Usage: 65.2%  
  Disk Usage: 91%  
  System Load Average: 3.45

* **Cron Job Snippet**: \*/10 \* \* \* \* /path/to/your/resource\_monitor.sh

### **Part 2: Log Management and Backup**

**Goal**: Automate the backup of logs older than 7 days, compress them, and then safely delete the originals to manage disk space.

#### **Steps**

1. Create the Log Management Script  
   Create a file named log\_manager.sh. This script will find, compress, move, and delete old log files, while keeping a record of its actions.  
   \#\!/bin/bash

   \# \--- Configuration \---  
   \# Directories (ensure these exist before running)  
   LOG\_DIR="/var/logs/checkins"  
   BACKUP\_DIR="/backup/logs"

   \# Retention period (in days)  
   RETENTION\_DAYS=7

   \# Log file for this script's actions  
   ACTION\_LOG="/var/log/log\_manager\_actions.log"

   \# \--- Script Logic \---  
   TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

   \# Log script start  
   echo "\[$TIMESTAMP\] Starting log management script..." \>\> "$ACTION\_LOG"

   \# Ensure directories exist  
   mkdir \-p "$LOG\_DIR"  
   mkdir \-p "$BACKUP\_DIR"

   \# Find log files older than RETENTION\_DAYS  
   OLD\_LOGS=$(find "$LOG\_DIR" \-type f \-name "\*.log" \-mtime \+"$RETENTION\_DAYS")

   if \[ \-z "$OLD\_LOGS" \]; then  
       echo "\[$TIMESTAMP\] No logs older than $RETENTION\_DAYS days found. Exiting." \>\> "$ACTION\_LOG"  
       exit 0  
   fi

   \# Create a dated backup archive  
   BACKUP\_FILENAME="logs\_backup\_$(date "+%Y-%m-%d\_%H%M%S").tar.gz"  
   BACKUP\_PATH="$BACKUP\_DIR/$BACKUP\_FILENAME"

   echo "\[$TIMESTAMP\] Found old logs. Creating backup archive: $BACKUP\_PATH" \>\> "$ACTION\_LOG"

   \# Compress the old logs into the backup directory  
   tar \-czvf "$BACKUP\_PATH" $OLD\_LOGS

   \# Verify that the backup was created successfully  
   if \[ $? \-eq 0 \]; then  
       echo "\[$TIMESTAMP\] Backup successful. Removing original log files." \>\> "$ACTION\_LOG"  
       \# Delete the original files  
       echo "$OLD\_LOGS" | xargs rm \-f  
       if \[ $? \-eq 0 \]; then  
           echo "\[$TIMESTAMP\] Successfully removed old log files." \>\> "$ACTION\_LOG"  
       else  
           echo "\[$TIMESTAMP\] ERROR: Failed to remove old log files." \>\> "$ACTION\_LOG"  
       fi  
   else  
       echo "\[$TIMESTAMP\] ERROR: Backup failed. Original log files were not removed." \>\> "$ACTION\_LOG"  
   fi

   echo "\[$TIMESTAMP\] Log management script finished." \>\> "$ACTION\_LOG"  
   echo "-------------------------------------------" \>\> "$ACTION\_LOG"

2. **Make the Script Executable**  
   chmod \+x log\_manager.sh

3. Schedule with a Cron Job  
   To run this script daily at 2:00 AM, edit your crontab:  
   crontab \-e

   Add the following line:  
   0 2 \* \* \* /path/to/your/log\_manager.sh

#### **Deliverables**

* **Bash script**: log\_manager.sh (as provided above).  
* **Sample Action Log Output** (/var/log/log\_manager\_actions.log):  
  \[2025-10-26 02:00:01\] Starting log management script...  
  \[2025-10-26 02:00:01\] Found old logs. Creating backup archive: /backup/logs/logs\_backup\_2025-10-26\_020001.tar.gz  
  \[2025-10-26 02:00:05\] Backup successful. Removing original log files.  
  \[2025-10-26 02:00:05\] Successfully removed old log files.  
  \[2025-10-26 02:00:05\] Log management script finished.  
  \-------------------------------------------

* **Cron Job Snippet**: 0 2 \* \* \* /path/to/your/log\_manager.sh