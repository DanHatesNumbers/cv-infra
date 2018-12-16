provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_s3_bucket" "state-bucket" {
	bucket = "danhatesnumber-cv-infra-tf-state"
	acl = "private"

	versioning = {
		enabled = true
	}
}