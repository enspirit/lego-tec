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
          full_stops_rv
            .project([:bs_name])
            .materialize
        end

        def stops
          @stops ||= stops_rv
            .to_a
            .sort{|t1,t2| t1[:bs_name] <=> t2[:bs_name] }
        end

        def values_rv
          summarized_hops
            .project([:bs_name, :cs_name, :bl_num, :bl_system])
            .group([:bl_system, :bl_num], :value)
            .extend({
              :value => ->(t) {
                h = t[:value]
                  .summarize([:bl_system], :bl_num => :count)
                  .y_by_x(:bl_num, :bl_system)
                value_h(h)
              }
            })
        end

        def rows_rv
          stops_rv
        end

        def rows
          rows_rv
            .join(rows_rv.rename(:bs_name => :cs_name), [])
            .left_join(values_rv, [:bs_name, :cs_name], { value: nil })
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

        def is_mobility_matrix_page
          true
        end

      protected

        def value_h(value)
          before = value["AVANT"]
          after  = value["APRES"]
          if before && after
            if before < after
              color = "good"
              label = "+#{after-before}"
            else
              color = "warning"
              label = "-#{before-after}"
            end
          elsif before
            color = "danger"
            label = "-#{before}"
          elsif after
            color = "good"
            label = "+#{after}"
          else
            color = "neutral"
            label = "/"
          end
          {
            color: color,
            label: "#{label}"
          }
        end
      end
    end
  end
end
