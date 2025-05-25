output "ec2_public_ips" {
  value = [
    for instance in aws_instance.my_instance : {
        name        = instance.tags["Name"]
        public_ip   = instance.public_ip

    }
  ]
}