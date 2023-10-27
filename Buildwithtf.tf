terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.100.0"
    }
  }
}

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

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ciuqfa001h8s9sa7i"
    }
  }

  network_interface {
    subnet_id = "default"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/dmitry/test/Lesson14Terraform/test.pub")}"
  }
}

