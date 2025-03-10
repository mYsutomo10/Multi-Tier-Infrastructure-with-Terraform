module "vpc" {
  source     = "./modules/vpc"
  project_id = var.project_id
  region     = var.region
  vpc_name   = "${var.vpc_name}-${var.environment}"
  subnet_cidr = var.subnet_cidr
}

module "iam" {
  source     = "./modules/iam"
  project_id = var.project_id
  environment = var.environment
}

module "security" {
  source     = "./modules/security"
  project_id = var.project_id
  vpc_id     = module.vpc.vpc_id
  environment = var.environment
}

module "database" {
  source     = "./modules/database"
  project_id = var.project_id
  region     = var.region
  environment = var.environment
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.subnet_id
  db_tier    = var.db_tier
  depends_on = [module.vpc, module.security]
}

module "backend" {
  source     = "./modules/backend"
  project_id = var.project_id
  region     = var.region
  environment = var.environment
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.subnet_id
  machine_type = var.backend_machine_type
  instance_count = var.backend_instance_count
  service_account_email = module.iam.backend_service_account_email
  database_connection_string = module.database.connection_string
  depends_on = [module.vpc, module.database, module.iam, module.security]
}

module "frontend" {
  source     = "./modules/frontend"
  project_id = var.project_id
  region     = var.region
  environment = var.environment
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.subnet_id
  machine_type = var.frontend_machine_type
  instance_count = var.frontend_instance_count
  service_account_email = module.iam.frontend_service_account_email
  backend_url = module.backend.backend_endpoint
  depends_on = [module.vpc, module.backend, module.iam, module.security]
}