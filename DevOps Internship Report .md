# **DevOps Internship Summary Report: Tasks 1-17**

This report provides a comprehensive summary of the tasks completed during the DevOps internship, documenting the key learnings and challenges encountered from the initial local setup of a Strapi application to its automated deployment and monitoring on AWS.

### **Task 1: Local Strapi Setup**

* **What I Learned:**  
  * Gained foundational knowledge of Strapi as a headless CMS.  
  * Understood the basics of setting up a Node.js application, managing dependencies with npm/yarn, and running it locally.  
  * Learned how to create content types and interact with the Strapi API.  
* **Challenges Faced:**  
  * Initially faced issues with Node.js version compatibility. Ensuring the correct version was installed and used was crucial for all dependencies to work correctly.  
  * Minor configuration issues within Strapi, such as setting up the initial database connection.

### **Task 2: Dockerizing the Strapi Application**

* **What I Learned:**  
  * The fundamentals of containerization using Docker.  
  * How to write a Dockerfile to create a reproducible image of the Strapi application, including managing dependencies and environment variables.  
  * The importance of .dockerignore to keep the image size small and build times fast.  
* **Challenges Faced:**  
  * Optimizing the Docker image for size. The initial builds included unnecessary files like node\_modules from the host.  
  * Ensuring the correct environment variables were passed into the container at runtime for the application to start correctly.

### **Task 3: Multi-Container Setup with Docker Compose**

* **What I Learned:**  
  * How to orchestrate multiple containers (Strapi app and a PostgreSQL database) using docker-compose.yml.  
  * Learned about Docker networking, allowing containers to communicate with each other using service names.  
  * How to use Docker volumes to persist database data even after a container is removed.  
* **Challenges Faced:**  
  * Establishing a stable connection between the Strapi container and the database container. It required careful configuration of environment variables and ensuring the containers were on the same network.  
  * Managing the startup order; the Strapi app would sometimes try to connect to the database before it was ready.

### **Task 4: Deploying to AWS EC2 with Terraform**

* **What I Learned:**  
  * The principles of Infrastructure as Code (IaC) using Terraform.  
  * How to provision core AWS resources like a VPC, subnets, security groups, and an EC2 instance.  
  * The importance of using remote state management (like an S3 backend) for collaboration and state locking.  
* **Challenges Faced:**  
  * **VPC Configuration:** Setting up the VPC, subnets (public/private), and route tables correctly was complex. An initial misconfiguration in the route table prevented the EC2 instance from accessing the internet.  
  * **IAM Roles & Permissions:** Creating an IAM role with the principle of least privilege was challenging. I initially gave the EC2 instance overly broad permissions, which had to be refined for security.

### **Task 5: Automating Deployment with GitHub Actions (CI/CD)**

* **What I Learned:**  
  * The fundamentals of Continuous Integration and Continuous Deployment (CI/CD) using GitHub Actions.  
  * How to create a workflow file (.yml) to automate building the Docker image, pushing it to Docker Hub, and deploying it to the EC2 instance.  
  * Using GitHub Secrets to securely store sensitive credentials like AWS keys and Docker Hub tokens.  
* **Challenges Faced:**  
  * Setting up the SSH connection from the GitHub Actions runner to the EC2 instance was tricky due to key management and security group rules.  
  * The workflow failed multiple times due to small syntax errors in the YAML file.

### **Task 6: Deploying to AWS ECS Fargate with Terraform**

* **What I Learned:**  
  * The benefits of serverless container orchestration with ECS Fargate, removing the need to manage EC2 instances.  
  * How to define ECS Task Definitions, Services, and Clusters using Terraform.  
  * The role of an Application Load Balancer (ALB) in distributing traffic to the Fargate tasks.  
* **Challenges Faced:**  
  * **IAM Task Roles:** Differentiating between the Task Execution Role (for pulling images) and the Task Role (for app permissions) was confusing at first. Incorrect permissions caused "permission denied" errors when the task tried to start.  
  * Networking was complex; ensuring the Fargate tasks were launched in the correct subnets with a route to a NAT Gateway for outbound internet access took time to debug.

### **Task 7: Fully Automated CI/CD for ECS Fargate**

* **What I Learned:**  
  * How to enhance the GitHub Actions workflow to deploy to ECS Fargate.  
  * This involved building the Docker image, pushing it to Amazon ECR (Elastic Container Registry), and then updating the ECS service to deploy the new task definition.  
* **Challenges Faced:**  
  * Authenticating the GitHub Actions runner with AWS ECR required a specific set of IAM permissions and commands.  
  * Updating the ECS service with the new task definition without causing downtime was a key learning curve.

### **Task 8: Add CloudWatch Monitoring to ECS Deployment**

* **What I Learned:**  
  * How to integrate CloudWatch with ECS to centralize application and service logs.  
  * Setting up CloudWatch Alarms to monitor key metrics like CPU and Memory utilization of the ECS service.  
  * Creating a CloudWatch Dashboard to visualize these metrics for easy monitoring.  
* **Challenges Faced:**  
  * Configuring the log driver in the ECS Task Definition correctly to stream logs to the right CloudWatch Log Group.  
  * Fine-tuning alarm thresholds to avoid false positives while still catching genuine performance issues.

### **Task 9: Optimize Costs with Fargate Spot**

