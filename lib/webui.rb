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

    get '/' do
      haml :index
    end

    get '/dynamic/:data' do
      content_type :json
      Dynamic.send(params[:data]).to_json
    end

    get '/js/:script.js' do
      coffee "js/#{params[:script]}".to_sym
    end

    get '/style/:sheet.css' do
      sass "style/#{params[:sheet]}".to_sym, Compass.sass_engine_options
    end
  end
end
