require 'mindbody-api/response'

module MindBody
  module Services
    class Client < Savon::Client
      
      def call(operation_name, locals = {}, &block)
        # Inject the auth params into the request and setup the
        # correct request structure
        @globals.open_timeout(MindBody.configuration.open_timeout)
        @globals.read_timeout(MindBody.configuration.read_timeout)
        @globals.log_level(MindBody.configuration.log_level)

        locals = locals.has_key?(:message) ? locals[:message] : locals
        locals = fixup_locals(locals)
        params = { :message => { 'Request' => auth_params.merge(locals) } }

        if MindBody.configuration.api_key.present?
          puts "TIMMUS API KEY FOUND"
          @globals.headers(
            {
              "API-key" => MindBody.configuration.api_key,
              "SiteID" => MindBody.configuration.site_id
            }
          )
        else
          puts "TIMMUS API KEY NOT FOUND"
        end

        # Run the request
        response = super(operation_name, params, &block)
        Response.new(response)
      end

      private

      def auth_params
        { 'SourceCredentials' => { 'SourceName' => MindBody.configuration.source_name,
                                   'Password' => MindBody.configuration.source_key,
                                   'SiteIDs' => { 'int' => MindBody.configuration.site_ids } } }
      end

      def fixup_locals(locals)
        # TODO this needs fixed to support various list types
        locals.each_pair do |key, value|
          if value.is_a? Array
            locals[key] = { 'int' => value }
          end
        end
      end
    end
  end
end
