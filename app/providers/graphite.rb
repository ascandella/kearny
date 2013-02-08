require 'json'
require 'typhoeus'

module Kearny::Providers
  class Graphite < Base
    def get_data(from, to)
      # TODO: Normalize from/to params
      response = Typhoeus::Request.new(
        "#{self.class.config['graphite_host']}/render",
        params: build_parameters(@state['targets'], from, to)
      ).run

      if response.success?
        JSON.parse(response.response_body)
      else
        { error: true, message: response.response_body }
      end
    end

  private

    def build_parameters(targets, from, to)
      {
        format: 'json',
        target: targets.join('&target='),
        from: from,
        until: to,
      }
    end
  end
end
