output "security_group" {
  value = aws_security_group.lb
}

output "listener" {
  value = aws_lb_listener.https
}
