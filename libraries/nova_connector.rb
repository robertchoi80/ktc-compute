module KTC
  module Nova
    # Connector
    class Connector
      attr_accessor :auth_uri, :user, :api_key, :tenant, :con

      def initialize(args)
        @auth_uri = args[:auth_uri]
        @user    = args[:user]
        @api_key = args[:api_key]
        @tenant  = args[:tenant]

        validate
        con
      end

      def con
        @con ||= Fog::Compute.new(
          provider: 'OpenStack',
          openstack_tenant: @tenant,
          openstack_api_key: @api_key,
          openstack_auth_url: @auth_uri + '/tokens',
          openstack_username: @user
        )
      end

      def validate
        %w/auth_uri user api_key tenant/.each do |opt|
          fail "Argument must not be empty '#{opt.to_sym}'" if opt.to_sym.nil?
        end
      end
    end
  end
end
