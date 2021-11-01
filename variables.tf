/**
 *	Contain user supplied values to setup Google Cloud Platform infrastructure
 */
 
/**
 * The set of variables to contain User/Project defined values required for configuring
 *  cloud resources
 */
variable "project_name" {
	description = "The project name to contain resources"
	default = "cognisian"
}

variable "org_id" {
	description = "The organization which owns the project"
	default = ""
}

variable "billing_acct" {
	description = "The Google account which is used to do billing"
	default = ""
}

/**
 * The set of variables to contain Google defined values required for configuring
 *  cloud resources
 */
variable "gcloud_creds" {
	description = "Local file containing gcloud credentials"
	type = string
	sensitive = true
}

variable "gcloud_os_image" {
	description = "Google OS disk image name"
	default = ""
}

variable "gcloud_region" {
	description = "Google Cloud region"
	default = "us-central1"
}

variable "gcloud_zone" {
	description = "Google Cloud zone"
	default = "us-central1-c"
}