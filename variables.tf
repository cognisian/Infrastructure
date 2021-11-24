/**
 *	Contain user supplied values to setup Google Cloud Platform infrastructure
 */
 
/**
 * The set of variables to contain User/Project defined values required for configuring
 *  cloud resources
 */
variable "gcloud_creds" {
    description = "Local file containing gcloud credentials"
    type = string
    default = ""
}

variable "project_name" {
	description = "The project name to contain resources"
	default = "cognisian-site"
}

variable "billing_acct" {
	description = "The Google account which is used to do billing"
	default = ""
}

variable "ssh_user" {
    description = "The user to SSH into Google compute instance"
    default = ""
}

variable "ssh_pub_key_file" {
    description = "The public key file to copy to Google compute instance"
    default = ""
    sensitive = true
}

variable "ssh_pvt_key_file" {
    description = "The private key file to use to connect to Google compute instance"
    default = ""
    sensitive = true
}

variable "gcloud_regions" {
    description = "LIst of Google Cloud regions"
    type = map(string)
    default = {
        taiwan = "asia-east1"
        hong_kong = "asia-east2"
        toyko = "asia-northeast1"
        osaka = "asia-northeast2"
        seoul = "asia-northeast3"
        mumbai = "asia-south1"
        delhi = "asia-south2"
        singapore = "asia-southeast1"
        jakarta = "asia-southeast2"
        sydney = "australia-southeast1"
        melbourne = "australia-southeast2"
        warsaw = "europe-central2"
        hamina = "europe-north1"
        st-ghislain = "europe-west1"
        london = "europe-west2"
        frankfurt = "europe-west3"
        eemshaven = "europe-west4"
        zurich = "europe-west6"
        montreal = "northamerica-northeast1"
        toronto = "northamerica-northeast2"
        osasco = "southamerica-east1"
        council-bluffs = "us-central1"
        moncks-corner = "us-east1"
        ashburn = "us-east4"
        the-dalles = "us-west1"
        los-angeles = "us-west2"
        salt-lake = "us-west3"
        las-vegas = "us-west4"
    }
}

variable "gcloud_zones" {
    description = "LIst of Google Cloud zones"
    default = ["a", "b", "c", "d", "f"]
}

variable "gcloud_machine_types" {
    description = "LIst of Google Cloud machine types"
    default = ["f1-micro", "g1-small", "e2-micro", "e2-small", "e2-medium",
                           "n1-standard-1", "n1-standard-2", "n1-standard-4", 
                           "n1-standard-8", "n1-standard-16", "n1-standard-32", 
                           "n1-standard-64", "n1-standard-96", 
                           "n1-highmem-2", "n1-highmem-4",  "n1-highmem-8", 
                           "n1-highmem-16", "n1-highmem-32", "n1-highmem-64",
                           "n1-highmem-96", 
                           "n1-highcpu-2", "n1-highcpu-4",  "n1-highcpu-8", 
                           "n1-highcpu-16", "n1-highcpu-32", "n1-highcpu-64",
                           "n1-highcpu-96", 
                           "n2-standard-2", "n2-standard-4", 
                           "n2-standard-8", "n2-standard-16", "n2-standard-32", 
                           "n2-standard-64", "n2-standard-96", 
                           "n2-highmem-2", "n2-highmem-4",  "n2-highmem-8", 
                           "n2-highmem-16", "n2-highmem-32", "n2-highmem-64",
                           "n2-highmem-96", 
                           "n2-highcpu-2", "n2-highcpu-4",  "n2-highcpu-8", 
                           "n2-highcpu-16", "n2-highcpu-32", "n2-highcpu-64",
                           "n2-highcpu-96", 
                           "e2-standard-2", "e2-standard-4", 
                           "e2-standard-8", "e2-standard-16", "e2-standard-32", 
                           "e2-standard-64", "e2-standard-96", 
                           "e2-highmem-2", "e2-highmem-4",  "e2-highmem-8", 
                           "e2-highmem-16", "e2-highmem-32", "e2-highmem-64",
                           "e2-highmem-96", 
                           "e2-highcpu-2", "e2-highcpu-4",  "e2-highcpu-8", 
                           "e2-highcpu-16", "e2-highcpu-32", "e2-highcpu-64",
                           "e2-highcpu-96"]
}
