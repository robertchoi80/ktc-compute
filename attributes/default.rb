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

include_attribute "openstack-compute::default"

default["openstack"]["compute"]["network"]["service_type"] = "quantum"
default["openstack"]["compute"]["network"]["plugins"] = [ "linuxbridge", "dhcp_agent", "l3_agent", "metadata_agent" ]
default["openstack"]["compute"]["network"]["quantum"]["libvirt_vif_driver"] = "nova.virt.libvirt.vif.QuantumLinuxBridgeVIFDriver"
default["openstack"]["compute"]["network"]["quantum"]["linuxnet_interface_driver"] = "nova.network.linux_net.QuantumLinuxBridgeInterfaceDriver"
default["openstack"]["compute"]["network"]["quantum"]["firewall_driver"] = "nova.virt.libvirt.firewall.IptablesFirewallDriver"
default["openstack"]["compute"]["network"]["quantum"]["security_group_api"] = "nova"
default["openstack"]["compute"]["platform"]["api_ec2_packages"] = []
default["openstack"]["compute"]["platform"]["api_os_compute_packages"] = []
default["openstack"]["compute"]["platform"]["memcache_python_packages"] = []
default["openstack"]["compute"]["platform"]["neutron_python_packages"] = []
default["openstack"]["compute"]["platform"]["compute_api_metadata_packages"] = []
default["openstack"]["compute"]["platform"]["compute_compute_packages"] = []
default["openstack"]["compute"]["platform"]["compute_network_packages"] = []
default["openstack"]["compute"]["platform"]["compute_scheduler_packages"] = []
default["openstack"]["compute"]["platform"]["compute_conductor_packages"] = []
default["openstack"]["compute"]["platform"]["compute_vncproxy_packages"] = []
default["openstack"]["compute"]["platform"]["compute_vncproxy_consoleauth_packages"] = []
default["openstack"]["compute"]["platform"]["compute_cert_packages"] = []
default["openstack"]["compute"]["platform"]["common_packages"] = []
default["openstack"]["compute"]["platform"]["libvirt_packages"] = [ "libvirt-bin", "python-libvirt", "genisoimage", "open-iscsi" ]
default["openstack"]["compute"]["platform"]["novnc"]["url"] = "https://dl.dropboxusercontent.com/u/848501/novnc.tar.gz"
default["openstack"]["compute"]["platform"]["nova"]["git_repo"] = "https://github.com/kt-cloudware/nova.git"
default["openstack"]["compute"]["platform"]["nova"]["git_ref"] = "develop"

# referenced in recipes/compute.rb
default["quantum"]["plugin"] = ""

default["memcached"]["port"] = "11211"

default["openstack"]["compute"]["identity_service_chef_role"] = "ktc-identity"
