include_attribute "ktc-base::users"

node['authorization']['sudo']['users'] << 'nova'
