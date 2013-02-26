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

    def client_configuration
      with_json_file('client') do |file|
        JSON.parse(file.read)
      end
    end

    def save_client_configuration(content)
      with_json_file('client', 'w') do |file|
        file.write(JSON.pretty_generate(content))
      end
    end

    def save_dashboard(name, content)
      with_dashboard(name, 'w') do |file|
        file.write(JSON.pretty_generate(content))
      end
    end

  private

    def with_json_file(name, mode = 'r')
      File.open(File.join(settings.root, 'public', "#{name}.json"), mode) do |file|
        yield file if block_given?
      end
    end

    def with_dashboard(name, mode = 'r', &block)
      with_json_file(File.join('dashboards', name), mode, &block)
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
