require 'json'
require 'net/http'

module Kearny::Providers
  class Graphite < Base
    def get_data
      uri = URI.parse(build_url)

      uri.query = URI.encode_www_form(
                    target: @state['targets'],
                    from: @state['from'],
                    to: @state['to'],
                    format: 'json',
                  )
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        { data: JSON.parse(response.body) }
      else
        { error: true, message: response.body }
      end
    end

  private

    def build_url
       "http://#{self.class.config['graphite_host']}/render"
    end
  end
end
