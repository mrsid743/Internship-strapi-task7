Strapi Internship Tasks: From Local Setup to Automated DeploymentGitHub RepositoryThis repository documents the process of setting up, containerizing, deploying, and automating a Strapi application. The project covers local setup, Dockerization, orchestration with Docker Compose, infrastructure provisioning on AWS with Terraform, and setting up a CI/CD pipeline using GitHub Actions.📋 Table of ContentsPrerequisitesTask 1: Local Strapi SetupTask 2: Dockerizing the Strapi ApplicationTask 3: Multi-Container Setup with Docker ComposeTask 4: Deploying to AWS EC2 with TerraformTask 5: Automating Deployment with GitHub Actions (CI/CD)Task 6: Deploying to AWS ECS Fargate with TerraformTask 7: Fully Automated CI/CD for ECS FargateTask 8: Add CloudWatch Monitoring to ECS DeploymentTask 9: Optimize Costs with Fargate SpotTask 10: Configure AWS Resources for Blue/Green DeploymentTask 11: Set up a GitHub Actions Workflow for Blue/Green Deployment🛠️ PrerequisitesBefore you begin, ensure you have the following installed and configured:Node.js (v18 or later)npm or yarnDocker and Docker ComposeTerraformAn AWS Account with programmatic access (Access Key ID and Secret Access Key)A Docker Hub AccountA GitHub AccountAWS CLI✅ Task 1: Local Strapi SetupStepsClone the Strapi RepositoryYou can create a new Strapi project using the create-strapi-app command.npx create-strapi-app@latest my-strapi-project --quickstart
Navigate to the Project Directorycd my-strapi-project
Run Strapi in Development ModeThe --quickstart flag will automatically start the development server. If it doesn't, use the following command:npm run develop
# or
yarn develop
Create Your First Admin UserOnce the server starts, navigate to http://localhost:1337/admin. You'll be prompted to create the first administrator account. Fill in the details to access the Admin Panel.Create a Sample Content TypeIn the Admin Panel, go to Content-Type Builder > Create new collection type.Enter a Display name (e.g., "Article").Add fields like title (Text) and content (Rich Text).Click Save and wait for the server to restart.You can now add content to your new "Article" collection type!Push to GitHubInitialize a Git repository, commit your changes, and push it to your GitHub account.git init
git add .
git commit -m "Initial Strapi setup"
git branch -M main
git remote add origin [https://github.com/](https://github.com/)<your-username>/<your-repo-name>.git
git push -u origin main
✅ Task 2: Dockerizing the Strapi ApplicationStepsCreate a DockerfileIn the root of your Strapi project, create a file named Dockerfile with the following content:# Use the official Node.js 18 image as a base
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /opt/app

# Copy package.json and package-lock.json (or yarn.lock)
COPY ./package.json ./
COPY ./yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the application source code
COPY ./ .

# Build the Strapi admin panel
ENV NODE_ENV=production
RUN yarn build

# Expose the port Strapi runs on
EXPOSE 1337

# Start the Strapi application
CMD ["yarn", "start"]
Build the Docker ImageOpen your terminal in the project root and run the following command to build the image. Replace <your-dockerhub-username> with your actual Docker Hub username.docker build -t <your-dockerhub-username>/strapi-app .
Run the Docker ContainerRun the container to test if the image works correctly.docker run -p 1337:1337 <your-dockerhub-username>/strapi-app
You should now be able to access your Strapi application at http://localhost:1337.✅ Task 3: Multi-Container Setup with Docker ComposeProject Structure.
├── nginx/
│   └── nginx.conf
├── src/
│   └── (Your Strapi app files)
├── .env
├── docker-compose.yml
└── Dockerfile
StepsCreate docker-compose.ymlThis file defines the services: strapi, postgres, and nginx.version: '3.8'

services:
  strapi:
    container_name: strapi
    build: .
    image: <your-dockerhub-username>/strapi-app
    environment:
      DATABASE_CLIENT: postgres
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: ${DATABASE_NAME}
      DATABASE_USERNAME: ${DATABASE_USERNAME}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD}
      HOST: 0.0.0.0
      PORT: 1337
    volumes:
      - ./src:/opt/app
    ports:
      - "1337:1337"
    depends_on:
      - postgres
    networks:
      - strapi-net

  postgres:
    container_name: postgres
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: ${DATABASE_NAME}
      POSTGRES_USER: ${DATABASE_USERNAME}
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD}
    volumes:
      - strapi-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - strapi-net

  nginx:
    container_name: nginx
    image: nginx:1.21-alpine
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "80:80"
    depends_on:
      - strapi
    networks:
      - strapi-net

