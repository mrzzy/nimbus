#
# Nimbus
# Terraform Deployment
# Moved Tombstones
#

# Tombstones for moved resources
moved {
  from = google_compute_disk.warp_disk
  to   = module.warp_vm.google_compute_disk.warp_disk
}

moved {
  from = google_compute_network.sandbox
  to   = module.gce.google_compute_network.sandbox
}

moved {
  from = google_compute_firewall.sandbox
  to   = module.gce.google_compute_firewall.sandbox
}

moved {
  from = module.gce.google_compute_network.sandbox
  to   = module.vpc.google_compute_network.sandbox
}

moved {
  from = module.k8s.kubernetes_secret.csi-rclone
  to   = module.k8s.kubernetes_secret.opaque["rclone"]
}


moved {
  from = google_app_engine_application.warp_proxy
  to   = google_app_engine_application.app
}

moved {
  from = google_app_engine_flexible_app_version.warp_proxy_v1
  to   = module.proxy_service.google_app_engine_flexible_app_version.v1
}

moved {
  from = aws_s3_bucket.lake
  to   = module.s3_lake.aws_s3_bucket.bucket
}

moved {
  from = module.s3_lake.aws_s3_bucket.bucket
  to   = module.providence.module.s3_lake.aws_s3_bucket.bucket
}

moved {
  from = module.s3_dev.aws_s3_bucket.bucket
  to   = module.providence.module.s3_dev.aws_s3_bucket.bucket
}

moved {
  from = aws_iam_user.airflow
  to   = module.providence.aws_iam_user.airflow
}

moved {
  from = aws_redshiftserverless_workgroup.warehouse
  to   = module.providence.aws_redshiftserverless_workgroup.warehouse
}

moved {
  from = aws_redshiftserverless_namespace.warehouse
  to   = module.providence.aws_redshiftserverless_namespace.warehouse
}
