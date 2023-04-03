variable "fleet_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_id" {
  type = string
}
  
variable "fleet_members" {
  type = map(object({
    clusterName = string
    clusterResourceId = string
  }))
}