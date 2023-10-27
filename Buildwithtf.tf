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
  token                    = "y0_AgAAAABInuphAATuwQAAAADwPYzg6Bkb2OKrS_irllXl28Piw_Y_20w"
  cloud_id                 = "b1g076oa23iiut56kpqh"
  folder_id                = "b1gs7vib6tce4ocj9pnr"
  zone                     = "ru-central1-a"
}

#Build host
resource "yandex_compute_instance" "build" {
  name        = "build"
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
    ssh-keys = "ubuntu:${file("/home/dmitry/test/Lesson14Terraform/test.pub")}"
  }
#Configure ssh-connect to build host
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("/home/dmitry/test/Lesson14Terraform/test")
    host = yandex_compute_instance.build.network_interface.0.nat_ip_address
  }
#scp Dockerfile in build host
  provisioner "file" {
    source      = "Dockerfile"
    destination = "/home/ubuntu/Dockerfile"
  }
#Connect to build host and build image then send to docker registry
  provisioner "remote-exec" {
    inline =  [
      "sudo apt update && sudo apt install docker.io -y",
      "cd /home/ubuntu && sudo docker build -t buildtf .",
      "sudo docker login -u morgotq -p Zoipolidz1.",
      "sudo docker tag buildtf morgotq/buildtf && sudo docker push morgotq/buildtf"
    ]
  }
}

#Prod Host
resource "yandex_compute_instance" "prod" {
  name        = "prod"
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
#Configure network options
  network_interface {
    subnet_id = "e9b6m0jmtruhhm3r4bdj"
    nat            = true
  }

#Indicate the path to the ssh key
  metadata = {
    ssh-keys = "ubuntu:${file("/home/dmitry/test/Lesson14Terraform/prod.pub")}"
  }
#Configure ssh-connect to prod host
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("/home/dmitry/test/Lesson14Terraform/prod")
    host = yandex_compute_instance.prod.network_interface.0.nat_ip_address
  }
#Connect to prod host and build image from registry and run it
  provisioner "remote-exec" {
    inline =  [
      "sudo apt update && sudo apt install docker.io -y",
      "sudo docker pull morgotq/buildtf",
      "sudo docker run -d -p 8020:8080 morgotq/buildtf"
    ]
  }
}
