terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# BAD SECURITY PRACTICES BELOW
# -----------------------------------------------------------------

resource "google_storage_bucket" "bad_bucket" {
  name          = var.bucket_name
  location      = "US"

  # 1. Uniform bucket-level access disabled (not recommended)
  uniform_bucket_level_access = false

  # 2. Public access allowed
  force_destroy = true  # DANGEROUS: allows deleting even if objects exist

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# 3. Public IAM binding (VERY BAD: makes bucket world-readable)
resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.bad_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",   # ANYONE ON THE INTERNET CAN READ OBJECTS
    "allAuthenticatedUsers"
  ]
}

# 4. Bucket encryption disabled (defaults to Google-managed key)
#    NOT using a CMEK → weak for sensitive data
