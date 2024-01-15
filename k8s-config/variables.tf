variable "cloudflare_api_token" {
  description = "Cloudflare API Token for DNS editing"
  type        = string
}

variable "tools_namespace" {
  description = "Kubernetes namespace for tools"
  type        = string
}

variable "CI_JOB_TOKEN" {
  description = "Gitlab Token"
  type        = string
}

variable "CI_PROJECT_ID" {
  description = "Gitlab Project ID"
  type        = string
}

variable "gitlab_token" {
  description = "Gitlab Token Access"
  type        = string
}