terraform {
  backend s3 {
    profile = "covidreality" # CHECKTHIS - local creds profile for doing things
    bucket = "yaleman-terraform-state" # CHECKTHIS - used for storing terraform state
    key    = "splunk_core.tfstate" # CHECKTHIS - PROBABLY SET THIS 🤔
    region = "us-east-1" # CHECKTHIS - region for the s3 terraform state bucket
  }
}

provider aws {
  profile = "covidreality" # CHECKTHIS - local creds profile for doing things
  region = "ap-southeast-2" # CHECKTHIS - where you're running all the things
}

provider acme {
  server_url = "https://acme-v02.api.letsencrypt.org/directory" 
}
