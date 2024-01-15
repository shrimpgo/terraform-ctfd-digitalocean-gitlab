# variables.tf: variables need to be declared
variable "do_token" {
  description = "Digital Ocean Token"
  type        = string
}

variable "region" {
  description = "The region that the reserved IP is reserved to."
  type        = string
  validation {
    condition     = contains(["nyc1", "nyc2", "nyc3", "sgp1", "tor1", "sfo1", "sfo2", "sfo3", "lon1", "blr1", "ams1", "ams2", "ams3", "fra1", "syd1"], var.region)
    error_message = "This type of region is not valid."
  }
}