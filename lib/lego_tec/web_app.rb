require 'sinatra'

module LegoTec
  class WebApp < Sinatra::Base
    if settings.development?
      require 'sinatra/reloader'
      register Sinatra::Reloader
      also_reload ROOT_FOLDER/'lib/lego_tec/data/**/*.rb'
      also_reload ROOT_FOLDER/'lib/lego_tec/datatypes/**/*.rb'
      also_reload ROOT_FOLDER/'lib/lego_tec/web_app/**/*.rb'
      enable :reloader
    end

    set :raise_errors, true
    set :show_exceptions, false
    set :dump_errors, false
    set :root, Path.dir/'web_app'
    set :views, Path.dir/'web_app'/'views'
    set :db, Data::Base.new

    get '/' do
      min_hour = (params['min-hour'] || 5).to_i
      max_hour = (params['max-hour'] || 9).to_i
      options = {
        mode: params["mode"] || "poles",
        from: params["from"],
        to: params["to"],
        day: (params["day"] || "1").to_i,
        variant: params["variant"] || "SCOLAIRE",
        min_hour: min_hour*60,
        max_hour: max_hour*60,
        slot_size: 60,
      }
      Views::Layout.new(Views::Home.new(settings.db, options)).render
    end

    get '/matrices-de-mobilite' do
      min_hour = (params['min-hour'] || 5).to_i
      max_hour = (params['max-hour'] || 9).to_i
      options = {
        mode: params["mode"] || "poles",
        matrix_mode: params["matrix-mode"] || "count",
        from: params["from"],
        to: params["to"],
        day: (params["day"] || "1").to_i,
        variant: params["variant"] || "SCOLAIRE",
        min_hour: min_hour*60,
        max_hour: max_hour*60,
        slot_size: 60,
      }
      Views::Layout.new(Views::MobilityMatrix.new(settings.db, options)).render
    end
  end
end
