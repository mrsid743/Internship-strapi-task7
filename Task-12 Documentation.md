# **Docker Swarm: Architecture, AWS Setup, and Commands**

This document provides a detailed guide to Docker Swarm, covering its architecture, a step-by-step guide to setting it up on AWS EC2 instances, and a list of useful commands for management and troubleshooting.

### **1\. Docker Swarm Architecture and Components**

Docker Swarm is a container orchestration tool, meaning it allows you to manage a cluster of Docker hosts as a single virtual system. It's Docker's native solution for clustering and scheduling containers.

The architecture is designed around a decentralized model, but it operates with a distinction between manager and worker nodes.

#### **Key Components:**

* **Nodes:** A node is an instance of the Docker engine participating in the swarm. There are two types of nodes:  
  * **Manager Nodes:** These nodes handle the cluster management tasks: maintaining cluster state, scheduling services, and serving the Swarm mode HTTP API endpoints. They use the Raft consensus algorithm to manage the global state of the cluster, ensuring that the cluster remains consistent and available even if some manager nodes fail. For high availability, it is recommended to have an odd number of manager nodes (e.g., 3 or 5\) to maintain quorum and prevent split-brain scenarios.  
  * **Worker Nodes:** These nodes are primarily responsible for running the containers (tasks). They receive instructions from the manager nodes and report back on the status of their assigned tasks. By default, manager nodes can also run tasks, but they can be configured to be manager-only.  
* **Services:** A service is the definition of the tasks to execute on the manager or worker nodes. It's the central structure of the swarm system and the primary way users interact with the swarm. When you create a service, you specify which container image to use and which commands to execute inside running containers.  
  * **Replicated Services:** The swarm manager distributes a specific number of replica tasks among the nodes based on the scale you set in the service definition.  
  * **Global Services:** This runs one task for the service on every available node in the cluster.  
* **Tasks:** A task is a running container that is part of a swarm service and managed by a swarm manager, as opposed to a standalone container. It is the atomic scheduling unit of Swarm. The manager node assigns tasks to worker nodes, and the workers run them.  
* **Load Balancing:** Docker Swarm includes an internal load balancer. When you create a service and expose ports, Swarm automatically assigns the service a Virtual IP (VIP) that routes requests to all healthy tasks within that service. Swarm uses an ingress routing mesh and DNS-based service discovery to facilitate this.

### **2\. Step-by-Step Setup using AWS EC2 Instances**

This guide assumes you have an AWS account and are familiar with launching EC2 instances. We will set up a simple cluster with one manager and two worker nodes.

#### **Step 1: Launch EC2 Instances**

1. Navigate to the EC2 dashboard in your AWS Console.  
2. Click "Launch Instances".  
3. Choose an Amazon Machine Image (AMI), such as **Ubuntu Server 20.04 LTS**.  
4. Choose an instance type, like **t2.micro** (eligible for the free tier).  
5. Launch three instances: one will be our manager, and the other two will be worker-1 and worker-2. It's helpful to tag them accordingly.

*\[Image: AWS EC2 instance launch configuration screen showing instance type and AMI.\]*

#### **Step 2: Configure Security Groups**

Create a new security group for your Swarm cluster with the following inbound rules to allow the nodes to communicate with each other.

* **TCP port 22 (SSH):** From your IP for remote access.  
* **TCP port 2377:** For cluster management communications (manager nodes).  
* **TCP and UDP port 7946:** For communication among all nodes.  
* **UDP port 4789:** For overlay network traffic between nodes.

Apply this security group to all three of your launched instances.

*\[Image: AWS Security Group inbound rules configuration with the specified ports.\]*

#### **Step 3: Install Docker on All Nodes**

Connect to each of the three instances via SSH and run the following commands to install the Docker engine.

\# Update package index  
sudo apt-get update

\# Install prerequisites  
sudo apt-get install \-y apt-transport-https ca-certificates curl software-properties-common

