output "cluster_name" {
  description = "The name of the GKE cluster."
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster's control plane."
  value       = google_container_cluster.primary.endpoint
  sensitive   = true # The endpoint should be treated as sensitive data.
}

output "node_pool_name" {
  description = "The name of the custom node pool."
  value       = google_container_node_pool.primary_nodes.name
}
