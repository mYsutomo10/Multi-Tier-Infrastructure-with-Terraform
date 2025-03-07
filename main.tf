# Create VPC network
module "vpc" {
  source      = "./modules/vpc"
  project_id  = var.project_id
  environment = var.environment
}

# Deploy frontend tier
module "frontend" {
  source              = "./modules/frontend"
  project_id          = var.project_id
  region              = var.region
  zone                = var.zone
  environment         = var.environment
  vpc_network         = module.vpc.network_name
  vpc_subnetwork      = module.vpc.frontend_subnet_name
  instance_type       = var.frontend_instance_type
  min_instances       = var.min_instances
  max_instances       = var.max_instances
  backend_address     = module.backend.backend_address
  depends_on          = [module.vpc, module.backend]
}

# Deploy backend tier
module "backend" {
  source              = "./modules/backend"
  project_id          = var.project_id
  region              = var.region
  zone                = var.zone
  environment         = var.environment
  vpc_network         = module.vpc.network_name
  vpc_subnetwork      = module.vpc.backend_subnet_name
  instance_type       = var.backend_instance_type
  min_instances       = var.min_instances
  max_instances       = var.max_instances
  db_connection_name  = module.database.connection_name
  depends_on          = [module.vpc, module.database]
}

# Deploy database tier
module "database" {
  source         = "./modules/database"
  project_id     = var.project_id
  region         = var.region
  environment    = var.environment
  vpc_network    = module.vpc.network_name
  db_tier        = var.db_tier
  depends_on     = [module.vpc]
}