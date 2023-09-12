class BlDays
  VARIANTS = {
    "**Me**" => "**3****",
    "LM*JV"  => "12*45**",
    "LMMeJV" => "12345**",
    "S"      => "*****6*",
    "12345"  => "12345**",
    "****5"  => "****5**",
    "**3**"  => "**3****",
    "12*45"  => "12*45**",
    "12*4*"  => "12*4***",
    "12*4"   => "12*4***",
    "6"      => "*****6*",
  }

  def self.normalize(x)
    VARIANTS[x.strip] || raise("Unknown bl_days `#{x.strip}`")
  end
end
