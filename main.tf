resource "aws_docdb_cluster_parameter_group" "main" {
  name   = "${local.prefix}-docdb"
  family = var.parameter_group_family
  tags = merge(var.tags, {Name = "${local.prefix}-docdb"})

}

resource "aws_docdb_subnet_group" "main" {
  name       = "${local.prefix}-docdb"
  subnet_ids = var.subnets
  tags = merge(var.tags, {Name = "${local.prefix}-docdb"})
}

resource "aws_security_group" "main" {
  name        = "${local.prefix}-docdb"
  description = "${local.prefix}-docdb"
  vpc_id      = var.vpc_id

  ingress {
    description      = "DOCDB"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = var.sg_cidrs
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(var.tags, {Name = "${local.prefix}-docdb"})

}


resource "aws_docdb_cluster" "main" {
  cluster_identifier      = "${local.prefix}-docdb"
  engine                  = "docdb"
  master_username         = data.aws_ssm_parameter.username.value
  master_password         = data.aws_ssm_parameter.password.value
  skip_final_snapshot     = true
  storage_encrypted = true
  db_subnet_group_name = aws_docdb_subnet_group.main.name
  vpc_security_group_ids = [ aws_security_group.main.id ]
}

 resource "aws_docdb_cluster_instance" "main" {
  count              = var.instance_count
  identifier         = "${local.prefix}-docdb-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.instance_class
}