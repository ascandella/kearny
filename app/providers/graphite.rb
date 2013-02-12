require 'json'
require 'typhoeus'

module Kearny::Providers
  class Graphite < Base
    def get_data(from, to)
      # TODO: Normalize from/to params
      response = Typhoeus::Request.new(
        build_url(@state['targets'], from: from, to: to, format: 'json')
      ).run

      if response.success?
        { data: JSON.parse(response.response_body) }
      else
        { error: true, message: response.response_body }
      end
    end

    def demo
      JSON.parse(STATIC_DATA[rand(STATIC_DATA.size)])
    end

  private

    # Work around limitation in Typhoeus / param parsing where we want `target`
    # but don't want target[]=foo&target[]=bar, instead target=foo&target=bar
    # (probably a violation of some spec, but that's how graphite works.
    def build_url(targets, params = {})
      base = self.class.config['graphite_host']
      base << "/render?target=#{targets.join('&target=')}&"
      base << params.map { |k, v| "#{k}=#{v}" }.join('&')
    end
  end
end
