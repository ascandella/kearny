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
        %w[ d3 underscore backbone models views collections application ]
      end

      def static_data
        {
          version: Kearny.version,
        }
      end
    end

    get '/' do
      haml :index
    end

    get '/dashboard/:name' do
      content_type :json
      Kearny.dashboard(params[:name]).to_json
    end

    post '/data/for/:provider' do
      # Todo: store these widgets, or throw them away every time?
      content_type :json

      if provider = Providers.fetch(params[:provider])
        # Todo: read date parameters from somewhere. Defaults-per-dashboard plus
        # per-item override?
        source = provider.new(params[:configuration])
        if Kearny.settings.demo
          source.demo.to_json
        else
          source.get_data('-2d', 'now').to_json
        end
      else
        { error: true, message: 'No such provider' }.to_json
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
  end
end
