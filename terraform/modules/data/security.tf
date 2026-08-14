resource "aws_security_group" "mysql" {
  name        = "${var.name_prefix}-mysql-sg"
  description = "Allow MySQL from EKS worker nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from the EKS cluster security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-mysql-sg"
  }
}

resource "aws_security_group" "postgres" {
  name        = "${var.name_prefix}-postgres-sg"
  description = "Allow PostgreSQL from EKS worker nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from the EKS cluster security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-postgres-sg"
  }
}

resource "aws_db_subnet_group" "bedrock" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnets"
  }
}
