module KTC
  # Nova
  module Nova
    def find_existing_entity(con, list_type, request_options)
      response = con.send "list_#{list_type}", request_options
      entity_list = response[:body][list_type]
      entity_list.each do |ent|
        return ent unless need_update?(request_options, ent)
      end
      nil
    end

    # rubocop:disable Eval
    def store_id_in_attr(id, attr_path)
      attr_name = "node.set.#{attr_path}"
      eval "#{attr_name} = '#{id}'"
      Chef::Log.info "Set #{attr_name} to '#{id}'"
    end

    # rubocop:disable RedundantBegin,RescueException
    def send_request(con, request, entity_options = {}, *args)
      begin
        con.send(request, *args, entity_options)
      rescue Exception => e
        Chef::Log.error "An error occured with options: #{entity_options}"
        raise e
      end
    end

    # rubocop:disable MethodLength
    def get_id_from_macro(macro, search_map)
      macro_list = [:router, :network, :subnet, :port]
      if macro_list.include? macro
        if search_map.key? macro
          entity = find_existing_entity "#{macro.to_s}s", search_map[macro]
          id = entity['id']
        else
          fail "Must give :#{macro} options in 'search_id' attribute"
        end
      else
        fail "Macro must be one of #{macro_list}. You gave :#{macro}."
      end
      id
    end

    def compile_options(options, search_map)
      compiled_options = {}
      options.each do |k, v|
        if v.kind_of? Hash
          compiled_v = compile_options v, search_map
        elsif (v.kind_of? Symbol) && (v != :null)
          compiled_v = get_id_from_macro v, search_map
        else
          compiled_v = v
        end
        compiled_options[k] = compiled_v
      end
      compiled_options
    end

    def get_complete_options(default_options, resource_options)
      default_options.each do |k, v|
        if (v.nil?) && (!resource_options.key? k)
          fail "Must give option \"#{k}\". Given options: #{resource_options}"
        end
      end
      complete_options = default_options.clone
      complete_options.merge!(resource_options)
    end

    def need_update?(required_options, existing_options)
      !(required_options.to_a - existing_options.to_a).empty?
    end
  end
end
