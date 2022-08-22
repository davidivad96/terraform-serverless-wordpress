// EFS File System

resource "aws_efs_file_system" "efs_file_system" {
  encrypted        = "true"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  tags = {
    Name     = "efs-file-system"
    APP_NAME = var.APP_NAME
    ENV      = var.ENV
  }
}

// EFS Mount Targets

resource "aws_efs_mount_target" "efs_mount_target_a" {
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = var.PRIVATE_SUBNETS_IDS[0]
  security_groups = [var.EFS_MOUNT_TARGETS_SECURITY_GROUP_ID]
}

resource "aws_efs_mount_target" "efs_mount_target_b" {
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = var.PRIVATE_SUBNETS_IDS[1]
  security_groups = [var.EFS_MOUNT_TARGETS_SECURITY_GROUP_ID]
}

// EFS Access Point

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.efs_file_system.id
  root_directory {
    path = "/bitnami/wordpress"
  }
  tags = {
    Name     = "efs-access-point"
    APP_NAME = var.APP_NAME
    ENV      = var.ENV
  }
}

