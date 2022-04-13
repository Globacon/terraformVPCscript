// @fix: The entire file is formated using "terraform fmt" code.

// VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC for ${var.service}-${var.stage}"
  }
}

# Public Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Internet gateway for ${var.service}-${var.stage}"
  }
}

# Public subnets
resource "aws_subnet" "subnet_public_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet - Public - for ${var.service}-${var.stage}"
    CIDR = "10.0.0.0/20"
    AZ   = "us-east-1a"
  }
}

resource "aws_subnet" "subnet_public_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet - Public - for ${var.service}-${var.stage}"
    CIDR = "10.0.16.0/20"
    AZ   = "us-east-1b"
  }
}

resource "aws_network_acl" "network_acl_public" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.subnet_public_1.id,
    aws_subnet.subnet_public_2.id
  ]

  tags = {
    Name = "Network ACL - Public - for ${var.service}-${var.stage}"
  }
}

resource "aws_network_acl_rule" "network_acl_rule_inbound_public" {
  network_acl_id = aws_network_acl.network_acl_public.id
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "network_acl_rule_outbound_public" {
  network_acl_id = aws_network_acl.network_acl_public.id
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    ignore_changes = [
      propagating_vgws
    ]
  }

  tags = {
    Name = "Route table - Public - for ${var.service}-${var.stage}"
  }
}

resource "aws_route" "route_for_public" {
  route_table_id         = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "route_table_association_for_subnet_public_1_and_route_table_public" {
  subnet_id      = aws_subnet.subnet_public_1.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "route_table_association_for_subnet_public_2_and_route_table_public" {
  subnet_id      = aws_subnet.subnet_public_2.id
  route_table_id = aws_route_table.route_table_public.id
}

# Private subnets
resource "aws_subnet" "subnet_private_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.96.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet - Private - for ${var.service}-${var.stage}"
    CIDR = "10.0.96.0/20"
    AZ   = "us-east-1a"
  }
}

resource "aws_subnet" "subnet_private_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.112.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Subnet - Private - for ${var.service}-${var.stage}"
    CIDR = "10.0.112.0/20"
    AZ   = "us-east-1b"
  }
}

resource "aws_network_acl" "network_acl_private" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.subnet_private_1.id,
    aws_subnet.subnet_private_2.id
  ]

  tags = {
    Name = "Network ACL - Private - for ${var.service}-${var.stage}"
  }
}

resource "aws_network_acl_rule" "network_acl_rule_inbound_private" {
  network_acl_id = aws_network_acl.network_acl_private.id
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "network_acl_rule_outbound_private" {
  network_acl_id = aws_network_acl.network_acl_private.id
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    ignore_changes = [
      propagating_vgws
    ]
  }

  tags = {
    Name = "Route table - Private - for ${var.service}-${var.stage}"
  }
}

resource "aws_route_table_association" "route_table_association_for_subnet_private_1_and_route_table_private" {
  subnet_id      = aws_subnet.subnet_private_1.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_route_table_association" "route_table_association_for_subnet_private_2_and_route_table_private" {
  subnet_id      = aws_subnet.subnet_private_2.id
  route_table_id = aws_route_table.route_table_private.id
}

# DB subnet
resource "aws_subnet" "subnet_db_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.224.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet - DB - for ${var.service}-${var.stage}"
    CIDR = "10.0.224.0/20"
    AZ   = "us-east-1a"
  }
}

resource "aws_subnet" "subnet_db_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.240.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet - DB - for ${var.service}-${var.stage}"
    CIDR = "10.0.240.0/20"
    AZ   = "us-east-1b"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  // @fix: only lowercase alphanumeric characters, hyphens, underscores, periods, 
  //        and spaces allowed in "name"
  //        added lowr() string function to entire name.
  //        Because var.service is uppercase
  name        = lower("db-subnet-group-${(var.service)}-${var.stage}")
  description = "Subnet - DB - group for ${var.service}-${var.stage}"
  subnet_ids = [
    aws_subnet.subnet_db_1.id,
    aws_subnet.subnet_db_2.id
  ]

  tags = {
    Name = "Subnet - DB - group for ${var.service}-${var.stage}"
  }
}

resource "aws_network_acl" "network_acl_db" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.subnet_db_1.id,
    aws_subnet.subnet_db_2.id
  ]

  tags = {
    Name = "Network ACL - DB - for ${var.service}-${var.stage}"
  }
}

