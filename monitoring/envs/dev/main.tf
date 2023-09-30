locals {
  service = "monitoring"
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"
  service   = local.service
}

/*
module "dynamodb" {
  source = "../../modules/dynamodb"
  name   = local.service
}

module "aurora" {
  source = "../../modules/aurora"
  name   = local.service
}

module "lambda" {
  source = "../../modules/lambda"
  name   = local.service
}

module "amplify" {
  source = "../../modules/amplify"
  name   = local.service
}

module "app_runnber" {
  source = "../../modules/app_runnber"
  name   = local.service
}

module "step_function" {
  source = "../../modules/step_function"
  name   = local.service
}

module "elasti_cache" {
  source = "../../modules/elasti_cache"
  name   = local.service
}
*/