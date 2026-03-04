variable "domain_root" {
  type        = string
  description = "Root domain for the hosted zone (e.g. bzyk0945.site)"
}

variable "tags" {
  type    = map(string)
  default = {}
}
