terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.100.0"
    }
  }
}
#Configure connection to my yandex.cloud
provider "yandex" {
  token                    = ""
  cloud_id                 = "b1g076oa23iiut56kpqh"
  folder_id                = "b1gs7vib6tce4ocj9pnr"
  zone                     = "ru-central1-a"
}

resource "yandex_compute_instance" "test" {
  name        = "test"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
#Chose count core and ram
  resources {
    cores  = 2
    memory = 4
  }
#Chose ubuntu 20.04 (if I want to select another OC I can do in bash 'yc compute image list --folder-id standard-images | grep ubuntu' for exemple
  boot_disk {
    initialize_params {
      image_id = "fd8ciuqfa001h8s9sa7i"
    }
  }

  network_interface {
    subnet_id = "e9b6m0jmtruhhm3r4bdj"
    nat            = true
  }

#Indicate the path to the ssh key
  metadata = {
    ssh-keys = "builder:${file("/home/dmitry/test/Lesson14Terraform/test.pub")}"
  }

  output "public_ip" {
  value = yandex_compute_instance.test.public_ip_address
}
}

