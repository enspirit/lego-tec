module LegoTec
  module Data
    class Base
      def full_data
        FullData.new.materialize
      end

      def stops
        full_data.project([:bs_name]).materialize
      end

      def days
        full_data.project([:bl_days]).materialize
      end

      def variants
        full_data.project([:bl_variant]).materialize
      end
      
      def slots_for(options = {})
        min_hour  = options[:min_hour]
        max_hour  = options[:max_hour]
        slot_size = options[:slot_size] 

        Bmg::Relation.new(((min_hour/slot_size)..(max_hour/slot_size))
          .map{|h| h*slot_size }
          .flatten
          .map{|time|
            {
              :bs_slot => time,
              :bs_slot_human => to_human_time(time),
            }
          })
      end

      def comparison_table_for(options = {}, slots = slots_for(options))
        min_hour  = options[:min_hour]
        max_hour  = options[:max_hour]
        slot_size = options[:slot_size]
        days      = options[:days]
        variant   = options[:variant]
        from      = options[:from]
        to        = options[:to]

        full_data
          .join(
            full_data.rename({
              :bs_name => :cs_name,
              :bs_time => :cs_time
            }), 
            [:b_name, :bl_system, :bl_title, :bl_variant, :bl_direction, :bl_num, :bl_days]
          )
          .restrict({
            :bl_days => days,
            :bl_variant => [variant, "TOUT"],
            :bs_name => from,
            :cs_name => to,
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
        end
  
    private

      def to_human_time(time)
        h = time/60
        m = time % 60
        m == 0 ? "#{h}h" : "#{h}h#{m.to_s.rjust(2, '0')}"
      end
    end
  end
end
