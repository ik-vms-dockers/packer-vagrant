packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = ">=1.0.0"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">=1.0.4"
    }
  }

}
source "docker" "debian" {
  discard = true
  image   = "debian:jessie"
}

build {
  name    = "docker-example"
  sources = ["source.docker.debian"]

  provisioner "shell" {
    inline = ["echo $HOST", "echo 123"]
  }

  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yaml"
    sftp_command  = "/usr/bin/false"
    use_sftp      = false
  }
}
