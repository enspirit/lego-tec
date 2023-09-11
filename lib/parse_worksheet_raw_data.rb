require "json"
require "path"

def timeline_blocks(raw_data)
  blocks = []
  start = nil
  raw_data.each_with_index do |line, i|
    if line[0] =~ /Jour.s. de circulation/
      raise "State error: #{start.inspect} & #{i} : #{line.inspect}" unless start.nil?
      start = i
    elsif line[0] =~ /Numéro de voyage|Numéro de voyage/
      raise "State error" if start.nil?
      blocks << (start..i)
      start = nil
    end
  end
  blocks
end

def extract_timeline(bus_line)
  raw_data = bus_line.delete("bl_raw_data")
  blocks = timeline_blocks(raw_data)
  (1...raw_data.first.size).map{|col_index|
    blocks.map{|block|
      bl_days = raw_data[block.begin][col_index]
      bl_num = raw_data[block.end][col_index]
      bus_stops = raw_data[(block.begin+1)...block.end].map{|line|
        next if line[col_index].to_s.empty?
        bus_line.merge({
          bl_system: "BEFORE",
          bl_num: bl_num,
          bl_days: bl_days,
          bs_name: line[0].strip,
          bs_time: line[col_index].strip,
        })
      }.compact
    }.flatten
  }.flatten
end

root = Path.backfind('.[Gemfile]')
(root/'data'/'raw_data'/'old').glob("*.json") do |file|
  lines = file.load.map{|line|
    extract_timeline(line)
  }.flatten
  ((root/'data'/'seminormalized')/file.basename).write(JSON.pretty_generate(lines))
end
