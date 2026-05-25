resource "aws_ecs_cluster" "python_app_cluster" {
  name = "python-app-cluster-name"
}
resource "aws_ecs_task_definition" "python_app_task" {
  family                   = "python-app-task-name"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "welcome-app-container"
      image     = "${aws_ecr_repository.welcome-app-repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
  
}

resource "aws_ecs_service" "python_app_service" {
    name = "python-app-service-name"
  cluster = aws_ecs_cluster.python_app_cluster.id
  task_definition = aws_ecs_task_definition.python_app_task.arn
  launch_type = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets = [ aws_subnet.main_subnet.id ]
    security_groups = [ aws_security_group.ecs_sg.id ]
    assign_public_ip = true
  }
}