volumes:
  strapi-data:

networks:
  strapi-net:
    driver: bridge
Configure Nginx as a Reverse ProxyCreate nginx/nginx.conf to forward requests from port 80 to the Strapi container on port 1337.server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://strapi:1337;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
Create .env file for credentials.DATABASE_NAME=strapi_db
DATABASE_USERNAME=strapi_user
DATABASE_PASSWORD=strapi_password
Run the EnvironmentFrom your project root, run:docker-compose up --build
You can now access the Strapi admin panel at http://localhost/admin. 🎉✅ Task 4: Deploying to AWS EC2 with TerraformStepsPush Your Docker Image to Docker HubFirst, log in and push the image you built in Task 2.docker login
docker push <your-dockerhub-username>/strapi-app:latest
Create Terraform Configuration FilesCreate a file named main.tf. This file will define the AWS provider, a security group to allow HTTP and SSH traffic, and the EC2 instance itself.terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Or your preferred region
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For production, restrict this to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "strapi_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (us-east-1)
  instance_type = "t2.micro"
  security_groups = [aws_security_group.strapi_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              docker pull <your-dockerhub-username>/strapi-app:latest
              docker run -d -p 80:1337 --restart always <your-dockerhub-username>/strapi-app:latest
              EOF

  tags = {
    Name = "Strapi-Instance"
  }
}

output "public_ip" {
  value = aws_instance.strapi_server.public_ip
}
Initialize and Apply TerraformRun the following commands in the directory containing your main.tf file.# Initialize Terraform
terraform init

# Preview the changes
terraform plan

# Apply the changes to create the infrastructure
terraform apply --auto-approve
Verify DeploymentAfter terraform apply completes, it will output the public IP address of the EC2 instance. Access your Strapi app by navigating to http://<your-ec2-public-ip>.✅ Task 5: Automating Deployment with GitHub Actions (CI/CD)PrerequisitesAdd the following secrets to your GitHub repository (Settings > Secrets and variables > Actions):AWS_ACCESS_KEY_ID: Your AWS access key.AWS_SECRET_ACCESS_KEY: Your AWS secret key.DOCKERHUB_USERNAME: Your Docker Hub username.DOCKERHUB_TOKEN: Your Docker Hub access token.1. CI Workflow: Build and Push Docker ImageCreate .github/workflows/ci.yml to automatically build and push the Docker image to Docker Hub.name: CI - Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    outputs:
      image_tag: ${{ steps.meta.outputs.version }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ secrets.DOCKERHUB_USERNAME }}/strapi-app
          tags: |
            type=sha,prefix=,format=short

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
2. CD Workflow: Deploy with TerraformCreate .github/workflows/terraform.yml to manually trigger the deployment.name: CD - Deploy to EC2 with Terraform

on:
  workflow_dispatch:
    inputs:
      image_tag:
        description: 'Image tag to deploy (e.g., latest or commit SHA)'
        required: true
        default: 'latest'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -var="image_tag=${{ github.event.inputs.image_tag }}"

      - name: Terraform Apply
        run: terraform apply -auto-approve -var="image_tag=${{ github.event.inputs.image_tag }}"
Update main.tf for Dynamic Image TagsModify your main.tf to accept the image tag as a variable.# ... (provider and security group config) ...

variable "image_tag" {
  description = "The Docker image tag to deploy"
  type        = string
  default     = "latest"
}

resource "aws_instance" "strapi_server" {
  # ... (ami, instance_type, etc.) ...

  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y docker
                sudo service docker start
                sudo usermod -a -G docker ec2-user
                docker pull <your-dockerhub-username>/strapi-app:${var.image_tag}
                # Stop and remove old container if it exists
                docker stop $(docker ps -q --filter "ancestor=<your-dockerhub-username>/strapi-app") || true
                docker rm $(docker ps -aq --filter "ancestor=<your-dockerhub-username>/strapi-app") || true
                docker run -d -p 80:1337 --restart always <your-dockerhub-username>/strapi-app:${var.image_tag}
                EOF
  
  # ... (tags) ...
}

