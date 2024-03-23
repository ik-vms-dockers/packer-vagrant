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
    hashicups = {
      version = "~> 1"
      source  = "github.com/hashicorp/hashicups"
    }
    comment = {
      version = ">= v0.2.23"
      source  = "github.com/sylviamoss/comment"
    }
  }
}

locals { timestamp = formatdate("DDMMYY-hhmm", timestamp()) }

source "vagrant" "this" {
  box_name     = "packer/generic/ubuntu2204"
  provider     = "virtualbox"
  source_path  = "generic/ubuntu2204"
  communicator = "ssh"
  skip_add     = true
  add_force    = true
  skip_package = true
  teardown_method = "destroy"
  output_dir   = "vm/ubuntu2204-${local.timestamp}"
}

# source "null" "basic-example" {
#   communicator = "none"
# }

build {
  name    = "ubuntu-${local.timestamp}"
  sources = ["source.vagrant.this"]

  # provisioner "shell" {
  #   execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
  #   # script = "scripts/setup.sh"
  # }

  provisioner "comment" {
    comment = "*****Basic example to test with LATEST packer*****"
    ui = true
  }

  provisioner "shell" {
    inline = ["echo 'Build Vagrant Box ${local.timestamp}'",
    "echo HOST $HOST",
    "echo UUID ${build.PackerRunUUID}",
    ]
  }

  # post-processor "checksum" { # checksum image
  #   checksum_types = [ "md5", "sha512" ] # checksum the artifact
  #   keep_input_artifact = false           # keep the artifact
  # }
}
