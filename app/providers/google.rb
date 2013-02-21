require 'garb'

module Kearny::Providers
  class Google < Base
    def get_data
      metric_class = self.class.build_metric_class(@state)
      results      = metric_class.results(self.class.client,
                                          start_date: from_date,
                                          end_date: to_date)

      metric = metric_class.metrics.elements.first
      datapoints = results.map do |result|
        next if (point = result.send(metric).to_f) == 0
        [point, self.class.to_epoch(result.date)]
      end.compact

      # TODO: Support multiple metrics?
      { data: [ target: metric, datapoints: datapoints ] }
    end

    def self.client
      if @client.nil?
        Garb::Session.login config['username'], config['password']

        @client = Garb::Management::Profile.all.detect do |profile|
          profile.web_property_id == config['web_property_id']
        end
      end
      @client
    end

    # Not the prettiest of dynamic programming, but this is how Garb wants its
    # metrics specified.
    def self.build_metric_class(config)
      @class_cache ||= {}

      if @class_cache[config].nil?
        @class_cache[config] = Class.new(GoogleAnalytic) do
          metrics Array(config['metrics'])

          if config['dimensions']
            dimensions Array(config['dimensions'])
          end
        end
      end
      @class_cache[config]
    end

  private

    class GoogleAnalytic
      extend Garb::Model
    end
  end
end
