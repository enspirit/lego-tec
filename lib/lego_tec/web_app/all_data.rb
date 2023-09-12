module LegoTec
  module WebApp
    class AllData
      include Bmg::Relation

      def each(&block)
        return to_enum unless block_given?

        (Path.backfind('.[Gemfile]')/'data'/'seminormalized').glob('*.json') do |file|
          file.load.each do |tuple|
            yield Bmg::TupleAlgebra.symbolize_keys(tuple)
          end
        end
      end
    end

    def to_human_time(time)
      h = time/60
      m = time % 60
      m == 0 ? "#{h}h" : "#{h}h#{m.to_s.rjust(2, '0')}"
    end
    
    def run
      min_hour = 5*60
      max_hour = 20*60
      slot_size = 60

      slots = Bmg::Relation.new(((min_hour/slot_size)..(max_hour/slot_size))
        .map{|h| h*slot_size }
        .flatten
        .map{|time|
          {
            :bs_slot => time,
            :bs_slot_human => to_human_time(time),
          }
        })

      systems = AllData.new.join(
          AllData.new.rename({
            :bs_name => :cs_name,
            :bs_time => :cs_time
          }), 
          [:b_name, :bl_system, :bl_title, :bl_variant, :bl_direction, :bl_num, :bl_days]
        )
        .restrict({
          :bl_days => "12345**",
          :bl_variant => ["SCOLAIRE", "TOUT"],
          :bs_name => "Sombreffe (Place du Stain)",
          :cs_name => ["Gembloux (Gare)", "Gembloux (Gare Quai 5)", "Gembloux (Gare Quai 4)"]
        })
        .restrict(
          Predicate.gte(:bs_time, min_hour) & Predicate.lt(:bs_time, max_hour)
        )
        .restrict(
          Predicate.lt(:bs_time, :cs_time)
        )
        .summarize(
          [:b_name, :bl_system, :bl_title, :bl_variant, :bl_direction, :bl_num, :bl_days],
          {
            :bs_time => :min,
            :cs_time => :max        
          }
        )
        .extend({
          :bs_slot => ->(t){ (t[:bs_time]/slot_size)*slot_size },
          :bs_time_human => ->(t){ to_human_time(t[:bs_time]) },
          :cs_time_human => ->(t){ to_human_time(t[:cs_time]) },
        })
        .group(
          [:bl_title, :bl_variant, :bl_direction, :bl_num, :bl_days, :bs_slot, :bs_time, :cs_time, :bs_time_human, :cs_time_human],
          :slots
        )
        .extend({
          :slots => ->(t) {
            slots.left_join(
              t[:slots]
                .group(
                  [:bl_title, :bl_variant, :bl_direction, :bl_num, :bl_days, :bs_time, :cs_time, :bs_time_human, :cs_time_human],
                  :buses
                ),
              [:bs_slot],
              :buses => []
            )
            .extend({
              :buses => ->(t) {
                t[:buses]
                  .to_a
                  .sort{|t1,t2| t1[:bs_time] <=> t2[:bs_time] }  
              }
            })
            .to_a
            .sort{|t1,t2| t1[:bs_slot] <=> t2[:bs_slot] }
          }
        })
        .group(
          [:b_name, :slots],
          :lines
        )
        .extend({
          :lines => ->(t) {
            t[:lines]
              .to_a
              .sort{|t1,t2| t1[:b_name] <=> t2[:b_name] }
          }
        })
        .to_a
        .sort{|t1,t2| t2[:bl_system] <=> t1[:bl_system] }

      data = {
        :systems => systems,
        :slots => slots.to_a,
        :full_colspan => 1+slots.to_a.size
      }
      #puts JSON.pretty_generate(data)
      rendered = Mustache.render((Path.dir/'templates'/'table.mustache').read, data)
      puts rendered
    end
  end
end
