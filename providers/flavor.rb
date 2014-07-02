include KTC::Nova

def whyrun_supported?
  false
end

def initialize(new_resource, run_context)
  super
  # create the fog connection
  conn = Connector.new(
    auth_uri: new_resource.auth_uri,
    api_key: new_resource.user_pass,
    user: new_resource.user_name,
    tenant: new_resource.tenant_name
  )
  @nova = conn.con
end

def find_existing_flavor
  response = @nova.send 'list_flavors_detail'
  entity_list = response[:body]['flavors']
  entity_list.each do |ent|
    next if need_update?(@complete_options, ent)
    @current_resource.entity = ent
    break
  end
end

# rubocop:disable MethodLength
def load_current_resource
  @current_resource ||= Chef::Resource::KtcComputeFlavor.new @new_resource.name
  @current_resource.auth_uri @new_resource.auth_uri
  @current_resource.user_pass @new_resource.user_pass
  @current_resource.tenant_name @new_resource.tenant_name
  @current_resource.user_name @new_resource.user_name
  @current_resource.options @new_resource.options

  default_options = {
  }
  @complete_options =
    get_complete_options default_options, @new_resource.options
  @complete_options['swap'] = '' if @complete_options['swap'] == 0
  find_existing_flavor
  @complete_options['swap'] &&= @new_resource.options['swap']
end

action :create do
  if !@current_resource.entity
    resp = send_request @nova, 'create_flavor', @complete_options
    Chef::Log.info("Created flavor: #{resp[:body]['flavor']}")
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info('Flavor already exists.. Not creating.')
    Chef::Log.info("Existing flavor: #{@current_resource.entity}")
    new_resource.updated_by_last_action(false)
  end
end

action :delete do
  if @current_resource.entity
    send_request @nova, 'delete_flavor', @current_resource.entity['id']
    Chef::Log.info("Deleted flavor: #{@current_resource.entity}")
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info("Flavor doesn't exist.. Not deleting.")
    Chef::Log.info("Requested flavor: #{@complete_options}")
    new_resource.updated_by_last_action(false)
  end
end
