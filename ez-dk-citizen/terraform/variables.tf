variable "admin_local_origin" {
  description = "Local Admin browser origin allowed to upload directly to S3."
  type        = string
  default     = "http://127.0.0.1:5173"

  validation {
    condition     = can(regex("^https?://[^/]+$", var.admin_local_origin))
    error_message = "admin_local_origin must be an HTTP(S) origin without a path."
  }
}

variable "admin_production_origin" {
  description = "Optional production Admin browser origin allowed to upload directly to S3."
  type        = string
  default     = null
  nullable    = true

  validation {
    # The Admin hashes uploads with WebCrypto, which browsers offer only in a secure context.
    condition     = var.admin_production_origin == null || can(regex("^https://[^/]+$", var.admin_production_origin))
    error_message = "admin_production_origin must be null or an HTTPS origin without a path."
  }
}
