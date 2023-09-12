module LegoTec
  module Datatypes
    class BsName
      def self.normalize(x)
        x.gsub(/\(Gare Quai[^\)]+\)/, "(Gare)")
      end
    end
  end
end
