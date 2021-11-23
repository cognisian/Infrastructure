 output "external_ip" {
    description = "The external IP of the instance"
    value = google_compute_address.static.address
 }