# ... (output) ...
Now, your complete CI/CD pipeline is set up! 🚀✅ Task 6: Deploying to AWS ECS Fargate with TerraformStepsCreate an ECR Repository with TerraformFirst, we need a private registry to store our Docker image. Create a file named ecr.tf and add the following code to define an AWS ECR repository.resource "aws_ecr_repository" "strapi_ecr_repo" {
  name                 = "strapi-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
Build and Push the Docker Image to ECRBefore creating the rest of the infrastructure, you must push your application's Docker image to the new ECR repository.First, apply the Terraform configuration to create the repository:terraform init
terraform apply -target=aws_ecr_repository.strapi_ecr_repo --auto-approve
Next, run the following commands to authenticate Docker with ECR, then build, tag, and push your image.# Set environment variables for your AWS Account ID and Region
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1 # Or your preferred region
export ECR_REPO_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}[.amazonaws.com/strapi-app](https://.amazonaws.com/strapi-app)"

# 1. Authenticate Docker to your ECR registry
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URI

# 2. Build the Docker image (ensure Dockerfile is in the current directory)
docker build -t strapi-app .

# 3. Tag the image for ECR
docker tag strapi-app:latest $ECR_REPO_URI:latest

# 4. Push the image to ECR
docker push $ECR_REPO_URI:latest
Write Terraform Code for ECS Fargate InfrastructureCreate a new file, ecs.tf, to define the cluster, load balancer, security groups, task definition, and service. This configuration uses the default VPC for simplicity.# Fetch default VPC and subnets to deploy resources into them
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for the Application Load Balancer (allows public HTTP traffic)
resource "aws_security_group" "alb_sg" {
  name        = "strapi-alb-sg"
  description = "Allow HTTP inbound traffic for ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for the Fargate Service (only allows traffic from our ALB)
resource "aws_security_group" "fargate_sg" {
  name        = "strapi-fargate-sg"
  description = "Allow inbound traffic from ALB for Fargate"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer (ALB) to route traffic to the service
resource "aws_lb" "strapi_alb" {
  name               = "strapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "strapi_tg" {
  name        = "strapi-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
  health_check {
    path                = "/_health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}

resource "aws_lb_listener" "strapi_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # 0.25 vCPU
  memory                   = "512"  # 512 MB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${aws_ecr_repository.strapi_ecr_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
      # NOTE: For a production setup, database credentials should be injected
      # securely using AWS Secrets Manager, not hardcoded.
      environment = [
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.fargate_sg.id]
    assign_public_ip = true # Required for Fargate to pull the ECR image
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.strapi_listener]
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Output the public URL of the ALB
output "strapi_url" {
  description = "Public URL of the Strapi application"
  value       = "http://${aws_lb.strapi_alb.dns_name}"
}
Initialize and Deploy the InfrastructureNow, run Terraform to deploy the entire ECS stack.terraform init
terraform plan
terraform apply --auto-approve
Verify DeploymentOnce terraform apply is complete, it will output the strapi_url. Navigate to this URL in your browser to access your Strapi application, now running scalably on ECS Fargate!✅ Task 7: Fully Automated CI/CD for ECS FargatePrerequisitesEnsure your ECS Fargate infrastructure from Task 6 is deployed and running.Add the following secrets to your GitHub repository (Settings > Secrets and variables > Actions):AWS_ACCESS_KEY_ID: Your AWS access key.AWS_SECRET_ACCESS_KEY: Your AWS secret key.GitHub Actions WorkflowCreate a new workflow file at .github/workflows/deploy-to-ecs.yml. This single workflow handles the entire CI/CD process.name: CI/CD - Build and Deploy to ECS Fargate

on:
  push:
    branches:
      - main

env:
  AWS_REGION: us-east-1              # Your AWS Region
  ECR_REPOSITORY: strapi-app         # Your ECR repository name from Task 6
  ECS_SERVICE: strapi-service        # Your ECS service name from ecs.tf
  ECS_CLUSTER: strapi-cluster        # Your ECS cluster name from ecs.tf
  ECS_TASK_DEFINITION: strapi-task   # Your ECS task definition family from ecs.tf
  CONTAINER_NAME: strapi             # The container name defined in your task definition

jobs:
  deploy:
    name: Build and Deploy
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          # Set the image URI as an output for the next step
          echo "::set-output name=image::$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

      - name: Download current task definition
        run: |
          aws ecs describe-task-definition --task-definition ${{ env.ECS_TASK_DEFINITION }} --query taskDefinition > task-definition.json

      - name: Fill in the new image ID in the Amazon ECS task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: task-definition.json
          container-name: ${{ env.CONTAINER_NAME }}
          image: ${{ steps.build-image.outputs.image }}

      - name: Deploy Amazon ECS task definition
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: ${{ env.ECS_SERVICE }}
          cluster: ${{ env.ECS_CLUSTER }}
          wait-for-service-stability: true
How It WorksTrigger: The workflow starts automatically whenever you push a commit to the main branch.AWS & ECR Login: It securely logs into your AWS account and ECR registry using the provided GitHub Secrets.Build & Push: It builds a new Docker image from your Dockerfile and tags it with the unique commit SHA. This ensures every version is traceable. The new image is then pushed to your ECR repository.Update Task Definition: The workflow fetches the latest active task definition for your service. It then creates a new revision of this definition in memory, replacing the old image URI with the URI of the new image it just pushed.Deploy New Revision: Finally, it registers this new task definition with ECS and updates the strapi-service, which triggers a new deployment. ECS handles the rolling update gracefully, draining old tasks and starting new ones with the updated image. The wait-for-service-stability: true flag ensures the workflow only succeeds if the new version deploys successfully.VerificationTo verify, simply make a small change to your Strapi application, commit it, and push it to the main branch. Go to the "Actions" tab in your GitHub repository to watch the workflow run. Once it completes, your changes will be live at the ALB URL provided by your Terraform output.✅ Task 8: Add CloudWatch Monitoring to ECS DeploymentPrerequisitesA functioning ECS Fargate deployment as set up in Task 6.Your Terraform code for the ECS infrastructure (ecs.tf).StepsUpdate Terraform to Create a CloudWatch Log GroupAdd the following resource to your ecs.tf file. This creates a dedicated log group where all logs from your Strapi container will be sent.# Add this to ecs.tf
resource "aws_cloudwatch_log_group" "strapi_logs" {
  name = "/ecs/strapi"

  tags = {
    Application = "Strapi"
    Environment = "Production"
  }
}
Update the ECS Task Definition to Send LogsModify the aws_ecs_task_definition resource in ecs.tf. Specifically, you need to add the logConfiguration block inside the container_definitions. This tells the ECS agent to use the awslogs driver and send logs to the group you just created.# Modify this existing resource in ecs.tf
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${aws_ecr_repository.strapi_ecr_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
      # --- Add this logConfiguration block ---
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.strapi_logs.name
          "awslogs-region"        = "us-east-1" # Or your AWS region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      # ------------------------------------
      environment = [
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" }
      ]
    }
  ])
}
(Optional) Create a CloudWatch Alarm for High CPUTo proactively monitor performance, you can add alarms. Add the following resource to ecs.tf to create an alarm that triggers if the average CPU utilization of the ECS service exceeds 75% for 5 minutes.# Add this to ecs.tf for proactive monitoring
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "strapi-high-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300" # 5 minutes
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "This alarm triggers if the Strapi service CPU utilization is over 75%."

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }

  # In a real-world scenario, you would configure an action,
  # like sending a notification to an SNS topic.
  # alarm_actions = [aws_sns_topic.your_topic.arn]
}
Apply and Verify the Monitoring SetupRun terraform apply to create the new CloudWatch resources and update your ECS task definition. Terraform will automatically register a new revision and trigger a service deployment.terraform plan
terraform apply --auto-approve
How to View Logs and MetricsTo View Logs:Go to the AWS CloudWatch console.In the navigation pane, click on Log groups.Find and click on the /ecs/strapi log group.You will see log streams from your running tasks. Click on one to view the application logs in real-time.To View Metrics:Go to the AWS CloudWatch console and click on All metrics.In the AWS/ECS namespace, select "Per-Service Metrics".Find metrics like CPUUtilization and MemoryUtilization for your cluster and service to view performance graphs.Alternatively, go to the ECS console, select your cluster, and click on the "Metrics" tab for a pre-built dashboard.✅ Task 9: Optimize Costs with Fargate SpotObjective: Modify the existing ECS Fargate deployment to use Fargate Spot instances for running tasks, significantly reducing compute costs. We will configure a capacity provider strategy that prioritizes Spot while keeping on-demand Fargate as a fallback for reliability.PrerequisitesA fully functional ECS Fargate deployment as configured in Task 8.StepsUpdate the ECS Cluster to Use Capacity ProvidersModify the aws_ecs_cluster resource in your ecs.tf file and add a new aws_ecs_cluster_capacity_providers resource. This defines Fargate and Fargate Spot as the available capacity providers for the cluster.# Modify this existing resource in ecs.tf
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Add this new resource to ecs.tf
resource "aws_ecs_cluster_capacity_providers" "strapi_cluster_providers" {
  cluster_name = aws_ecs_cluster.strapi_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}
