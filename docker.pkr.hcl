variable "version" {
  type    = string
  default = ""
}

packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    docker = {
      version = "~> 1"
      source = "github.com/hashicorp/docker"
    }
  }
}

locals {
  os_username            = "ubuntu"
  os                     = "ubuntu"
  os_freindly_name       = "jammy-22.04"
  os_virtualization_type = "hvm"
  os_arch                = "amd64"
  timestamp              = regex_replace(timestamp(), "[- TZ:]", "")

}

# https://github.com/hashicorp/packer-plugin-docker/blob/main/docs/builders/docker.mdx
source "docker" "this" {
  image       = "ubuntu:jammy" # https://hub.docker.com/_/ubuntu/tags?page=1&name=jammy
  # discard     = true
  pull        = true
  commit      = true
  run_command = [ "-d", "-i", "-t", "--name", "default", "{{.Image}}", "/bin/bash" ]
  # changes     = [
  #   "EXPOSE 56793",
  #   "LABEL version=1.0",
  #   "ONBUILD RUN date",
  # ]
}

build {
  name    = "docker-example"
  sources = ["source.docker.this"]

  provisioner "shell" {
      inline= [
        "echo 'Etc/UTC' > /etc/timezone",
        "cat /etc/timezone",
        "echo '-${build.ID}. uuid ${build.PackerRunUUID}-'"
      ]
  }

  provisioner "ansible" {
    playbook_file      = "${path.root}/ansible/playbook.yaml"
    # inventory_file     = "${path.root}/ansible/inventory.yml"
    ansible_env_vars  = ["ANSIBLE_HOST_KEY_CHECKING=False", "ANSIBLE_SSH_ARGS='-v -o ControlMaster=auto -o ControlPersist=15m"]

    host_alias = "${build.ID}"
    # sftp_command      = "/usr/lib/sftp-server -e -l INFO"
    extra_arguments = ["--scp-extra-args", "'-O'", "-vvv",
      "-e", "ansible_connection=docker",
    ]
    user            = "root"
    # sftp_command  = "/usr/bin/false"
    # use_sftp      = false
    # local_port              = 2222
    # extra_arguments = [
    #   "--connection", "docker",
    # ]
  }

  provisioner "shell" {
      inline= [
        "cat /tmp/ansible-test",
        "git --version",
        "curl --version",
      ]
  }

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
