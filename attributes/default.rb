# Cookbook Name:: ktc-nova
# Recipe:: default
#
# Copyright 2013, KT Cloudware
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_attribute 'openstack-compute::default'

default['openstack']['compute']['network']['service_type'] = 'quantum'
default['openstack']['compute']['network']['plugins'] = %w(
  linuxbridge
  dhcp_agent
  l3_agent
  metadata_agent
)
default['openstack']['compute']['network']['quantum']['libvirt_vif_driver'] =
  'nova.virt.libvirt.vif.QuantumLinuxBridgeVIFDriver'
default['openstack']['compute']['network']['quantum']['linuxnet_interface_driver'] =
  'nova.network.linux_net.QuantumLinuxBridgeInterfaceDriver'
default['openstack']['compute']['network']['quantum']['firewall_driver'] =
  'nova.virt.firewall.NoopFirewallDriver'

default['openstack']['compute']['network']['quantum']['security_group_api'] = 'quantum'
default['openstack']['compute']['platform']['api_ec2_packages'] = []
default['openstack']['compute']['platform']['api_os_compute_packages'] = []
default['openstack']['compute']['platform']['memcache_python_packages'] = []
default['openstack']['compute']['platform']['neutron_python_packages'] = []
default['openstack']['compute']['platform']['compute_api_metadata_packages'] = []
default['openstack']['compute']['platform']['compute_compute_packages'] = ['openstack']
default['openstack']['compute']['platform']['compute_network_packages'] = []
default['openstack']['compute']['platform']['compute_scheduler_packages'] = []
default['openstack']['compute']['platform']['compute_conductor_packages'] = []
default['openstack']['compute']['platform']['compute_vncproxy_packages'] = []
default['openstack']['compute']['platform']['compute_vncproxy_consoleauth_packages'] = []
default['openstack']['compute']['platform']['compute_cert_packages'] = []
default['openstack']['compute']['platform']['common_packages'] = []
default['openstack']['compute']['platform']['libvirt_packages'] = %w(
  libvirt-bin
  python-libvirt
  genisoimage
  open-iscsi
  virt-top
)
default['openstack']['compute']['platform']['novnc']['url'] =
  'https://dl.dropboxusercontent.com/u/848501/novnc.tar.gz'
default['openstack']['compute']['config']['cpu_allocation_ratio'] = '2.5'
default['openstack']['compute']['config']['ram_allocation_ratio'] = '0.95'
default['openstack']['compute']['config']['max_instances_per_host'] = '80'
default['openstack']['compute']['config']['quota_ram'] = '3200000'
default['openstack']['compute']['config']['quota_instances'] = '100'
default['openstack']['compute']['config']['quota_cores'] = '400'
default['openstack']['compute']['config']['quota_gigabytes'] = '250000'
default['openstack']['compute']['config']['quota_volumes'] = '500'
default['openstack']['compute']['ratelimit']['settings'] = {
  'generic-post-limit' => {
    'verb' => 'POST',
    'uri' => '*',
    'regex' => '.*',
    'limit' => '100',
    'interval' => 'MINUTE'
  },
  'create-servers-limit' => {
    'verb' => 'POST',
    'uri' => '*/servers',
    'regex' => '^/servers',
    'limit' => '500',
    'interval' => 'DAY'
  },
  'generic-put-limit' => {
    'verb' => 'PUT',
    'uri' => '*',
    'regex' => '.*',
    'limit' => '100',
    'interval' => 'MINUTE'
  },
  'changes-since-limit' => {
    'verb' => 'GET',
    'uri' => '*changes-since*',
    'regex' => '.*changes-since.*',
    'limit' => '30',
    'interval' => 'MINUTE'
  },
  'generic-delete-limit' => {
    'verb' => 'DELETE',
    'uri' => '*',
    'regex' => '.*',
    'limit' => '1000',
    'interval' => 'MINUTE'
  }
}
default['openstack']['compute']['config']['nfs_mount_options'] = 'timeo=100,retrans=1'

# referenced in recipes/compute.rb
default['quantum']['plugin'] = ''

default['memcached']['port'] = '11211'

default['openstack']['compute']['identity_service_chef_role'] = 'ktc-controller'

# vncserver listen changed
default['openstack']['compute']['vncserver_listen'] = '0.0.0.0'

# use syslog by default
default['openstack']['compute']['debug'] = true
default['openstack']['compute']['syslog']['use'] = true

# must be same as node['rsyslog']['nova_facility']
default['openstack']['compute']['syslog']['facility'] = 'LOG_LOCAL2'

# event notification
default['openstack']['compute']['notifiers'] = %w(log_notifier rpc_notifier)

# process monitoring
default['openstack']['compute']['api_processes'] = [
  { 'name' => 'nova-scheduler', 'shortname' => 'nova-scheduler' },
  { 'name' => 'nova-conductor', 'shortname' => 'nova-conductor' },
  { 'name' => 'nova-api-ec2', 'shortname' => 'nova-api-ec2' },
  { 'name' => 'nova-api-metadata', 'shortname' => 'nova-api-metada' },
  { 'name' => 'nova-api-os-compute', 'shortname' => 'nova-api-os-com' },
  { 'name' => 'nova-novncproxy', 'shortname' => 'nova-novncproxy' },
  { 'name' => 'nova-consoleauth', 'shortname' => 'nova-consoleaut' }
]

default['openstack']['compute']['compute_processes'] = [
  { 'name' => 'nova-compute', 'shortname' => 'nova-compute' },
  { 'name' => 'libvirtd', 'shortname' => 'libvirtd' }
]

default['openstack']['compute']['scheduler']['default_filters'] = %w(
  AvailabilityZoneFilter
  RamFilter
  ComputeFilter
  CoreFilter
  SameHostFilter
  DifferentHostFilter
  QuantumAgentFilter
)

default['controller_tlc'] = 'ktc-controller'