Update the ECS Service to Use the Spot StrategyNow, modify the aws_ecs_service resource in ecs.tf. The key change is to remove the launch_type argument and replace it with a capacity_provider_strategy. This tells the service to prioritize Fargate Spot.# Modify this existing resource in ecs.tf
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  # REMOVE the launch_type = "FARGATE" line

  # ADD a capacity provider strategy block to prioritize SPOT
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.fargate_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.strapi_listener, aws_ecs_cluster_capacity_providers.strapi_cluster_providers]
}
Note on Strategy: This simple strategy tells ECS to always try to place tasks on FARGATE_SPOT first. If Spot capacity is unavailable, ECS will automatically use on-demand FARGATE because it is registered with the cluster.Apply and Verify the ChangesRun terraform apply to update your ECS cluster and service configuration.terraform plan
terraform apply --auto-approve
How to VerifyNavigate to the AWS ECS Console and select your cluster.Click on your strapi-service.Go to the Tasks tab.Click on a running task and look at the Capacity provider field in the configuration details. It should now show FARGATE_SPOT.✅ Task 10: Configure AWS resources for Blue/Green deployment of the Strapi appThis task modifies our existing Terraform setup to support a blue/green deployment strategy managed by AWS CodeDeploy. This approach minimizes downtime and risk by shifting traffic incrementally to a new version of the application.StepsUpdate the ALB and Create a Second Target GroupIn ecs.tf, we need two target groups (blue and green) and a second listener rule for test traffic. The production listener will point to the blue group initially.# Modify ecs.tf

