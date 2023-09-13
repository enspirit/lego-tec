module LegoTec
  class WebApp
    module Views
      class Home
        def initialize(base, options)
          @base = base
          @options = options
        end
        attr_reader :base, :options

        def full_stops_rv
          @full_stops_rv ||= options[:mode] == "poles" ? base.poles_data : base.full_stops_data
        end

        def days
          @days ||= base
            .days
            .extend({
              is_day: ->(t){ t[:day_num] == options[:day] },
            })
            .to_a
            .sort{|t1,t2| t1[:day_num] <=> t2[:day_num] }
        end

        def variants_rv
          @variants_rv ||= full_stops_rv
            .project([:bl_variant])
        end

        def variants
          @variants ||= variants_rv
            .extend({
              is_variant: ->(t){ t[:bl_variant] == options[:variant] },
            })
            .to_a
        end

        def stops_rv
          @stops_rv ||= full_stops_rv
            .project([:bs_name])
        end

        def stops
          @stops ||= stops_rv
            .extend({
              is_from: ->(t){ t[:bs_name] == options[:from] },
              is_to: ->(t){ t[:bs_name] == options[:to] },
            })
            .to_a
            .sort{|s1,s2|
              s1[:bs_name].downcase <=> s2[:bs_name].downcase
            }
        end

        def slots_rv
          @slots_rv ||= begin
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
        end

        def slots
          @slots ||= slots_rv.to_a
        end

        def systems_rv
          min_hour  = options[:min_hour]
          max_hour  = options[:max_hour]
          slot_size = options[:slot_size]
          day       = options[:day]
          variant   = options[:variant]
          from      = options[:from]
          to        = options[:to]

          full_stops_rv
            .join(
              full_stops_rv.rename({
                :bs_name => :cs_name,
                :bs_time => :cs_time
              }),
              [:b_name, :bl_system, :bl_title, :bl_variant, :bl_direction, :bl_num, :bl_days]
            )
            .restrict({
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
            .restrict(->(t) {
              t[:bl_days][day-1...day] == day.to_s
            })
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
                slots_rv.left_join(
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

        def systems
          @systems ||= systems_rv
            .to_a
        end

        def empty
          systems.empty?
        end

        def full_colspan
          1+slots.size
        end

        def hours
          (5..20).map{|h|
            {
              :hour => h,
              :is_min_hour => h == min_hour,
              :is_max_hour => h == max_hour,
            }
          }
        end

        def min_hour
          options[:min_hour]/60
        end

        def max_hour
          options[:max_hour]/60
        end

        def is_stops_mode
          options[:mode] == "stops"
        end

        def is_poles_mode
          options[:mode] == "poles"
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
end
