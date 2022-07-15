variable "ETHEREUM_CLIENT" {
  default = "ralexstokes/mev-rs"
}

target "default" {
  tags = [ETHEREUM_CLIENT]
}

target "all" {
  inherits = ["default"]
  platforms = [
    "linux/amd64",
  ] 
}
