module LegoTec
  module Data
    class Base
      class FullData
        include Bmg::Relation

        DATA = Bmg::Relation.new(
          (GTFS_DATA_FOLDER/'system.json').each_line.map{|line|
            Bmg::TupleAlgebra.symbolize_keys(JSON.parse(line))
          }
        ).extend(
          :bl_variant => ->(t) {
            Datatypes::BlVariant.normalize(t[:bl_variant])
          },
          :bs_name => ->(t) {
            Datatypes::BsName.normalize(t[:bs_name])
          },
          :bl_type => ->(t) {
            Datatypes::BlType.infer(t)
          }
        ).materialize

        def type
          Bmg::Type::ANY.with_attrlist([
            :bl_system,
            :b_name,
            :bl_title,
            :bl_variant,
            :bl_num,
            :bl_direction,
            :bs_name,
            :bs_time,
            :bl_days,
            :bl_since,
            :bl_until,
            :bs_seqnum,
            :bs_latitude,
            :bs_longitude,
          ])
        end

        def each(&block)
          return to_enum unless block_given?

          DATA.each(&block)
        end
      end
    end
  end
end
