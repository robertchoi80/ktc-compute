#
# Cookbook Name:: ktc-compute
# Recipe:: compute
#

include_recipe 'ktc-utils'

KTC::Attributes.set
include_recipe 'ktc-logging::logging'
include_recipe 'ktc-network::compute'
include_recipe 'ktc-compute::nova_common'

cookbook_file '/etc/init/nova-compute.conf' do
  source 'etc/init/nova-compute.conf'
  action :create
end

# openstack-compute::compute recipe includes openstack-compute::api-metadata,
# which should not run on compute node. So we don't include
# openstack-compute::compute here, instead we define only necessary resources
# here.

if platform?(%w(ubuntu))
  if node['openstack']['compute']['libvirt']['virt_type'] == 'kvm'
    compute_compute_package = 'kvm'
  elsif node['openstack']['compute']['libvirt']['virt_type'] == 'qemu'
    compute_compute_package = 'qemu'
  end
end

platform_options = node['openstack']['compute']['platform']
package compute_compute_package do
  options platform_options['package_overrides']
  retries 3
  action :install
end

qemu_bios = 'seabios'
package qemu_bios do
  options platform_options['package_overrides']
  retries 3
  action :install
  version '1.7.3-1ubuntu0.1'
end

# Installing nfs client packages because in grizzly, cinder nfs is supported
# Never had to install iscsi packages because nova-compute package depends it
# So volume-attach 'just worked' before - alop
platform_options['nfs_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']

    action :install
  end
end

cookbook_file '/etc/nova/nova-compute.conf' do
  source 'nova-compute.conf'
  mode 00644
  cookbook 'openstack-compute'
  action :create
end

service 'nova-compute' do
  service_name platform_options['compute_compute_service']
  provider Chef::Provider::Service::Upstart
  supports status: true, restart: true
  subscribes :restart, resources('template[/etc/nova/nova.conf]')
  subscribes :restart, "git[#{Chef::Config[:file_cache_path]}/nova]"

  action [:enable, :start]
end

include_recipe 'openstack-compute::libvirt'
group node['openstack']['compute']['libvirt']['group'] do
  append true
  members [node['openstack']['compute']['group']]

  action :create
end

# UCLOUDNG-726 : disable KSM(kernel same-page merging) on all cnodes
cookbook_file '/etc/default/qemu-kvm' do
  source 'qemu-kvm'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[qemu-kvm]', :immediately
end

service 'qemu-kvm' do
  supports start: true, restart: true
  action :start
end

# Add cgroup_device_acl option to /etc/libvirt/qemu.conf
cookbook_file '/etc/libvirt/qemu.conf' do
  source 'qemu.conf.erb'
  owner 'nova'
  group 'nova'
  mode '0600'
  notifies :restart, 'service[libvirt-bin]', :immediately
end

vb_iface = KTC::Network.if_lookup 'management'
node.set['openstack']['compute']['libvirt']['bind_interface'] = vb_iface

include_recipe 'ktc-compute::_config_az'

# process monitoring and sensu-check config
processes = node['openstack']['compute']['compute_processes']

processes.each do |process|
  sensu_check "check_process_#{process['name']}" do
    command "check-procs.rb -c 10 -w 10 -C 1 -W 1 -p #{process['name']}"
    handlers ['default']
    standalone true
    interval 30
  end
end

ktc_collectd_processes 'compute-agent-processes' do
  input processes
end

# Setup sensu check for vm port status monitoring
endpoint = Services::Endpoint.new 'identity-api'
endpoint.load

auth_uri = "http://#{endpoint.ip}:#{endpoint.port}/v2.0"
admin_tenant_name = node['openstack']['identity']['admin_tenant_name']
admin_user = node['openstack']['identity']['admin_user']
admin_pass = user_password node['openstack']['identity']['admin_user']

post_command = " -u #{admin_user} -t #{admin_tenant_name} "
post_command << "-p #{admin_pass} -e #{auth_uri} "
post_command << "-c #{node['fqdn']}"

file_name = "#{node['sensu']['directory']}/plugins/check_vm_port_status.py"

cookbook_file file_name do
  source '/etc/sensu_plugins/check_vm_port_status.py'
  mode '0755'
end

sensu_check 'check_vm_port_status' do
  command 'check_vm_port_status.py' + post_command
  handlers ['default']
  standalone true
  interval 180
  refresh 180
end
