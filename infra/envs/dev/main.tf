locals {
  service = "nextjs-github"
}

module "ecr" {
  source        = "../../modules/ecr"
  name          = local.service
  holding_count = 5
}

module "network" {
  source  = "../../modules/network"
  env     = var.env
  service = local.service
}

module "alb" {
  source       = "../../modules/alb"
  env          = var.env
  service      = local.service
  vpc_id       = module.network.vpc_id
  subnet_1a_id = module.network.subnet_public_1a_id
  subnet_1c_id = module.network.subnet_public_1c_id
}

module "ecs" {
  source               = "../../modules/ecs"
  env                  = var.env
  service              = local.service
  cluster_name         = local.service
  container_name       = local.service
  vpc_id               = module.network.vpc_id
  subnet_1a_id         = module.network.subnet_private_1a_id
  subnet_1c_id         = module.network.subnet_private_1c_id
  alb_target_group_arn = module.alb.target_group_arn
  alb_sg_id            = module.alb.alb_sg_id
}
