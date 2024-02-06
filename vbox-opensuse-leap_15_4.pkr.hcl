packer {
  required_plugins {
    vagrant = {
      version = "~> 1"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variable "version" {
  type    = string
}

variable "cloud_token" {
  type    = string
  sensitive = true
}

# Source is the official OpenSUSE Leap box
source "vagrant" "opensuse_leap" {
  communicator = "ssh"
  source_path = "opensuse/Leap-15.4.x86_64"
  provider = "virtualbox"
  add_force = true
}

# Build custom box
build {
  name = "opensuse-leap15.4.x86_64"
  sources = ["source.vagrant.opensuse_leap"]

  # Update packages
  provisioner "shell" {
    inline = [
      "sudo zypper --non-interactive refresh",
      "sudo zypper --non-interactive update"
    ]
  }

  # Upload to Vagrant Cloud
  post-processor "vagrant-cloud" {
    access_token = "${var.cloud_token}"
    box_tag      = "xoan/Leap-15.4"
#    box_tag      = "xoan/test"
    version      = regex("[0-9].[0-9]+.[0-9]+", "${var.version}")
    version_description = "Packages updated"
  }
}
