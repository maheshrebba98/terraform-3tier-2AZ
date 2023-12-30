
##########################
### VPC CIDR block  ##
##########################

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "vpc_cidr_block"
  type       = string
}

##########################
### Web server | Presentation tier CIDR block -1 ##
##########################

variable "public-web-subnet-1-cidr" {
  default = "10.0.1.0/24"
  description = "public_web_subnet1"
  type       = string
}

##########################
### Web server | Presentation tier CIDR block -2 ##
##########################

variable "public-web-subnet-2-cidr" {
  default = "10.0.2.0/24"
  description = "public_web_subnet2"
  type       = string
}
##########################
### App server | Application tier CIDR block -1 ##
##########################

variable "private-app-subnet-1-cidr" {
  default = "10.0.3.0/24"
  description = "private_app_subnet1"
  type       = string
}

##########################
### App server | Application tier CIDR block -2 ##
##########################

variable "private-app-subnet-2-cidr" {
  default = "10.0.4.0/24"
  description = "private_app_subnet2"
  type       = string
}

##########################
### DB server | Database tier CIDR block -1 ##
##########################

variable "private-db-subnet-1-cidr" {
  default = "10.0.5.0/24"
  description = "private_db_subnet1"
  type       = string
}

##########################
### DB server | Database tier CIDR block -2 ##
##########################

variable "private-db-subnet-2-cidr" {
  default = "10.0.6.0/24"
  description = "private_db_subnet2"
  type       = string
}

##########################
### App tier Security Group ##
##########################

variable "ssh-locate" {
  default = "your_ip_address"
  description = "Ip address"
  type       = string
}

##########################
### DB Instance ##
##########################

variable "database-instance-class" {
  default = "db.t2.micro"
  description = "DB Instance type"
  type       = string
}

##########################
### Muiti_AZ ##
##########################

variable "multi-az-deployment" {
  default = true
  description = "Create a stand by DB Instance"
  type       = string
}
