terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
    time = {
      source = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

variable "endpoint" {
  type = string
}

resource "time_sleep" "wait" {
  create_duration = "5s"
}

data "http" "index" {
  depends_on = [ time_sleep.wait ]
  url    = var.endpoint
  method = "GET"
}
