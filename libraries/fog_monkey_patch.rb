begin
  require 'fog'
rescue LoadError
  Chef::Log.info 'fog gem not found. Attempting to install '
  # we do this cause there are some pacakges and system things that
  # may need to get installed as well as this gem
  Gem::DependencyInstaller.new.install('fog')
  require 'fog'
end

require 'fog/openstack/requests/compute/create_flavor'

module Fog
  module Compute
    class OpenStack
      # Real
      class Real
        # rubocop:disable MethodLength
        def create_flavor(attributes)
          # Get last flavor id
          flavor_ids = []
          flavors = list_flavors
          flavors.each do |flavor|
            flavor_ids << flavor['id'].to_i
          end

          attributes['id'] ||= flavor_ids.sort.last + 1
          data = {
            'flavor' => attributes
          }

          request(
            body: MultiJson.encode(data),
            expects: 200,
            method: 'POST',
            path: 'flavors'
          )
        end

        private

        def list_flavors
          list_flavors_detail.body['flavors'] +
            list_flavors_detail(is_public: false).body['flavors']
        end
      end
    end
  end
end
