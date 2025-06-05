variable "project_id" {
  description = "The ID of the project the quotas apply to"
  type        = string
}

variable "num_volumes" {
  description = "The number of volumes allowed"
  type        = number
  default     = 10
}

variable "num_snapshots" {
  description = "The number of snapshots allowed"
  type        = number
  default     = 4
}

variable "total_gigabytes" {
  description = "Total size of volumes in gigabytes"
  type        = number
  default     = 100
}

variable "per_volume_gigabytes" {
  description = "Maximum size per volume in gigabytes"
  type        = number
  default     = 10
}

variable "num_backups" {
  description = "Number of volume backups allowed"
  type        = number
  default     = 4
}

variable "total_backup_gigabytes" {
  description = "Total size of backups in gigabytes"
  type        = number
  default     = 10
}

variable "num_groups" {
  description = "Number of volume groups allowed"
  type        = number
  default     = 100
}

variable volume_type_quota_enabled {
    description = "Set quota for specific volume type"
    type = bool
    default = false
}

# variable "volume_type_quotas" {
#   description = "Map of custom quotas for volume types (e.g. ssd, hdd, standard)"
#   type = map(object({
#     volumes   = optional(number)
#     gigabytes = optional(number)
#     snapshots = optional(number)
#   }))
#   default = {}
# }