* **What I Learned:**  
  * The concept of using Fargate Spot to run fault-tolerant workloads at a significantly lower cost.  
  * How to configure the ECS service's capacity provider strategy in Terraform to use a mix of On-Demand and Spot instances for a balance of cost and reliability.  
* **Challenges Faced:**  
  * Understanding the implications of using Spot instances, which can be interrupted. This meant ensuring the application was stateless and could handle interruptions gracefully.  
  * The Terraform configuration for capacity providers was new and required careful reading of the documentation.

### **Task 10 & 11: Blue/Green Deployments with CodeDeploy**

* **What I Learned:**  
  * The principles of a Blue/Green deployment strategy to minimize deployment risk and eliminate downtime.  
  * How to configure AWS CodeDeploy, an Application Load Balancer, and target groups to manage traffic shifting between the "blue" (current) and "green" (new) environments.  
  * Updating the GitHub Actions workflow to trigger a CodeDeploy deployment instead of directly updating the ECS service.  
* **Challenges Faced:**  
  * The setup is inherently complex, involving multiple interconnected AWS services (ECS, ALB, CodeDeploy, IAM). A small misconfiguration in any one part would cause the entire deployment to fail.  
  * Debugging failed deployments in CodeDeploy required checking logs across multiple services to pinpoint the root cause.

### **Tasks 12-15: Documentation (Extended DevOps Practices)**

This section covers practices that build upon the previous tasks, focusing on security, networking, and data management.

#### **Task 12: Docker Swarm: Architecture, AWS Setup, and Commands**

* **Learnings:** Gained a practical understanding of Docker's native orchestration tool, Docker Swarm. This involved learning the core architectural concepts, including the roles of **manager and worker nodes**, the function of the **Raft consensus algorithm** for maintaining cluster state, and the power of the **routing mesh** for load balancing across services. The task provided hands-on experience in initializing a swarm, joining nodes, and declaratively defining and scaling services.

#### **Task 13: Unleash Feature Flag Integration in a Local React Application**

* **Learnings:** Learned how to implement **feature flags (or feature toggles)** to decouple code deployment from feature release. This involved setting up the Unleash feature flag server and integrating its React SDK into a client-side application. Key takeaways include the ability to perform **canary releases**, conduct **A/B testing**, and enable or disable features in real-time without requiring a new deployment, significantly improving development agility and reducing risk.

#### **Task 14: Reducing Docker Image Size: A Guide to Faster Deployments and Lower Costs**

* **Learnings:** Mastered several key techniques for optimizing Docker images. The most impactful method was using **multi-stage builds**, which allow for separating the build environment from the final runtime environment, drastically reducing the final image size. Other critical learnings included selecting lightweight **base images (e.g., alpine)**, carefully ordering Dockerfile commands to leverage layer caching, and using a comprehensive .dockerignore file to exclude unnecessary files from the build context.

#### **Task 15: A Comprehensive Analysis of the Kubernetes Orchestration Platform**

* **Learnings:** Acquired a foundational understanding of Kubernetes architecture and its core components. This included learning about the **Control Plane** (API Server, etcd, Scheduler, Controller Manager) and its role in managing the cluster's desired state. On the data plane, I learned about **Worker Node** components like the kubelet and kube-proxy. Most importantly, I grasped key Kubernetes objects and abstractions, such as **Pods** (the smallest deployable unit), **Services** (for networking), and **Deployments** (for managing application lifecycle and scalability).

### **Task 16: Build a Kubernetes Cluster Locally with Minikube**

* **What I Learned:**  
  * The fundamental concepts of Kubernetes, including Pods, Deployments, Services, and ConfigMaps.  
  * How to set up a local, single-node Kubernetes cluster using Minikube for development and testing.  
  * Writing Kubernetes manifest files (.yaml) to define the desired state of the application.  
* **Challenges Faced:**  
  * **Minikube Issues:** Minikube was resource-intensive and sometimes unstable on my local machine. It required sufficient RAM and CPU allocation. Driver issues (e.g., Docker vs. VirtualBox) also caused startup problems that needed troubleshooting.  
  * Understanding Kubernetes networking, especially the difference between ClusterIP, NodePort, and LoadBalancer services.

### **Task 17: Resource Monitoring & Log Management Automation**

* **What I Learned:**  
  * How to write robust Bash scripts for system administration tasks.  
  * Automating system health checks (CPU, memory, disk) and setting up alerts.  
  * Implementing a log rotation and backup policy to manage disk space effectively.  
  * Scheduling automated tasks using cron.  
* **Challenges Faced:**  
  * Writing scripts that are reliable and handle edge cases (e.g., what happens if a directory doesn't exist?).  
  * Ensuring the mail client for sending alerts was correctly configured on the Linux system.

### **Conclusion**

This internship provided a hands-on, end-to-end journey through modern DevOps practices. The key takeaway is the power of **automation** at every stage—from provisioning infrastructure with Terraform to building and deploying applications with GitHub Actions. Each task highlighted the importance of creating scalable, resilient, and cost-effective systems.

Facing challenges with **VPC networking, IAM permissions, and local tools like Minikube** were invaluable learning experiences. They underscored the necessity of meticulous configuration and deep understanding of the underlying technologies. The project evolved from a simple local application to a sophisticated, secure, and fully automated deployment on a serverless platform, demonstrating a clear progression in skills and a solid foundation in the principles of CI/CD, Infrastructure as Code, and Cloud Native technologies.