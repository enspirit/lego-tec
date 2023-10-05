module LegoTec
  class WebApp
    module Views
      class Home < View
        def initialize(base, options)
          @base = base
          @options = options
        end
        attr_reader :base, :options

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
          slot_size = options[:slot_size]
          from      = options[:from]
          to        = options[:to]

          summarized_hops
            .restrict({
              :bs_name => from,
              :cs_name => to,
            })
            .summarize(
              [
                :b_name,
                :bl_system,
                :bl_type,
                :bl_title,
                :bl_variant,
                :bl_direction,
                :bl_num,
                :bl_days
              ],
              {
                :bs_time => :min,
                :cs_time => :min,
              }
            )
            .extend({
              :bs_slot => ->(t){ (t[:bs_time]/slot_size)*slot_size },
              :bs_time_human => ->(t){ to_human_time(t[:bs_time]) },
              :cs_time_human => ->(t){ to_human_time(t[:cs_time]) },
            })
            .group(
              [
                :bl_title,
                :bl_type,
                :bl_variant,
                :bl_direction,
                :bl_num,
                :bl_days,
                :bs_slot,
                :bs_time,
                :cs_time,
                :bs_time_human,
                :cs_time_human
              ],
              :slots
            )
            .extend({
              :slots => ->(t) {
                slots_rv.left_join(
                  t[:slots]
                    .group([
                      :bl_title,
                      :bl_type,
                      :bl_variant,
                      :bl_direction,
                      :bl_num,
                      :bl_days,
                      :bs_time,
                      :cs_time,
                      :bs_time_human,
                      :cs_time_human
                    ], :buses),
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

        def is_bus_lines_page
          true
        end
      end
    end
  end
end
