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

sudo ip link add ovs-host1 type veth peer name veth-br1-host1
sudo ip link add ovs-host2 type veth peer name veth-br1-host2
sudo ip link add ovs-host3 type veth peer name veth-br1-host3
sudo ip link add ovs-host4 type veth peer name veth-br1-host4
sudo ip link add ovs-host5 type veth peer name veth-br2-host5
sudo ip link add ovs-host6 type veth peer name veth-br2-host6
sudo ip link add ovs-host7 type veth peer name veth-br2-host7
sudo ip link add ovs-host8 type veth peer name veth-br2-host8

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

ovs-vsctl add-port br1 veth-br1-host1 
ovs-vsctl add-port br1 veth-br1-host2
ovs-vsctl add-port br1 veth-br1-host3
ovs-vsctl add-port br1 veth-br1-host4
ovs-vsctl add-port br2 veth-br2-host5
ovs-vsctl add-port br2 veth-br2-host6
ovs-vsctl add-port br2 veth-br2-host7
ovs-vsctl add-port br2 veth-br2-host8

sudo ip link set veth-br1-host1 up
sudo ip link set veth-br1-host2 up
sudo ip link set veth-br1-host3 up
sudo ip link set veth-br1-host4 up
sudo ip link set veth-br2-host5 up
sudo ip link set veth-br2-host6 up
sudo ip link set veth-br2-host7 up
sudo ip link set veth-br2-host8 up

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

sudo ip netns exec host1 ping 10.0.0.2