\# Add Docker's official GPG key  
curl \-fsSL \[https://download.docker.com/linux/ubuntu/gpg\](https://download.docker.com/linux/ubuntu/gpg) | sudo apt-key add \-

\# Set up the stable repository  
sudo add-apt-repository "deb \[arch=amd64\] \[https://download.docker.com/linux/ubuntu\](https://download.docker.com/linux/ubuntu) $(lsb\_release \-cs) stable"

\# Update package index again  
sudo apt-get update

\# Install Docker CE  
sudo apt-get install \-y docker-ce

\# Add the current user to the docker group to avoid using sudo  
sudo usermod \-aG docker ${USER}

\# You will need to log out and log back in for this change to take effect.

Verify the installation on each node:

docker \--version

#### **Step 4: Initialize the Swarm on the Manager Node**

1. SSH into your designated manager instance.  
2. Run the following command to initialize the swarm. Replace \<MANAGER\_IP\> with the **private IP address** of your manager instance.  
   docker swarm init \--advertise-addr \<MANAGER\_IP\>

3. The output of this command will include a docker swarm join command with a token. **Copy this entire command.** This is what your worker nodes will use to join the cluster.

*\[Image: Terminal output showing the successful initialization of the swarm and the join command.\]*

#### **Step 5: Join Worker Nodes to the Swarm**

1. SSH into worker-1 and worker-2.  
2. On each worker node, paste and run the docker swarm join command you copied from the manager node.  
3. You will see a confirmation message: "This node joined a swarm as a worker."

*\[Image: Terminal output on a worker node showing the successful join message.\]*

#### **Step 6: Verify the Cluster**

1. Go back to your manager node's SSH session.  
2. Run the following command to list all the nodes in your swarm:  
   docker node ls

3. You should see your three nodes listed, with one manager and two workers. The manager's status should be Leader.

*\[Image: Terminal output of docker node ls showing one leader manager and two worker nodes.\]*

### **3\. Useful Swarm Commands**

Here is a list of common commands for managing your Docker Swarm cluster. Run these from a manager node.

| Command | Description |
| :---- | :---- |
| docker swarm init | Initialize a new swarm. |
| docker swarm join-token worker | Display the token and command to join a worker node. |
| docker node ls | List all nodes in the swarm. |
| docker service create \--replicas 3 \-p 80:80 \--name my-web nginx | Create a service with 3 replicas of Nginx. |
| docker service ls | List all running services. |
| docker service ps \<service\_name\> | List the tasks of a service. |
| docker service inspect \<service\_name\> | View detailed information about a service. |
| docker service scale \<service\_name\>=5 | Scale a service to a new number of replicas. |
| docker service rm \<service\_name\> | Remove a service. |
| docker node promote \<node\_id\> | Promote a worker node to a manager. |
| docker node demote \<node\_id\> | Demote a manager node to a worker. |
| docker swarm leave \--force | Force a manager node to leave the swarm. |
| docker swarm leave | Make a worker node leave the swarm. |

### **4\. Troubleshooting Notes**

* **Problem: A worker node is "Down" or "Unreachable" in docker node ls.**  
  * **Solution:**  
    1. Verify network connectivity between the manager and the affected worker. Try to ping the worker's private IP from the manager.  
    2. Check that the Security Group rules are correct and allow traffic on ports 2377, 7946, and 4789\.  
    3. Inspect the Docker daemon logs on the affected worker for errors: sudo journalctl \-fu docker.service.  
* **Problem: A service's tasks fail to start.**  
  * **Solution:**  
    1. Use docker service ps \<service\_name\> to view the status of the tasks. It will often show an error message.  
    2. If the container is exiting immediately, check the logs of a failed task by finding a node it ran on and using docker logs \<container\_id\>.  
    3. Ensure the specified Docker image is correct and accessible from the worker nodes.  
* **Problem: Lost the join token.**  
  * **Solution:** Run docker swarm join-token worker on the manager node to retrieve the token and join command again.