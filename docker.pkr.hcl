variable "version" {
  type    = string
  default = ""
}

packer {
  required_plugins {
    docker = {
      version = "~> 1"
      source = "github.com/hashicorp/docker"
    }
  }
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# https://github.com/hashicorp/packer-plugin-docker/blob/main/docs/builders/docker.mdx
source "docker" "this" {
  image       = "ubuntu:jammy" # https://hub.docker.com/_/ubuntu/tags?page=1&name=jammy
  discard     = true
  pull        = true
}

build {
  sources = ["source.docker.this"]

  # provisioner "shell" {
  #   execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
  #   # script = "scripts/setup.sh"
  # }
  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      "echo Adding file to Docker Container",
      "echo \"FOO is $FOO\" > example.txt"
    ]
  }

  provisioner "shell" {
    inline = ["echo 'Build docker image'"]
  }
}
