output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "ec2_iam_role" {
  value = aws_iam_role.ec2.name
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "rds_port" {
  value = aws_db_instance.postgres.port
}

output "rds_database_name" {
  value = aws_db_instance.postgres.db_name
}

output "deployment_bucket_name" {
  value = aws_s3_bucket.deployments.bucket
}

output "deployment_bucket_arn" {
  value = aws_s3_bucket.deployments.arn
}

output "ec2_instance_id" {
  value = aws_instance.platform.id
}

output "ec2_private_ip" {
  value = aws_instance.platform.private_ip
}

output "ec2_public_ip" {
  value = aws_instance.platform.public_ip
}

output "ec2_ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "alb_id" {
  value = aws_lb.platform.id
}

output "alb_dns_name" {
  value = aws_lb.platform.dns_name
}

output "alb_zone_id" {
  value = aws_lb.platform.zone_id
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.platform.arn
}

output "database_secret_arn" {
  value = aws_secretsmanager_secret.database.arn
}