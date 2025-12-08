output "cluster_name" {
  value = module.eks.cluster_name
}

output "grafana_url" {
  value = module.observability.grafana_url
}
