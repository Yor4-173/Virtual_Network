sudo ovs-vsctl add-br br0
sudo ovs-vsctl add-br br1
sudo ovs-vsctl add-br br2

sudo ovs-vsctl add-port br0 ens33 

sudo ovs-vsctl add-port br1 ovs-host1 -- set interface ovs-host1 type=internal
sudo ovs-vsctl add-port br1 ovs-host1 -- set interface ovs-host2 type=internal
sudo ovs-vsctl add-port br1 ovs-host1 -- set interface ovs-host3 type=internal
sudo ovs-vsctl add-port br1 ovs-host1 -- set interface ovs-host4 type=internal

sudo ovs-vsctl add-port br2 ovs-host1 -- set interface ovs-host5 type=internal
sudo ovs-vsctl add-port br2 ovs-host1 -- set interface ovs-host6 type=internal
sudo ovs-vsctl add-port br2 ovs-host1 -- set interface ovs-host7 type=internal
sudo ovs-vsctl add-port br2 ovs-host1 -- set interface ovs-host8 type=internal

sudo nano ovs_ip.sh
sudo chmod +x ovs_ip.sh
./ ovs_ip.sh

sudo ovs-vsctl add-port br1 patch-br1-br0 -- set interface patch-br1-br0 type=patch options:peer=patch-br0-br1
sudo ovs-vsctl add-port br0 patch-br0-br1 -- set interface patch-br0-br1 type=patch options:peer=patch-br1-br0

sudo ovs-vsctl add-port br2 patch-br2-br0 -- set interface patch-br2-br0 type=patch options:peer=patch-br0-br2
sudo ovs-vsctl add-port br0 patch-br0-br2 -- set interface patch-br0-br2 type=patch options:peer=patch-br2-br0


sudo ovs-vsctl set-controller br0 tcp:192.168.1.86:6633 tcp:192.168.1.142:6633
sudo ovs-vsctl set-controller br1 tcp:192.168.1.86:6633 tcp:192.168.1.142:6633
sudo ovs-vsctl set-controller br2 tcp:192.168.1.86:6633 tcp:192.168.1.142:6633

sudo ovs-vsctl set-fail-mode br0 standalone
sudo ovs-vsctl set-fail-mode br1 standalone
sudo ovs-vsctl set-fail-mode br2 standalone

sudo ip addr add 10.0.0.1/24 dev br1
sudo ip addr add 10.0.0.2/24 dev br2
