require 'path'
require 'json'
require_relative './datatypes'

def flatten_bus_lines(data)
  size = data[:bl_nums].size
  slices = data[:bl_raw_timeline].each_slice(1+size).to_a
  data[:bl_nums].each_with_index.map{|bl_num, i|
    slices.map{|slice|
      next if slice[i+1].nil? || slice[i+1].empty?
      {
        b_name: data[:b_name],
        bl_system: "AFTER",
        bl_title: data[:bl_title],
        bl_variant: BlVariant.normalize(data[:bl_variant]),
        bl_direction: data[:bl_direction],
        bl_num: bl_num,
        bl_days: BlDays.normalize(data[:bl_days][i]),
        bs_name: slice[0],
        bs_time: BlTime.normalize(slice[i+1])
      }
    }.compact
  }
end

def parse_bus_line(busnum, source)
  source.scan(%r{
    ^
    \s*(#{busnum})                           # 0: b_name
    \n\s*(.+?)                               # 1: bl_title
    \n\s*(.+?)                               # 2: bl_variant
    \n\s*(.+?)                               # 3: bl_variant
    \n\s*(.+?)                               # 4: bl_days or bl_direction
    \n\s*(.+?)                               # 5: bl_direction or bl_days
    \n\s*(.+?)                               # 6: bl_raw_timeline
    Numéro\s?de\s?voyage\s+?                 # 7: bl_nums
    ([^\$]+?$)
  }mx).map{|match|
    if match[4] =~ /Jour\(s\)\s?de\s?circulation\s(.*?)$/
      match[4] = $1
    elsif match[5] =~ /Jour\(s\)\s?de\s?circulation\s(.*?)$/
      match[4], match[5] = $1, match[4]
    else
      raise "Illegal state error"
    end
    flatten_bus_lines({
      b_name: match[0],
      bl_title: match[1],
      bl_variant: match[2],
      bl_direction: match[5],
      bl_days: match[4].split("\s"),
      bl_raw_timeline: match[6].split("\n").map(&:strip),
      bl_nums: match[7].split("\s"),
    })
  }.flatten.uniq
end

root = Path.backfind('.[Gemfile]')
(root/'data'/'raw_data'/'new').glob("*.txt") do |file|
  source = file.read
  busnum = file.basename.to_s[/^([^\.]+)/, 0]
  lines = parse_bus_line(busnum, source)
  (root/'data'/'seminormalized'/"#{busnum}.json").write(JSON.pretty_generate(lines))
end
