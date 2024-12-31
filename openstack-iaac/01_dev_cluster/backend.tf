terraform { 
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "weedesign"

    workspaces {
      name = "dev-cluster"
    }
  }
}