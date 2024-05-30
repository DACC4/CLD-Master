//This file contains the value we want to output. they will be visible on the command line after an apply, and can be referenced elsewhere (if we're in a module, or with another state)
output "gce_instance_ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
