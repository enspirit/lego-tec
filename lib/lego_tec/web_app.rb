require 'sinatra'

module LegoTec
  class WebApp < Sinatra::Base
    if settings.development?
      require 'sinatra/reloader'
      register Sinatra::Reloader
      also_reload 'lib/lego_tec/data/**/*.rb'
      enable :reloader
    end

    set :raise_errors, true
    set :show_exceptions, false
    set :dump_errors, false
    set :root, Path.dir/'web_app'
    set :views, Path.dir/'web_app'/'views'
    set :db, Data::Base.new

    get '/' do
      tpl = settings.views/'home.mustache'
      min_hour = (params['min-hour'] || 5).to_i
      max_hour = (params['max-hour'] || 20).to_i
      options = {
        from: params["from"],
        to: params["to"],
        days: params["days"] || "12345**",
        variant: params["variant"] || "SCOLAIRE",
        min_hour: min_hour*60,
        max_hour: max_hour*60,
        slot_size: 60,
      }
      slots = settings.db.slots_for(options)
      data = {
        :days => settings.db
          .days
          .extend({
            is_days: ->(t){ t[:bl_days] == options[:days] },
          })
          .to_a
          .sort{|t1,t2| t1[:bl_days] <=> t2[:bl_days] },
        :variants => settings.db
          .variants
          .extend({
            is_variant: ->(t){ t[:bl_variant] == options[:variant] },
          })
          .to_a,
        :stops => settings.db
          .stops
          .extend({
            is_from: ->(t){ t[:bs_name] == options[:from] },
            is_to: ->(t){ t[:bs_name] == options[:to] },
          })
          .to_a
          .sort{|s1,s2| s1[:bs_name] <=> s2[:bs_name] },
        :slots => slots
          .to_a,
        :systems => settings.db
          .comparison_table_for(options, slots),
        :full_colspan => 1+slots.count,
        :min_hour => options[:min_hour]/60,
        :max_hour => options[:max_hour]/60,
      }
      Mustache.render(tpl.read, data)
    end
  end
end
