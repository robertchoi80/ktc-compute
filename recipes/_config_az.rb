# Configure the compute availablity zone

az = node[:openstack][:availability_zone]

# if az is not set skip all this
unless az.nil?
  # check if az exists
  bash "configure_availability_zone" do
    user "root"
    cwd "/root"
    code <<-EOH
      source /root/openrc
      /usr/local/bin/nova aggregate-list | grep #{az}
      [[ $? -ne 0 ]] && /usr/local/bin/nova aggregate-create #{az} #{az}
      /usr/local/bin/nova aggregate-details #{az} | grep #{node[:fqdn]}
      [[ $? -ne 0 ]] && /usr/local/bin/nova aggregate-add-host #{az} #{node[:fqdn]}
      touch /root/.az_configured
    EOH
    not_if { ::File.exists?("/var/chef/cache/.az_configured") }
  end
end
