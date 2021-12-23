###########
# SERVERS #
###########

resource "aws_security_group" "k3s_cp_sg" {
  name        = "k3s-cp-sg"
  description = "Allow traffic for K8S Control Plane"
  vpc_id      = aws_vpc.k3s_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "k3s-cp-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
    Owner                                       = var.tfuser
  }
}

resource "aws_security_group_rule" "k3s_cp_sg_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s_cp_sg.id
}

resource "aws_security_group_rule" "k3s_cp_ingress" {
  description       = "Ingress Control Plane"
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s_cp_sg.id
}

###############
# INIT SERVER #
###############

resource "aws_instance" "init_server" {
  ami           = var.amis[var.region][var.os].ami
  instance_type = var.k3s_server_size
  count         = 1

  root_block_device {
    volume_type = "standard"
    volume_size = 30
  }

  subnet_id                   = aws_subnet.k3s_public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.k3s_cp_sg.id]
  associate_public_ip_address = var.is_public

  iam_instance_profile = aws_iam_instance_profile.k3s_master_iam_profile.name

  key_name = "${var.tfuser}-keypair"

  user_data = base64encode(data.template_file.init_server_userdata.rendered)

  tags = {
    Name                                        = "k3s-init-server"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
    Owner                                       = var.tfuser
  }
}

###########
# SERVERS #
###########

resource "aws_instance" "server" {
  ami           = var.amis[var.region][var.os].ami
  instance_type = var.k3s_server_size
  count         = 2

  root_block_device {
    volume_type = "standard"
    volume_size = 30
  }

  subnet_id                   = aws_subnet.k3s_public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.k3s_cp_sg.id]
  associate_public_ip_address = var.is_public

  iam_instance_profile = aws_iam_instance_profile.k3s_master_iam_profile.name

  key_name = "${var.tfuser}-keypair"

  user_data = base64encode(data.template_file.server_userdata.rendered)

  tags = {
    Name                                        = "k3s-server-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
    Owner                                       = var.tfuser
  }
}

#####################
# CONTROL PLANE ELB #
#####################

resource "aws_elb" "k3s_cp_elb" {
  name = "k3s-cp-elb-${random_string.random_append.result}"

  subnets = [aws_subnet.k3s_public_subnet_1.id, aws_subnet.k3s_public_subnet_2.id]

  listener {
    instance_port     = 6443
    instance_protocol = "tcp"
    lb_port           = 6443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:6443"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name                                        = "k3s-cp-elb"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
  }

  security_groups = [aws_security_group.k3s_cp_sg.id]
}

resource "aws_elb_attachment" "k3s_initserver_lb_attachment" {
  elb      = aws_elb.k3s_cp_elb.id
  instance = aws_instance.init_server[0].id
}

resource "aws_elb_attachment" "k3s_server0_lb_attachment" {
  elb      = aws_elb.k3s_cp_elb.id
  instance = aws_instance.server[0].id
}

resource "aws_elb_attachment" "k3s_server1_lb_attachment" {
  elb      = aws_elb.k3s_cp_elb.id
  instance = aws_instance.server[1].id
}
