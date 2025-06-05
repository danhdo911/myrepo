variable "vcd_org" {
  description = "The organization in which the app port profile exists"
  type        = string
}

variable "vcd_vdc" {
  description = "The organization in which the app port profile exists"
  type        = string
}

variable "names" {
  description = "List of NSX-T app port profile names (e.g., [\"TCP-3306\", \"TCP-22\"])"
  type        = list(string)
}
