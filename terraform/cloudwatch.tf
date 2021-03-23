#// CREATE ECS CLOUDWATCH EVENT RULE
#resource "aws_cloudwatch_event_rule" "uploads_cloudwatch_event_rule" {
#  name        = "${var.environment_name}-${var.service_name}-uploads-rule-${data.terraform_remote_state.region.aws_region_shortname}"
#  description = "Capture ECS events from Uploads Consumer."
#
#  #depends_on  = ["aws_lambda_function.lambda_function"]
#
#  event_pattern = <<PATTERN
#{
#  "detail-type": [ "ECS Task State Change" ],
#  "source": [ "aws.ecs" ],
#  "detail": {
#    "group": [
#    "family:${var.environment_name}-uploads-consumer-${data.terraform_remote_state.region.aws_region_shortname}"
#    ],
#    "lastStatus": [
#      "STOPPED",
#      "RUNNING"
#    ]
#  }
#}
#PATTERN
#}

// CREATE CLOUDWATCH EVENT RULE
resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule" {
  name        = "${var.environment_name}-${var.service_name}-batch-queue-rule-${count.index}-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
  count       = length(data.terraform_remote_state.etl_infrastructure.outputs.batch_job_queues)
  description = "Capture Batch events from ETL."

  #depends_on  = ["aws_lambda_function.lambda_function"]

  event_pattern = <<PATTERN
{
  "detail-type": [ "Batch Job State Change" ],
  "detail": {
    "jobQueue": [
        "${data.terraform_remote_state.etl_infrastructure.outputs.batch_job_queues[count.index]}"
    ]
  },
  "source": [ "aws.batch" ]
}
PATTERN
}

// CREATE ECS CLOUDWATCH EVENT RULE
resource "aws_cloudwatch_event_rule" "ecs_cloudwatch_event_rule" {
  name        = "${var.environment_name}-${var.service_name}-ecs-rule-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
  description = "Capture ECS events for ETL."

  #depends_on  = ["aws_lambda_function.lambda_function"]

  event_pattern = <<PATTERN
{
  "detail-type": [ "ECS Task State Change" ],
  "source": [ "aws.ecs" ],
  "detail": {
    "group": [
    "family:${var.environment_name}-etl-nextflow-task-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
    ],
    "lastStatus": [
      "PENDNING",
      "RUNNING",
      "STOPPED"
    ]
  }
}
PATTERN
}

#// CREATE UPLOADS CLOUDWATCH EVENT TARGET
#resource "aws_cloudwatch_event_target" "uploads_cloudwatch_event_target" {
#  target_id = "${var.environment_name}-${var.service_name}-uploads-rule-target-${data.terraform_remote_state.region.aws_region_shortname}"
#  rule      = "${aws_cloudwatch_event_rule.uploads_cloudwatch_event_rule.name}"
#  arn       = "${aws_lambda_function.lambda_function.arn}"
#}

// CREATE CLOUDWATCH EVENT TARGET
resource "aws_cloudwatch_event_target" "ecs_cloudwatch_event_target" {
  target_id = "${var.environment_name}-${var.service_name}-ecs-queue-rule-target-${count.index}-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
  count     = length(data.terraform_remote_state.etl_infrastructure.outputs.batch_job_queues)
  rule      = aws_cloudwatch_event_rule.ecs_cloudwatch_event_rule.name
  arn       = aws_lambda_function.lambda_function.arn
}

// CREATE CLOUDWATCH EVENT TARGET
resource "aws_cloudwatch_event_target" "cloudwatch_event_target" {
  target_id = "${var.environment_name}-${var.service_name}-batch-queue-rule-target-${count.index}-${data.terraform_remote_state.region.outputs.aws_region_shortname}"
  count     = length(data.terraform_remote_state.etl_infrastructure.outputs.batch_job_queues)
  rule      = element(aws_cloudwatch_event_rule.cloudwatch_event_rule.*.name, count.index)
  arn       = aws_lambda_function.lambda_function.arn
}
