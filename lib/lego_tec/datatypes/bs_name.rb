module LegoTec
  module Datatypes
    class BsName
      def self.normalize(x)
        x
          .gsub(/\(Gare Quai[^\)]+\)/i, "(Gare)")
          .gsub(/Gare - Quai \d+\s*$/i, "(Gare)")
          .gsub(/Corroy-le-([^\s]+)/i, 'Corroy-le-Chateau')
          .gsub(/Quatre Bras/i, '(Quatre Bras)')
          .gsub(/Gare Centrale Quai B06/i, '(Gare Centrale)')
          .capitalize
      end
    end
  end
end
