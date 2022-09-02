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

resource "aws_efs_access_point" "efs_file_system_access_point" {
  file_system_id = aws_efs_file_system.efs_file_system.id
  posix_user {
    uid = 1000
    gid = 1000
  }
  root_directory {
    path = "/bitnami"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0777"
    }
  }
  tags = {
    Name     = "efs-file-system-access-point"
    APP_NAME = var.APP_NAME
    ENV      = var.ENV
  }
}
