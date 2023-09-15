module LegoTec
  class WebApp
    class View < Mustache
      self.template_path = ROOT_FOLDER/'lib'

      def full_stops_rv
        @full_stops_rv ||= options[:mode] == "poles" ? base.poles_data : base.full_stops_data
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
        min_hour  = options[:min_hour]
        max_hour  = options[:max_hour]
        day       = options[:day]
        variant   = options[:variant]
        slot_size = options[:slot_size]

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
          })
          .restrict(
            Predicate.gte(:bs_time, min_hour) & Predicate.lte(:bs_time, max_hour+slot_size)
          )
          .restrict(
            Predicate.lt(:bs_time, :cs_time)
          )
          .restrict(->(t) {
            t[:bl_days][day-1...day] == day.to_s
          })
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
