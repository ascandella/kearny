module Kearny
  class << self
    attr_accessor :settings

    def env
      settings.environment
    end

    def configuration(piece = 'kearny')
      @@config_store ||= {}
      @@config_store[piece] ||= load_config(piece)
    end

    # User-configurable dashboards, stored in JSON
    def dashboard(name = 'default')
      with_dashboard(name) { |json| JSON.parse(json.read) }
    end

    def save_dashboard(name, content)
      with_dashboard(name, 'w') do |file|
        file.write(JSON.pretty_generate(content))
      end
    end

  private

    def with_dashboard(name, mode = 'r')
      File.open(File.join(settings.root,'config', 'dashboards',
                          "#{name}.json")) do |file|
        yield file if block_given?
      end
    end

    # Application-level configuration, such as API keys
    def load_config(piece)
      path = File.join(settings.root, 'config', "#{piece}.yml")
      config = if File.exist?(path)
        YAML.load_file(path)
      end
      if config
        config.has_key?(env.to_s) ? config[env.to_s] : config
      end
    end
  end
end
