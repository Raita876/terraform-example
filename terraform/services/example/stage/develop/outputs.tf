output "load_balancer_dns_name" {
  value = "http://${module.application.load_balancer_dns_name}"
}
