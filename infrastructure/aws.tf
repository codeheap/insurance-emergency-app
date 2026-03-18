# AWS Cognito Configuration

resource "aws_cognito_user_pool" "user_pool" {
  name = "insurance-emergency-app-user-pool"
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "insurance-emergency-app-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  generate_secret = false
}

# AWS RDS Configuration

resource "aws_db_instance" "default" {
  identifier = "insurance-emergency-app-db"
  allocated_storage = 20
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = "insurance_db"
  username = "admin"
  password = "password"
  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids = [aws_security_group.default.id]
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "default" {
  name       = "insurance-emergency-app-subnet-group"
  subnet_ids = [aws_subnet.default.id]
}

resource "aws_security_group" "default" {
  name        = "insurance-emergency-app-sg"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.default.id
}

# AWS S3 Configuration

resource "aws_s3_bucket" "assets_bucket" {
  bucket = "insurance-emergency-app-assets"
  versioning {
    enabled = true
  }
}

# AWS Lambda Configuration

resource "aws_lambda_function" "function" {
  function_name = "insurance-emergency-app-function"
  handler = "index.handler"
  runtime = "nodejs14.x"
  role = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("./path_to_your_lambda_code.zip")
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
      Effect = "Allow"
      Sid = ""
    }]
  })
  policy {
    name = "lambda_basic_execution"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*",
        Effect = "Allow"
      }]
    })
  }
}