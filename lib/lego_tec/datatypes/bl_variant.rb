module LegoTec
  module Datatypes
    class BlVariant
      VARIANTS = {
        "SC" => "SCOLAIRE",
        "VA" => "VACANCES",
        "DI" => "AUTRE",
        "BW" => "AUTRE",
        "SA" => "AUTRE",
        "Période scolaire" => "SCOLAIRE",
        "Vacances scolaires" => "VACANCES",
        "Toutes périodes" => "AUTRE",
        "SCOLAIRE" => "SCOLAIRE",
        "VACANCES" => "VACANCES",
        "SAMEDI" => "AUTRE",
      }

      def self.normalize(x)
        VARIANTS[x] || raise("Unknown bl_variant `#{x}`")
      end
    end
  end
end
