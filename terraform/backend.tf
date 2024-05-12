terraform {
  backend "s3" {
    bucket         = "killers78-tfstates"
    key            = "network.tfstate"
    region         = "us-east-2"     
  }
}
