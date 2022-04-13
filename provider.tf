// @fix: Added provider file. It's recommended to identify the version of the providers
// @fix: It's also recommended to have the terraform version defined.
terraform {
  required_version = "~> 1.1.5"
  // @fix: A local backend is defined for the convenince
  //      but it's recommened to have a remote backend for security
  //      A remote backend configuration will require creation of the S3 bucket to be used
  //      A sample:
 
  backend "s3" {
    bucket = "ismailademo"
    # original value "path/to/the/key/of/the/state"
    key    = "terraformstate"
    region = "us-east-1"
  }
  
#   backend "local" {
#     path = "./terraform.tfstate"
#   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}
