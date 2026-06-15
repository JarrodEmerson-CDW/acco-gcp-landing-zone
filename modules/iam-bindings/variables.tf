variable "bindings" {
  description = <<-EOT
    Map of IAM bindings to create.
    Key = arbitrary unique label (e.g. "project/prj-dv-network/gcp-dv-admins/viewer").
    - resource_type : "organization" | "folder" | "project"
    - resource_id   : numeric org ID, folder ID (folders/NNN), or project ID string
    - member        : IAM member string, e.g. "group:gcp-dv-admins@accoes.com"
    - role          : IAM role, e.g. "roles/viewer"
    - condition     : optional IAM condition block (title, description, expression)
  EOT
  type = map(object({
    resource_type = string
    resource_id   = string
    member        = string
    role          = string
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}
}