resource "aws_network_acl_rule" "network_acl_rule_inbound_db" {
  network_acl_id = aws_network_acl.network_acl_db.id
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "network_acl_rule_outbound_db" {
  network_acl_id = aws_network_acl.network_acl_db.id
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_route_table" "route_table_db" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Route table - DB - for ${var.service}-${var.stage}"
  }
}

resource "aws_route" "route_for_db" {
  route_table_id         = aws_route_table.route_table_db.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id

  timeouts {
    create = "5m"
  }
}

# Security Group
resource "aws_security_group" "security_group_ec2" {
  name        = "EC2"
  description = "Security group - EC2 - ${var.service}-${var.stage}"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group" "security_group_alb" {
  name        = "Application Load Balancer"
  description = "Security group - Application Load Balancer - ${var.service}-${var.stage}"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol  = "tcp"
    from_port = "80"
    to_port   = "80"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group" "security_group_rds" {
  name        = "RDS"
  description = "Security group - RDS - ${var.service}-${var.stage}"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "172.16.0.0/12"
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

// Database
/*
resource "random_string" "rds_password" {
  length  = 20
  special = false
}
*/
// @fix: For sensitive random strings it's recommended to use random_password instead of random_string
resource "random_password" "rds_password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
//change name on line 367 from insurance-db to insurancedb becos DBName must begin with a  letter and contain only alphanumeric characters.
resource "aws_db_instance" "db_instance" {
  name = "insurancedb"
  // @fix:  only lowercase alphanumeric characters and hyphens allowed in "identifier"
  //        added lower() function to entire string
  identifier = lower("${var.organization}-${var.service}-insurance-db")
  // @fix: Double quotes instead of sinlge quotes, becos it is a string.
  //Error: Error creating DB Instance: InvalidParameterValue: MasterUsername db cannot be used as it is a reserved word used by the engine
  username = "dbuser"
  // @fix: After updating random_string to random_password I updated getting the valu of it
  //      random_string.rds_password.result -> random_password.rds_password.result
  password       = random_password.rds_password.result
  engine         = "postgres"
  engine_version = "12.7"
  instance_class = "db.t3.micro"
  vpc_security_group_ids = [
    aws_security_group.security_group_rds.id
  ]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  allocated_storage       = 100
  storage_type            = "gp2"
  backup_window           = "03:40-04:40"
  backup_retention_period = 31
  // @fix: A database should not be exposed publicly. EC2 and RDS instance can be in the same network
  //        Next line should be false
  publicly_accessible       = true
  final_snapshot_identifier = "insurance-final-snapshot"
  apply_immediately         = true
  maintenance_window        = "sun:03:00-sun:03:30"

  // @fix: Multi AZ is needed for reliability.
  multi_az = true

 
  lifecycle {
    ignore_changes = [
      password
    ]
  }
}

// EC2
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.service}-${var.stage}-public-key"
  public_key = var.public_key
}

resource "aws_instance" "instance" {
  ami           = "ami-07d0cf3af28718ef8" // Ubuntu
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.security_group_ec2.id
  ]
  subnet_id = aws_subnet.subnet_private_1.id
  // @fix: Like the RDS this EC2 instace shoudl not have public address. There is no need of exposing to internet
  //        Load balancer will do exposing of the traffic.
  //        Next line should be false.
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair.key_name

  // @fix: Security related update.
  //      When the entire EBS volume is encrypted,
  //    data stored at rest on the volume, disk I/O,
  //    snapshots created from the volume, and data in-transit between EBS and EC2 are all encrypted.
  root_block_device {
    encrypted = true
  }
}

// ALB
resource "aws_alb" "alb" {
  name = "${var.service}-${var.stage}"
  subnets = [
    aws_subnet.subnet_public_1.id,
    aws_subnet.subnet_public_2.id
  ]
  // @fix: "security_groups": set of string required.
  //        Converted array by adding []
  //        Also the list should content the set of SG ids not the resource itself
  //?        so added `.id`  [aws_security_group.security_group_alb -> [aws_security_group.security_group_alb.id
  security_groups            = [aws_security_group.security_group_alb.id]
  enable_deletion_protection = true
}

resource "aws_alb_target_group" "alb_target_group" {
  name        = "${var.service}-${var.stage}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.id
  }
}

resource "aws_alb_target_group_attachment" "alb_ip_attachment" {
  target_group_arn = aws_alb_target_group.alb_target_group.arn
  target_id        = aws_instance.instance.id
  port             = 80
}
