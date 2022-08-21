// Aurora Database

resource "aws_db_subnet_group" "db_subnet" {
  name        = "db-subnet-group"
  description = "Aurora DB subnet group"
  subnet_ids  = var.PRIVATE_SUBNETS_IDS
  tags = {
    Name     = "db-subnet-group"
    APP_NAME = var.APP_NAME
    ENV      = var.ENV
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier        = "aurora-cluster"
  availability_zones        = var.DB_AVAILABILITY_ZONES
  master_username           = "admin"
  master_password           = var.AURORA_DB_PASSWORD
  port                      = 3306
  database_name             = "wordpress_db"
  engine                    = "aurora-mysql"
  engine_mode               = "serverless"
  engine_version            = "5.7.mysql_aurora.2.08.3"
  db_subnet_group_name      = aws_db_subnet_group.db_subnet.name
  skip_final_snapshot       = false
  final_snapshot_identifier = "aurora-cluster-final-snapshot"
  tags = {
    Name     = "aurora-cluster"
    APP_NAME = var.APP_NAME
    ENV      = var.ENV
  }
}
