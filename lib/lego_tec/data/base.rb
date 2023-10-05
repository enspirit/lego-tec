module LegoTec
  module Data
    class Base
      def full_stops_data
        @full_stops_data ||= FullData
          .new
          .materialize
      end

      def poles_data
        @poles_data ||= full_stops_data
          .extend({
            :bs_name => ->(t){
              t[:bs_name][/^([A-Z0-9a-z-]+)/, 1]
            }
          })
          .summarize([
            :b_name,
            :bl_type,
            :bl_variant,
            :bl_direction,
            :bl_title,
            :bl_system,
            :bl_num,
            :bl_days,
            :bs_name,
          ], {
            :bs_time => :min
          })
          .materialize
      end

      def days
        @days ||= Bmg::Relation.new([
          "Lundi",
          "Mardi",
          "Mercredi",
          "Jeudi",
          "Vendredi",
          "Samedi",
          "Dimanche"
        ].each_with_index.map do |day,i|
          {
            day_num: 1+i,
            day_name: day,
          }
        end)
      end
    end
  end
end
