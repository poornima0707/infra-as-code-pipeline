resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
  }
}


# ---------------------------------------------------------
# ECS TASK EXECUTION ROLE
# ---------------------------------------------------------

data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.project_name}-${var.environment}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-execution-role"
    Environment = var.environment
  }
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ---------------------------------------------------------
# APPLICATION LOAD BALANCER
# ---------------------------------------------------------

resource "aws_lb" "this" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
  }
}


# ---------------------------------------------------------
# TARGET GROUP
# ---------------------------------------------------------

resource "aws_lb_target_group" "this" {
  name = "${var.project_name}-${var.environment}-tg-v2"

  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3

    interval = 30
    timeout  = 5

    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-target-group"
    Environment = var.environment
  }
}


# ---------------------------------------------------------
# ALB LISTENER
# ---------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}


# ---------------------------------------------------------
# ECS TASK DEFINITION
# ---------------------------------------------------------

resource "aws_ecs_task_definition" "this" {
  family = "${var.project_name}-${var.environment}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.cpu
  memory = var.memory

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name = "${var.project_name}-${var.environment}-container"

      image = var.container_image

      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = var.log_group_name
          "awslogs-region"        = "ap-south-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-${var.environment}-task-definition"
    Environment = var.environment
  }
}


# ---------------------------------------------------------
# ECS SERVICE
# ---------------------------------------------------------

resource "aws_ecs_service" "this" {
  name = "${var.project_name}-${var.environment}-service"

  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn

  desired_count = var.desired_count

  launch_type = "FARGATE"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets = var.private_subnet_ids

    security_groups = [
      var.ecs_security_group_id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn

    container_name = "${var.project_name}-${var.environment}-container"

    container_port = 80
  }

  depends_on = [
    aws_lb_listener.http
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-service"
    Environment = var.environment
  }
}


# ---------------------------------------------------------
# ECS AUTO SCALING TARGET
# ---------------------------------------------------------

resource "aws_appautoscaling_target" "ecs" {
  max_capacity = var.max_capacity
  min_capacity = var.min_capacity

  resource_id = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"

  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


# ---------------------------------------------------------
# ECS CPU AUTO SCALING POLICY
# ---------------------------------------------------------

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name = "${var.project_name}-${var.environment}-cpu-scaling"

  policy_type = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}