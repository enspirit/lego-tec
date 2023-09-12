module LegoTec
  module Datatypes
    class BlTime
      RX = /^(\d{1,2}):(\d{2})$/

      def self.normalize(x)
        raise "Unknown time `#{x}`" unless x.strip =~ RX
        $1.to_i * 60 + $2.to_i
      end
    end
  end
end
