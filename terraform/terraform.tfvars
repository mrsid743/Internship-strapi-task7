# terraform.tfvars
#
# Provide the exact names of your pre-existing IAM roles here.
# These values will override the defaults set in variables.tf.
#
# IMPORTANT: Make sure these names match your IAM roles in the AWS Console exactly.

ecs_task_execution_role_name = "internship-strapi-execution-role"
ecs_task_role_name           = "internship-strapi-task-role"
