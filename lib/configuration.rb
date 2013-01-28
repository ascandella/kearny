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

  private

    def load_config(piece)
      path = File.join(Kearny.settings.root, 'config', "#{piece}.yml")
      config = if File.exist?(path)
        YAML.load_file(path)
      end
      if config
        config.has_key?(Kearny.env.to_s) ? config[Kearny.env.to_s] : config
      end
    end
  end
end
