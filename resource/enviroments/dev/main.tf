module "ecr" {
  source        = "../../modules/ecr"
  name          = "next-docker"
  holding_count = 5
}

module "network" {
  source                   = "../../modules/network"
  vpc_name                 = "${var.env}-next-vpc"
  subnet_public_name       = "${var.env}-next-public-1a"
  subnet_private_name      = "${var.env}-next-private-1a"
  internet_gateway_name    = "${var.env}-next-gateway"
  elastic_ip_name          = "${var.env}-next-eip" #変更した場合ISへ申請必要
  nat_gateway_name         = "${var.env}-next-nat-gw"
  route_table_public_name  = "${var.env}-next-public"
  route_table_private_name = "${var.env}-next-private"
}

module "alb" {
  source       = "../../modules/alb"
  vpc_id       = module.network.vpc_id
  subnet_1a_id = module.network.subnet_public_1a_id
  subnet_1c_id = module.network.subnet_public_1c_id
}

module "ecs" {
  source       = "../../modules/ecs"
  cluster_name = "next-cluster"
  vpc_id       = module.network.vpc_id
  subnet_1a_id = module.network.subnet_public_1a_id
  subnet_1c_id = module.network.subnet_public_1c_id
  alb_target_group_arn = module.alb.target_group_arn
}
