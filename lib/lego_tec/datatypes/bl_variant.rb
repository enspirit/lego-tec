module LegoTec
  module Datatypes
    class BlVariant
      VARIANTS = {
        "Période scolaire" => "SCOLAIRE",
        "Vacances scolaires" => "VACANCES",
        "Toutes périodes" => "TOUT",
        "SCOLAIRE" => "SCOLAIRE",
        "VACANCES" => "VACANCES",
        "SAMEDI" => "TOUT",
      }

      def self.normalize(x)
        VARIANTS[x] || raise("Unknown bl_variant `#{x}`")
      end
    end
  end
end