# Blue Target Group (current production)
resource "aws_lb_target_group" "strapi_blue_tg" {
  name        = "strapi-blue-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
  health_check {
    path = "/_health"
  }
}

# Green Target Group (for new versions)
resource "aws_lb_target_group" "strapi_green_tg" {
  name        = "strapi-green-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
  health_check {
    path = "/_health"
  }
}

# Production Listener (Port 80) -> Points to Blue TG
resource "aws_lb_listener" "strapi_prod_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_blue_tg.arn
  }
}

# Test Listener (e.g., Port 8080) -> Points to Green TG for testing before traffic shift
resource "aws_lb_listener" "strapi_test_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_green_tg.arn
  }
}
Update the ECS Service for CodeDeployModify the aws_ecs_service resource in ecs.tf to hand over deployment control to CodeDeploy.# Modify this existing resource in ecs.tf
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # This block tells ECS that CodeDeploy will manage deployments
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.fargate_sg.id]
    assign_public_ip = true
  }

  # The load_balancer block is now managed by CodeDeploy's deployment group
  # and can be removed from here to avoid conflicts.
  # We keep a placeholder here during initial creation.
  load_balancer {
     target_group_arn = aws_lb_target_group.strapi_blue_tg.arn
     container_name   = "strapi"
     container_port   = 1337
  }

  # We no longer depend on the listener directly
  depends_on = [aws_lb.strapi_alb]
}
Create CodeDeploy Resources and IAM RoleCreate a new file, codedeploy.tf, to define the CodeDeploy application, deployment group, and the necessary IAM role.# Create codedeploy.tf

# IAM Role for CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
  name = "ecs-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# CodeDeploy Application
resource "aws_codedeploy_app" "strapi_app" {
  compute_platform = "ECS"
  name             = "strapi-codedeploy-app"
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "strapi_dg" {
  app_name               = aws_codedeploy_app.strapi_app.name
  deployment_group_name  = "strapi-deployment-group"
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  ecs_service {
    cluster_name = aws_ecs_cluster.strapi_cluster.name
    service_name = aws_ecs_service.strapi_service.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.strapi_prod_listener.arn]
      }
      target_group {
        name = aws_lb_target_group.strapi_blue_tg.name
      }
      target_group {
        name = aws_lb_target_group.strapi_green_tg.name
      }
      test_traffic_route {
        listener_arns = [aws_lb_listener.strapi_test_listener.arn]
      }
    }
  }
}
Apply Terraform ChangesRun terraform apply to create and update all the necessary resources for the blue/green setup.terraform init
terraform plan
terraform apply --auto-approve
✅ Task 11: Set up a GitHub Actions workflow to handle deploymentThis workflow automates the blue/green deployment process by interacting with CodeDeploy.StepsCreate appspec.yml and taskdef.json filesCodeDeploy needs an AppSpec file to understand how to deploy the ECS service. We also use a template for our task definition. Create these in your repository root.appspec.yml:version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "<TASK_DEFINITION>"
        LoadBalancerInfo:
          ContainerName: "strapi"
          ContainerPort: 1337
