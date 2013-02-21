require 'yaml'
require 'chronic'

module Kearny::Providers
  class << self
    # Allow dynamic class loading. Useful so that only the features you need
    # are loaded, and the unused ones may have their dependencies omitted from
    # the Gemfile.
    def fetch(provider)
      class_name = provider.capitalize
      return const_get(class_name) if const_defined?(class_name)

      begin
        require_relative provider.downcase
      rescue LoadError
        logger.error "No provider found for #{provider}"
      end

      return const_get(class_name)
    end
  end

  class Base
    def initialize(state)
      @state = state
    end

    def from_date
      self.class.parse_time(@state['from']).to_date rescue nil
    end

    def to_date
      self.class.parse_time(@state['to']).to_date rescue Time.now
    end

    def demo
      num_points = 50
      start_time = (Time.now - (60 * num_points)).to_i
      {
        data: (1..rand(5)).to_a.map do |series|
          {
            target: "demo-#{series}",
            datapoints: (0..num_points).to_a.map do |point|
              [rand(45), start_time + (60 * point)]
            end
          }
        end
      }
    end

    TIME_PARSER = /(\d+)(.*)/
    def self.parse_time(friendly)
      return Time.now unless match = TIME_PARSER.match(friendly)

      ::Chronic.parse("#{match[1]} #{match[2]} ago")
    end

    def self.to_epoch(date_str)
      DateTime.parse(date_str).strftime('%s').to_i
    end

    def self.config
      Kearny.configuration(name.split('::').last.downcase)
    end
  end
end
