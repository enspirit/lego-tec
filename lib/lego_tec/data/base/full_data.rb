module LegoTec
  module Data
    class Base
      class FullData
        include Bmg::Relation

        def each(&block)
          return to_enum unless block_given?

          SEMINORMALIZED_DATA_FOLDER.glob('*.json') do |file|
            file.load.each do |tuple|
              yield Bmg::TupleAlgebra.symbolize_keys(tuple)
            end
          end
        end
      end
    end
  end
end
