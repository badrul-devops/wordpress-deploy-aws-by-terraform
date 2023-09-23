resource "aws_instance" "wordpress" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  key_name                    = "wordpress-project"
  subnet_id                   = aws_subnet.public1.id
  security_groups             = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

resource "aws_db_instance" "rds_instance" {
  engine                    = "mysql"
  engine_version            = "5.7"
  skip_final_snapshot       = true
  final_snapshot_identifier = "my-final-snapshot"
  instance_class            = "db.t2.micro"
  allocated_storage         = 15
  identifier                = "my-rds-instance"
  db_name	                  = "wordpress_db"
  username                  = "badrul"
  password                  = "badrul123"
  db_subnet_group_name      = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.rds_security_group.id]

  tags = {
    Name = "RDS Instance"
  }
}
resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]
  }

  tags = {
    Name = "RDS SG"
  }
}
output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}