resource "google_storage_bucket" "static-site" {
  name          = "terraformsite"
  location      = "US"
  project       = "isentropic-keep-330517"
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404Thisworked.html"
  }

  cors {
    origin          = ["http://tfsitetest.com"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}