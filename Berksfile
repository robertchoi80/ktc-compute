#
# vim: set ft=ruby:
#
site :opscode

metadata

cookbook "ktc-base",
  github: "cloudware-cookbooks/ktc-base"
# solo-search for intgration tests
group :integration do
  cookbook 'chef-solo-search', github: 'edelight/chef-solo-search'

# cookbook ' other things from openstack'

# add in a test cook for minitest or to twiddle an LWRP
#  cookbook 'my_cook_test', :path => './test/cookbooks/my_cook_test'
end
