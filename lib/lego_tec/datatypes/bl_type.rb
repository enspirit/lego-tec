module LegoTec
  module Datatypes
    class BlType
      def self.infer(x)
        case x[:b_name]
        when /^E/ then "Express"
        else "Classique"
        end
      end
    end
  end
end
