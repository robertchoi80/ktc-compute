#
# Cookbook Name:: ktc-nova
# Recipe:: compute
#

include_recipe "nova::compute"
# Add cgroup_device_acl option to /etc/libvirt/qemu.conf
cookbook_file "/etc/libvirt/qemu.conf" do
  source "qemu.conf.erb"
  owner "nova"
  group "nova"
  mode "0600"
  notifies :restart, resources(:service => "libvirt-bin"), :immediately
end

# Fix /etc/init/nova-compute.conf not to read /etc/nova/nova-compute.conf
cookbook_file "/etc/init/nova-compute.conf" do
  source "init_nova-compute.conf"
  cookbook "ktc-nova"
  action :create
  notifies :restart, resources(:service => "nova-compute"), :immediately
end

# Remove nova-compute.conf. We don't need it.
file "/etc/nova/nova-compute.conf" do
  action :delete
end

# apply fixes for nova-compute
include_recipe "osops-utils"
%w{ 1:2013.1-0ubuntu2~cloud1 1:2013.1.1-0ubuntu2~cloud0}.each do |version|
  if ::Chef::Recipe::Patch.check_package_version("nova-compute",version,node)
    template "/usr/share/pyshared/nova/network/quantumv2/api.py" do
      source "ktc-patches/api.py.#{version}"
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, resources(:service => "nova-compute"), :immediately
    end
  end
#  if ::Chef::Recipe::Patch.check_package_version("nova-compute",version,node)
#    template "/usr/share/pyshared/nova/compute/manager.py" do
#      source "ktc-patches/manager.py.#{version}"
#      owner "root"
#      group "root"
#      mode "0644"
#      notifies :restart, resources(:service => "nova-compute"), :immediately
#    end
#  end
end
