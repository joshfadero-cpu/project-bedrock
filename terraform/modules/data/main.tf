# ------------------------------------------------------------------
# Managed data layer: RDS MySQL for catalog, RDS PostgreSQL for
# orders, DynamoDB for carts. These replace the in-cluster databases
# the sample application ships with.
# ------------------------------------------------------------------

# ---------------- Catalog: MySQL ----------------

resource "aws_db_instance" "catalog" {
  identifier     = "${var.name_prefix}-catalog-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.catalog_db_name
  username = var.catalog_db_username
  password = random_password.catalog.result
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.bedrock.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = var.backup_retention_days
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = {
    Name = "${var.name_prefix}-catalog-mysql"
  }
}

# ---------------- Orders: PostgreSQL ----------------

resource "aws_db_instance" "orders" {
  identifier     = "${var.name_prefix}-orders-postgres"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.orders_db_name
  username = var.orders_db_username
  password = random_password.orders.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.bedrock.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = var.backup_retention_days
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = {
    Name = "${var.name_prefix}-orders-postgres"
  }
}

# ---------------- Carts: DynamoDB ----------------

resource "aws_dynamodb_table" "carts" {
  name         = var.carts_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  # The carts service queries baskets by customer through this index.
  # Confirmed by reading DynamoItemEntity in the cart service source:
  # @DynamoDbSecondaryPartitionKey(indexNames = { "idx_global_customerId" })
  global_secondary_index {
    name            = "idx_global_customerId"
    hash_key        = "customerId"
    projection_type = "ALL"
  }

  tags = {
    Name = var.carts_table_name
  }
}
