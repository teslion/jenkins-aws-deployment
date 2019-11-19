#######################################################################
#   Route 53   ########################################################
#######################################################################
resource "aws_route53_zone" "zone" {
  name = var.zone_name

  tags = {
    Name = "${var.project_name}_instance_DNS"
  }
}

resource "aws_route53_record" "record" {
  zone_id =  aws_route53_zone.zone.zone_id
  name    = "${var.project_name}"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.master_instance.public_ip]
}
