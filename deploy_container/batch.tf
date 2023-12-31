resource "aws_batch_compute_environment" "ecs_batch" {
  compute_environment_name = "container_fargate_batch"

  compute_resources {
    max_vcpus = 16

    security_group_ids = [
      aws_security_group.ecs_security_Group.id
    ]

    subnets = [
      aws_subnet.ecs_subnet.id
    ]

    type = "FARGATE"
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role,aws_security_group.ecs_security_Group]
}

resource "aws_batch_job_definition" "ecs_batch_job" {
  name = "ecs_batch_job_definition"
  type = "container"

  platform_capabilities = [
    "FARGATE",
  ]

  container_properties = jsonencode({
    image      = "${var.ecr_url}:latest"
    jobRoleArn = aws_iam_role.ecs_data_role.arn

    fargatePlatformConfiguration = {
      platformVersion = "LATEST"
    }

    resourceRequirements = [
      {
        type  = "VCPU"
        value = "0.25"
      },
      {
        type  = "MEMORY"
        value = "512"
      }
    ]

    executionRoleArn = aws_iam_role.ecs_task_execution_role.arn
  })
}

resource "aws_batch_job_queue" "ecs_queue" {
  name     = "fargate-etl-batch-job-queue"
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.ecs_batch.arn
  ]
}