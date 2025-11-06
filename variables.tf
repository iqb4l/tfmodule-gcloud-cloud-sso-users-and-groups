variable "users" {
  description = "A list of cloud sso users."
  type = list(object({
    user_name    = string
    display_name = optional(string)
    first_name   = optional(string)
    last_name    = optional(string)
    email        = optional(string)
    description  = optional(string)
  }))
  default = []
}

variable "groups" {
  description = "A list of cloud sso groups"
  type = list(object({
    group_name  = string
    description = optional(string)
    users       = optional(list(string), [])
  }))
  default = []
}