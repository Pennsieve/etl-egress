# CREATE LAMBDA FUNCTION
resource "aws_lambda_function" "lambda_function" {
  function_name     = "${var.environment_name}-${var.service_name}-${var.tier}-lambda-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
  role              = data.terraform_remote_state.etl_infrastructure.outputs.lambda_iam_role_arn
  handler           = "egress.lambda_handler"
  runtime           = "python2.7"
  s3_bucket         = data.aws_s3_bucket_object.s3_bucket_object.bucket
  s3_key            = data.aws_s3_bucket_object.s3_bucket_object.key
  s3_object_version = data.aws_s3_bucket_object.s3_bucket_object.version_id
  timeout           = 30

  vpc_config {
    subnet_ids         = tolist(data.terraform_remote_state.vpc.outputs.private_subnet_ids)
    security_group_ids = [data.terraform_remote_state.platform_infrastructure.outputs.etl_security_group_id]
  }

  environment {
    variables = {
      VERSION = var.version_number
    }
  }
}

# CREATE BATCH LAMBDA FUNCTION PERMISSION
resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  count         = length(data.terraform_remote_state.etl_infrastructure.outputs.batch_job_queues)
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = element(aws_cloudwatch_event_rule.cloudwatch_event_rule.*.arn, count.index)
  statement_id  = "AllowExecutionFromEvents${count.index}"
}

# CREATE ECS LAMBDA FUNCTION PERMISSION
resource "aws_lambda_permission" "ecs_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_cloudwatch_event_rule.arn
  statement_id  = "AllowExecutionFromEvents"
}
