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