output "webserver_instances" {
    description = "The external IP of the instance"
    value = {
        for inst in tolist(google_compute_instance.webservers):
            "servers" => [{
                for tag in inst.tags:
                    tag => {
                        name = inst.name,
                        ip = inst.network_interface.0.access_config.0.nat_ip
                    }
            }]
    }
 }

output "github_actions_sa" {
    description = "email of the generated GitHub Deploy service account"
    value = google_service_account.gh_deploy_sa.email
}

output "workload_identity_pool" {
    description = "Workload Identity Pool ID"
    value = google_iam_workload_identity_pool.gh_actions_idpool.name
}

output "workload_identity_pool_provider" {
    description = "ID to use in workload_identity_provider value in your GitHub Actions YAML"
    value = "GitHub Actions workload_identity_provider = ${google_iam_workload_identity_pool_provider.gh_actions_idpool_prvdr.name}"
}
