sudo ovs-vsctl add-br br0
sudo ovs-vsctl add-br br1
sudo ovs-vsctl add-br br2

sudo ovs-vsctl add-port br0 ens33 

sudo ovs-vsctl add-port br1 ovs-host1 -- set interface ovs-host1 type=internal
sudo ovs-vsctl add-port br1 ovs-host2 -- set interface ovs-host2 type=internal
sudo ovs-vsctl add-port br1 ovs-host3 -- set interface ovs-host3 type=internal
sudo ovs-vsctl add-port br1 ovs-host4 -- set interface ovs-host4 type=internal

sudo ovs-vsctl add-port br2 ovs-host5 -- set interface ovs-host5 type=internal
sudo ovs-vsctl add-port br2 ovs-host6 -- set interface ovs-host6 type=internal
sudo ovs-vsctl add-port br2 ovs-host7 -- set interface ovs-host7 type=internal
sudo ovs-vsctl add-port br2 ovs-host8 -- set interface ovs-host8 type=internal

sudo ip netns add host1
sudo ip netns add host2
sudo ip netns add host3
sudo ip netns add host4
sudo ip netns add host5
sudo ip netns add host6
sudo ip netns add host7
sudo ip netns add host8

sudo ip link set ovs-host1 netns host1
sudo ip link set ovs-host2 netns host2
sudo ip link set ovs-host3 netns host3
sudo ip link set ovs-host4 netns host4
sudo ip link set ovs-host5 netns host5
sudo ip link set ovs-host6 netns host6
sudo ip link set ovs-host7 netns host7
sudo ip link set ovs-host8 netns host8

sudo ip netns exec host1 ip addr add 10.0.0.1/24 dev ovs-host1
sudo ip netns exec host2 ip addr add 10.0.0.2/24 dev ovs-host2
sudo ip netns exec host3 ip addr add 10.0.0.3/24 dev ovs-host3
sudo ip netns exec host4 ip addr add 10.0.0.4/24 dev ovs-host4
sudo ip netns exec host5 ip addr add 10.0.0.5/24 dev ovs-host5
sudo ip netns exec host6 ip addr add 10.0.0.6/24 dev ovs-host6
sudo ip netns exec host7 ip addr add 10.0.0.7/24 dev ovs-host7
sudo ip netns exec host8 ip addr add 10.0.0.8/24 dev ovs-host8

sudo ip netns exec host1 ip link set ovs-host1 up
sudo ip netns exec host2 ip link set ovs-host2 up
sudo ip netns exec host3 ip link set ovs-host3 up
sudo ip netns exec host4 ip link set ovs-host4 up
sudo ip netns exec host5 ip link set ovs-host5 up
sudo ip netns exec host6 ip link set ovs-host6 up
sudo ip netns exec host7 ip link set ovs-host7 up
sudo ip netns exec host8 ip link set ovs-host8 up
sudo ip netns exec host1 ip link set lo up
sudo ip netns exec host2 ip link set lo up
sudo ip netns exec host3 ip link set lo up
sudo ip netns exec host4 ip link set lo up
sudo ip netns exec host5 ip link set lo up
sudo ip netns exec host6 ip link set lo up
sudo ip netns exec host7 ip link set lo up
sudo ip netns exec host8 ip link set lo up

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
