require 'compass'
require 'sinatra/base'
require 'coffee-script'
require 'json'
require 'haml'
require 'sass'

module Kearny
  class WebUI < Sinatra::Base
    set :haml,  format: :html5
    set :root,  File.expand_path('.')
    set :views, File.join(root, 'app', 'views')

    set :demo, false
    # Make e.g. `environment` available elsewhere
    configure do
      Kearny.settings = settings
      Compass.add_project_configuration(File.join(root, 'config', 'compass.rb'))
    end

    configure :development, :production do
      enable :logging
    end

    helpers do
      def includes
        %w[
            d3 underscore backbone
            configuration models controls app_view views
            collections router application
          ]
      end

      def sheets
        %w[ layout icons theme-normal ].tap do |sheets|
          if File.exists?(File.join(Kearny.settings.views, 'style',
                                    'branding.sass'))
            sheets << 'branding'
          end
        end
      end

      def static_data
        @_static_data ||= {
          version: Kearny.version,
        }
      end
    end

    get '/configuration' do
      content_type :json
      Kearny.client_configuration.to_json
    end

    put '/configuration' do
      # Parse it to make sure it's valid JSON
      Kearny.save_client_configuration(JSON.parse(request.body.read))
      Kearny.client_configuration.to_json
    end

    post '/feed/me/data' do
      # Todo: store these widgets, or throw them away every time?
      content_type :json
      json_params = JSON.parse(request.body.read)

      cache(json_params) do
        if provider = Providers.fetch(json_params['type'])
          source = provider.new(json_params)
          if Kearny.settings.demo
            source.demo.to_json
          else
            source.get_data.to_json
          end
        else
          { error: true, message: 'No such provider' }.to_json
        end
      end
    end

    # TODO Make this a parameter
    CACHE_TIME = Kearny.configuration['cache']['expiry_seconds']
    def cache(params, &block)
      if cacheable? params
        @@_cache ||= {}
        if @@_cache.has_key?(params)
          time, data = @@_cache[params]
          if (Time.now.to_i - CACHE_TIME) < time
            return data
          end
        end
        @@_cache[params] = [Time.now.to_i, yield]
        @@_cache[params].last
      else
        yield
      end
    end

    # Past this many seconds ago, we cache responses. For fresh requests, e.g.
    # data that will change today, always fetch from the upstream provider.
    CUTOFF = Kearny.configuration['cache']['cutoff_seconds']
    def cacheable?(params)
      # TODO Move time parsing off Provider namespace
      if params['from'] && (from = Providers::Base.parse_time(params['from']))
        (from.to_i + CUTOFF) < Time.now.to_i
      end
    end

    get '/js/:script.js' do
      coffee "js/#{params[:script]}".to_sym
    end

    get '/style/:sheet.css' do
      sass "style/#{params[:sheet]}".to_sym, Compass.sass_engine_options
    end

    get '/version' do
      content_type :json
      { version: Kearny.version }.to_json
    end

    get '/' do
      haml :index
    end

    # Handled by backbone, so this is identical
    get '/dashboard/:name' do
      haml :index
    end
  end
end
