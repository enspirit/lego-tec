module LegoTec
  class WebApp
    class View < Mustache
      self.template_path = ROOT_FOLDER/'lib'

      def full_stops_rv
        @full_stops_rv ||= if options[:mode] == "poles"
          base.poles_data
        else
          base.full_stops_data
        end
      end

      def poles_rv
        base
          .poles_data
          .project([:bs_name])
          .extend(:is_focus => ->(t) { t[:bs_name] == options[:focus] })
      end

      def poles
        @poles ||= poles_rv
          .to_a
          .sort{|t1,t2| t1[:bs_name] <=> t2[:bs_name] }
      end

      def lines_rv
        full_stops_rv
          .project([:b_name])
      end

      def lines
        @lines ||= lines_rv
          .extend({
            is_line: ->(t){ options[:lines].include?(t[:b_name]) },
          })
          .to_a
          .sort{|t1,t2| t1[:b_name] <=> t2[:b_name] }
      end

      def line_types_rv
        full_stops_rv
          .project([:bl_type])
      end

      def line_types
        @line_types ||= line_types_rv
          .extend({
            is_line_type: ->(t){ options[:line_types].include?(t[:bl_type]) },
          })
          .to_a
          .sort{|t1,t2| t1[:bl_type] <=> t2[:bl_type] }
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

      def summarized_hops
        min_hour   = options[:min_hour]
        max_hour   = options[:max_hour]
        day        = options[:day]
        variant    = options[:variant]
        slot_size  = options[:slot_size]
        line_types = options[:line_types]
        lines      = options[:lines]

        base_stops_rv = full_stops_rv
          .restrict(->(t) {
            t[:bl_days][day-1...day] != '*' && t[:bl_days][day-1...day] != '0'
          })
          .restrict({
            :bl_variant => [variant, 'AUTRE'],
            :bl_type => line_types,
          })
          .restrict(lines.empty? ? Predicate.tautology : {
            :b_name => lines
          })
          .restrict(
            Predicate.gte(:bs_time, min_hour) & Predicate.lte(:bs_time, max_hour+2*slot_size)
          )
          .materialize

        base_stops_rv
          .join(
            base_stops_rv.rename({
              :bs_name => :cs_name,
              :bs_time => :cs_time
            }),
            [
              :b_name,
              :bl_system,
              :bl_type,
              :bl_title,
              :bl_variant,
              :bl_direction,
              :bl_num,
              :bl_days
            ]
          )
          .restrict(
            Predicate.lt(:bs_time, :cs_time)
          )
          .restrict(
            Predicate.gte(:bs_time, min_hour) & Predicate.lte(:bs_time, max_hour+slot_size)
          )
      end

      def hours
        (5..21).map{|h|
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

      def is_bus_lines_page
        false
      end

      def is_mobility_matrix_page
        false
      end

    protected

      def to_human_time(time)
        h = time/60
        m = time % 60
        m == 0 ? "#{h}h" : "#{h}h#{m.to_s.rjust(2, '0')}"
      end
    end
  end
end
