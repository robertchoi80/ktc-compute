#
# Cookbook Name:: ktc-compute
# Recipe:: package_setup
#

include_recipe "sudo"
include_recipe "ktc-package"

group node["openstack"]["compute"]["group"] do
  system true
end

user node["openstack"]["compute"]["user"] do
  home "/var/lib/nova"
  gid node["openstack"]["compute"]["group"]
  shell "/bin/sh"
  system  true
  supports :manage_home => true
end

sudo "nova_sudoers" do
  user     node["openstack"]["compute"]["user"]
  host     "ALL"
  runas    "root"
  nopasswd true
  commands ["/usr/bin/nova-rootwrap"]
end

%w|
  /var/cache/nova
  /var/cache/nova/api
  /var/lib/nova/.python-eggs
  /var/lib/nova/instances
  /var/log/nova
  /var/run/nova
|.each do |p|
  directory "#{p}" do
    owner node["openstack"]["compute"]["user"]
    group node["openstack"]["compute"]["group"]
    mode 00755
    action :create
  end
end

%w/
  nova-all
  nova-api
  nova-api-ec2
  nova-api-metadata
  nova-api-os-compute
  nova-baremetal-deploy-helper
  nova-baremetal-manage
  nova-cells
  nova-cert
  nova-clear-rabbit-queues
  nova-compute
  nova-conductor
  nova-console
  nova-consoleauth
  nova-dhcpbridge
  nova-manage
  nova-network
  nova-novncproxy
  nova-objectstore
  nova-rootwrap
  nova-rpc-zmq-receiver
  nova-scheduler
  nova-spicehtml5proxy
  nova-xvpvncproxy
/.each do |p|
  link "/usr/bin/#{p}" do
    to "/opt/openstack/nova/bin/#{p}"
  end
end

link "/usr/bin/nova" do
  to "/opt/openstack/novaclient/bin/nova"
end
