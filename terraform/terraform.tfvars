# terraform.tfvars
#
# Provide the exact names of your pre-existing IAM roles here.
# These values will override the defaults set in variables.tf.

# This is the role from your screenshot. It allows ECS to pull the Docker image.
ecs_task_execution_role_name = "ec2_ecr_full_access_role"

# This is the role for the Strapi application container itself.
# Please double-check that this is the correct name for your second role.
ecs_task_role_name = "internship-strapi-task-role"