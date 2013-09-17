#
# Cookbook Name:: ktc-compute
# Recipe:: compute
#

include_recipe "ktc-utils"

KTC::Attributes.set

include_recipe "ktc-network::agents"
include_recipe "ktc-compute::nova-common"

cookbook_file "/etc/init/nova-compute.conf" do
  source "etc/init/nova-compute.conf"
  action :create
end

# openstack-compute::compute recipe includes openstack-compute::api-metadata,
# which should not run on compute node. So we don't include openstack-compute::compute
# here, instead we define only necessary resources here.

# Installing nfs client packages because in grizzly, cinder nfs is supported
# Never had to install iscsi packages because nova-compute package depends it
# So volume-attach 'just worked' before - alop
platform_options = node["openstack"]["compute"]["platform"]
platform_options["nfs_packages"].each do |pkg|
  package pkg do
    options platform_options["package_overrides"]

    action :upgrade
  end
end

cookbook_file "/etc/nova/nova-compute.conf" do
  source "nova-compute.conf"
  mode   00644
  cookbook "openstack-compute"
  action :create
end

service "nova-compute" do
  service_name platform_options["compute_compute_service"]
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true
  subscribes :restart, resources("template[/etc/nova/nova.conf]")

  action [:enable, :start]
end

include_recipe "openstack-compute::libvirt"
group node["openstack"]["compute"]["libvirt"]["group"] do
  append true
  members [node["openstack"]["compute"]["group"]]

  action :create
end

# Add cgroup_device_acl option to /etc/libvirt/qemu.conf
cookbook_file "/etc/libvirt/qemu.conf" do
  source "qemu.conf.erb"
  owner "nova"
  group "nova"
  mode "0600"
  notifies :restart, resources(:service => "libvirt-bin"), :immediately
end

vb_iface = KTC::Network.if_lookup "management"
node.set["openstack"]["compute"]["libvirt"]["bind_interface"] = vb_iface
