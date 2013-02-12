require 'json'
require 'net/http'

module Kearny::Providers
  class Graphite < Base
    def get_data(from, to)
      # TODO: Normalize from/to params
      uri = URI.parse(build_url)

      uri.query = URI.encode_www_form(
                    target: @state['targets'],
                    from: from,
                    to: to,
                    format: 'json',
                  )

      response = Net::HTTP.get_response(uri)
      puts uri.inspect

      if response.is_a?(Net::HTTPSuccess)
        { data: JSON.parse(response.body) }
      else
        { error: true, message: response.body }
      end
    end

    def demo
      JSON.parse(STATIC_DATA[rand(STATIC_DATA.size)])
    end

  private

    def build_url
       "http://#{self.class.config['graphite_host']}/render"
    end
  end
end
