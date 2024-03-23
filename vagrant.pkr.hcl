variable "version" {
  type    = string
  default = ""
}

packer {
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "vagrant" "this" {
  box_name     = "packer/generic/ubuntu2204"
  provider     = "virtualbox"
  source_path  = "generic/ubuntu2204"
  communicator = "ssh"
  skip_add     = true
  add_force    = true
}

build {
  sources = ["source.vagrant.this"]

  # provisioner "shell" {
  #   execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
  #   # script = "scripts/setup.sh"
  # }
  provisioner "shell" {
    inline = ["echo 'Build Vagrant Box'"]
}
}
