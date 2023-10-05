module LegoTec
  class WebApp
    module Views
      class MobilityMatrix < View
        def initialize(base, options)
          @base = base
          @options = options
        end
        attr_reader :base, :options

        def stops_rv
          if options[:focus] && !options[:focus].empty?
            @stops_rv ||= values_rv
              .restrict(Predicate.eq(:bs_name, options[:focus]) | Predicate.eq(:cs_name, options[:focus]))
              .project([:cs_name])
              .rename(:cs_name => :bs_name)
          else
            @stops_rv ||= values_rv
              .project([:bs_name])
              .materialize
          end
        end

        def stops
          @stops ||= stops_rv
            .to_a
            .sort{|t1,t2| t1[:bs_name] <=> t2[:bs_name] }
        end

        def values_rv
          @values_rv ||= summarized_hops
            .summarize(
              [
                :bs_name,
                :cs_name,
                :bl_num,
                :bl_system
              ],
              {
                :bs_time => :min,
                :cs_time => :min,
              }
            )
            .project([
              :bs_name,
              :cs_name,
              :bs_time,
              :cs_time,
              :bl_num,
              :bl_system
            ])
            .group([
              :bl_system,
              :bl_num,
              :bs_time,
              :cs_time
            ], :value)
            .extend({
              :value => ->(t) {
                h = t[:value]
                  .extend({
                    speed: ->(t){ t[:cs_time] - t[:bs_time] }
                  })
                  .summarize([:bl_system], :bl_num => :count, :speed => :avg)
                  .y_by_x(y_attr_for_mode, :bl_system)
                value_h(t, h)
              }
            })
            .materialize
        end

        def rows_rv
          stops_rv
        end

        def rows
          rows_rv
            .join(rows_rv.rename(:bs_name => :cs_name), [])
            .left_join(values_rv, [:bs_name, :cs_name], { :value => nil })
            .group([:cs_name, :value], :columns)
            .extend({
              :columns => ->(t) {
                t[:columns]
                  .to_a
                  .sort{|t1,t2| t1[:cs_name] <=> t2[:cs_name] }
              }
            })
            .to_a
            .sort{|t1,t2| t1[:bs_name] <=> t2[:bs_name] }
        end

        def empty
          false
        end

        def is_count_matrix_mode
          options[:matrix_mode] == 'count'
        end

        def is_count_delta_matrix_mode
          options[:matrix_mode] == 'count-delta'
        end

        def is_speed_matrix_mode
          options[:matrix_mode] == 'speed'
        end

        def is_speed_delta_matrix_mode
          options[:matrix_mode] == 'speed-delta'
        end

        def is_mobility_matrix_page
          true
        end

      protected

        def y_attr_for_mode
          if is_count_matrix_mode
            :bl_num
          elsif is_count_delta_matrix_mode
            :bl_num
          else
            :speed
          end
        end

        def value_h(t, value)
          before = value["AVANT"]&.to_i
          after  = value["APRES"]&.to_i
          if is_count_delta_matrix_mode
            if before && after
              if before < after
                # more busses
                color = "good"
                label = "+#{after-before}"
              elsif before > after
                # less busses
                color = "warning"
                label = "-#{before-after}"
              else
                # same busses
                color = "neutral"
                label = "/"
              end
            elsif before
              # no more bus
              color = "danger"
              label = "-#{before}"
            elsif after
              # new busses only
              color = "good"
              label = "+#{after}"
            else
              # still no bus...
              color = "neutral"
              label = "/"
            end
          elsif is_count_matrix_mode
            label = "#{before} / #{after}"
            if before && after
              delta = after - before
              color = if delta > 0
                "good"
              elsif delta == 0
                "neutral"
              else
                "warning"
              end
            elsif before
              color = "warning"
            elsif after
              color = "good"
            end
          elsif is_speed_matrix_mode
            label = "#{before} / #{after}"
            if before && after
              delta = after - before
              color = if delta > 0
                "warning"
              elsif delta == 0
                "neutral"
              else
                "good"
              end
            elsif before
              color = "warning"
            elsif after
              color = "good"
            end
          elsif is_speed_delta_matrix_mode
            if before && after
              if before < after
                # longer than before
                color = "warning"
                label = "+#{after-before}"
              elsif before > after
                # faster than before
                color = "good"
                label = "-#{before-after}"
              else
                # same speed
                color = "neutral"
                label = "="
              end
            elsif before
              # no more bus
              color = "neutral"
              label = ""
            elsif after
              # new buses only
              color = "neutral"
              label = ""
            else
              # still no bus...
              color = "neutral"
              label = ""
            end
          end
          focus = options[:focus]
          focus_class = (focus && (t[:bs_name] == focus || t[:cs_name] == focus)) ? "focus" : "no-focus"
          {
            color: color,
            focus: focus_class,
            label: "#{label}"
          }
        end
      end
    end
  end
end
