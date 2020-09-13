#Outlining the provider (AWS, GCP, Azure) 
provider "aws" {
    version = "~> 3.2"
    region = var.regionlocal
    shared_credentials_file = "~/.aws/credentials"
}
