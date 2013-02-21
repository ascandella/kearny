require 'date'
require 'mixpanel_client'

module Kearny::Providers
  class Mixpanel < Base
    def get_data

      data = self.class.client.request(@state['method'], {
        event: @state['targets'][0],
        from_date: from_date.to_s,
        to_date: to_date.to_s,
      }.merge(@state['mixpanel']))

      { data: transform(data) }
    rescue ::Mixpanel::HTTPError => ex
      { error: true, message: ex.to_s }
    end

    def self.client
      @client ||= ::Mixpanel::Client.new(config.inject({}) do |memo, (k, v)|
                                           memo[k.to_sym] = v ; memo
                                         end)
    end

  private

    def transform(data)
      (data['data']['values'] || {}).map do |name, points|
        {
          target: name,
          datapoints: points.map do |date, value|
            [value, self.class.to_epoch(date)]
          end.sort_by { |_, date| date }
        }
      end
    end
  end
end
