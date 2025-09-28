# iam.tf

# --- ECS Task Execution Role ---
# This data source looks up the existing IAM role that ECS uses to pull images and write logs.
# You must provide the name of this role in your variables.
data "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_execution_role_name
}

# --- ECS Task Role (Optional but good practice) ---
# This data source looks up the existing IAM role that the Strapi application itself uses.
# This role would grant permissions to other AWS services (e.g., S3).
# You must provide the name of this role in your variables.
data "aws_iam_role" "ecs_task_role" {
  name = var.ecs_task_role_name
}

