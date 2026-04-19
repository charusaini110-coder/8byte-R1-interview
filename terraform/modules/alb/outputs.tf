output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.frontend_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.frontend_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.frontend_alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app_tg.arn
}
