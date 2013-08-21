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

# referenced in recipes/compute.rb
default["quantum"]["plugin"] = ""

default["memcached"]["port"] = "11211"

default["openstack"]["compute"]["identity_service_chef_role"] = "ktc-identity"
