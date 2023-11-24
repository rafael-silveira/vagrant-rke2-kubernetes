
require "yaml"
settings = YAML.load_file "settings.yaml"

IP_SECTIONS = settings["network"]["control_ip"].match(/^([0-9.]+\.)([^.]+)$/)
IP_NW = IP_SECTIONS.captures[0]
IP_START = Integer(IP_SECTIONS.captures[1])
NUM_WORKER_NODES = settings["nodes"]["workers"]["count"]

CLUSTER_MASTER_IP = IP_NW + "#{IP_START}"

Vagrant.configure("2") do |config|
  config.vm.provision "shell", env: { "IP_NW" => IP_NW, "IP_START" => IP_START, "NUM_WORKER_NODES" => NUM_WORKER_NODES }, inline: <<-SHELL
      apt-get update -y
      echo "$IP_NW$((IP_START)) master-node" >> /etc/hosts
      for i in `seq 1 ${NUM_WORKER_NODES}`; do
        echo "$IP_NW$((IP_START+i)) worker-node0${i}" >> /etc/hosts
      done
  SHELL

  config.vm.box = settings["software"]["box"]
  config.vm.box_version = settings["software"]["box_version"]
  config.vm.box_check_update = true

  config.vm.define "master" do |master|
    master.vm.hostname = "master-node"
    master.vm.network "private_network", ip: settings["network"]["control_ip"]
    master.vm.provider "virtualbox" do |vb|
        vb.cpus = settings["nodes"]["control"]["cpu"]
        vb.memory = settings["nodes"]["control"]["memory"]
        vb.customize ["modifyvm", :id, "--groups", ("/" + settings["cluster_name"])]
        vb.customize ["modifyvm", :id, "--natnet1", "10.3/16"]
    end
    master.vm.provision "shell",
      env: {
        "DNS_SERVERS" => settings["network"]["dns_servers"].join(" "),
        "ENVIRONMENT" => settings["environment"],
        "OS" => settings["software"]["os"], 
        "CLUSTER_MASTER_IP" => CLUSTER_MASTER_IP
      },
      path: "scripts/common.sh"

    master.vm.provision "shell",
      env: {
        "RKE2_VERSION" => settings["software"]["rke2"], 
        "CLUSTER_MASTER_IP" => CLUSTER_MASTER_IP
      },
      path: "scripts/master.sh"

  end

  (1..NUM_WORKER_NODES).each do |i|

    config.vm.define "node0#{i}" do |node|
      node.vm.hostname = "worker-node0#{i}"
      node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
      node.vm.provider "virtualbox" do |vb|
          vb.cpus = settings["nodes"]["workers"]["cpu"]
          vb.memory = settings["nodes"]["workers"]["memory"]
          vb.customize ["modifyvm", :id, "--groups", ("/" + settings["cluster_name"])]
          vb.customize ["modifyvm", :id, "--natnet1", "10.3/16"]
        end
      node.vm.provision "shell",
        env: {
          "DNS_SERVERS" => settings["network"]["dns_servers"].join(" "),
          "ENVIRONMENT" => settings["environment"],
          "RKE2_VERSION" => settings["software"]["rke2"], 
          "CLUSTER_MASTER_IP" => CLUSTER_MASTER_IP, 
          "CLUSTER_NODE_IP" => IP_NW + "#{IP_START + i}",
          "OS" => settings["software"]["os"]
        },
        path: "scripts/common.sh"
      node.vm.provision "shell",
        env: {
          "DNS_SERVERS" => settings["network"]["dns_servers"].join(" "),
          "ENVIRONMENT" => settings["environment"],
          "RKE2_VERSION" => settings["software"]["rke2"], 
          "CLUSTER_MASTER_IP" => CLUSTER_MASTER_IP, 
          "CLUSTER_NODE_IP" => IP_NW + "#{IP_START + i}", 
          "OS" => settings["software"]["os"]
        },
        path: "scripts/node.sh"

    end
  end

end 