taskdef.json (This is a template; the ECR image URI will be injected by the workflow):{
    "ipcMode": null,
    "executionRoleArn": "arn:aws:iam::<AWS_ACCOUNT_ID>:role/ecs_task_execution_role",
    "containerDefinitions": [
        {
            "name": "strapi",
            "image": "<IMAGE1_NAME>",
            "essential": true,
            "portMappings": [
                {
                    "hostPort": 1337,
                    "protocol": "tcp",
                    "containerPort": 1337
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/strapi",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "networkMode": "awsvpc",
    "cpu": "256",
    "memory": "512",
    "family": "strapi-task"
}
Note: Replace <AWS_ACCOUNT_ID> with your actual AWS Account ID in taskdef.json.Create the GitHub Actions WorkflowCreate a new workflow file at .github/workflows/deploy-blue-green.yml. This workflow builds the image, updates the task definition, and triggers CodeDeploy.name: CI/CD - Blue/Green Deploy to ECS

on:
  push:
    branches:
      - main

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: strapi-app
  CODEDEPLOY_APP_NAME: strapi-codedeploy-app
  CODEDEPLOY_DEPLOYMENT_GROUP: strapi-deployment-group
  CONTAINER_NAME: strapi

jobs:
  deploy:
    name: Build and Deploy
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          echo "::set-output name=image::$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

      - name: Create new task definition revision
        id: task-def
        run: |
          # Read the taskdef.json template and replace the <IMAGE1_NAME> placeholder
          TASK_DEF_TEMPLATE=$(cat taskdef.json)
          NEW_TASK_DEF_CONTENT=$(echo "$TASK_DEF_TEMPLATE" | sed "s|<IMAGE1_NAME>|${{ steps.build-image.outputs.image }}|g")

          # Register the new task definition with ECS
          NEW_TASK_INFO=$(aws ecs register-task-definition --cli-input-json "$NEW_TASK_DEF_CONTENT")

          # Extract the new task definition ARN
          NEW_TASK_DEF_ARN=$(echo "$NEW_TASK_INFO" | jq -r '.taskDefinition.taskDefinitionArn')
          echo "::set-output name=task_def_arn::$NEW_TASK_DEF_ARN"

      - name: Create CodeDeploy Deployment
        id: deploy
        run: |
          # Read the appspec.yml template and replace the <TASK_DEFINITION> placeholder
          APPSPEC_TEMPLATE=$(cat appspec.yml)
          NEW_APPSPEC_CONTENT=$(echo "$APPSPEC_TEMPLATE" | sed "s|<TASK_DEFINITION>|${{ steps.task-def.outputs.task_def_arn }}|g")

          # Trigger the deployment
          DEPLOYMENT_ID=$(aws deploy create-deployment \
            --application-name ${{ env.CODEDEPLOY_APP_NAME }} \
            --deployment-group-name ${{ env.CODEDEPLOY_DEPLOYMENT_GROUP }} \
            --revision "{\"revisionType\":\"AppSpecContent\",\"appSpecContent\":{\"content\":\"$NEW_APPSPEC_CONTENT\"}}" \
            --query '[deploymentId]' --output text)
          echo "::set-output name=deployment_id::$DEPLOYMENT_ID"

      - name: Monitor Deployment Status
        run: |
          echo "Waiting for deployment ${{ steps.deploy.outputs.deployment_id }} to complete..."
          aws deploy wait deployment-successful --deployment-id ${{ steps.deploy.outputs.deployment_id }}
          echo "Deployment successful!"
How It WorksTrigger: The workflow runs on every push to the main branch.Build & Push: It builds and pushes a new Docker image to ECR, tagged with the unique commit SHA.Update Task Definition: It takes the taskdef.json template, injects the new ECR image URI, and registers a brand new task definition revision with ECS.Trigger CodeDeploy: It then takes the appspec.yml template, injects the ARN of the new task definition, and uses the AWS CLI to create a new deployment in CodeDeploy.CodeDeploy Takes Over: From here, CodeDeploy manages the entire blue/green process: it provisions new "green" tasks, runs health checks, and shifts traffic via the ALB listeners based on the ECSCanary10Percent5Minutes strategy.Monitor: The final step in the workflow waits for the CodeDeploy deployment to report success. If CodeDeploy initiates a rollback due to failed health checks, this step will fail, causing the workflow to fail and alerting the team.
