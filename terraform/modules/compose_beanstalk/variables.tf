variable "access_url" {

    type = string
  
}


variable "zone_id" {

    type = string
  
}

variable "application_name" {

    type = string
  
}

variable "environment_name" {
  
  type = string
}

variable "instance_type" {

    type = string
    default = "t3a.nano"
  
}

variable "certificate_arn" {

  type = string

}