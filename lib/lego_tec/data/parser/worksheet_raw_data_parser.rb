module LegoTec
  module Data
    module Parser
      class WorksheetRawDataParser
        def run
          (RAW_DATA_FOLDER/'old').glob("*.json") do |file|
            lines = file.load.map{|line|
              extract_timeline(line)
            }.flatten.uniq
            (SEMINORMALIZED_DATA_FOLDER/file.basename).write(JSON.pretty_generate(lines))
          end
        end

      private

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
                next unless line[col_index].to_s =~ Datatypes::BlTime::RX
                bus_line.merge({
                  "bl_system" => "AVANT",
                  "bl_variant" => Datatypes::BlVariant.normalize(bus_line["bl_variant"]),
                  "bl_num" => bl_num,
                  "bl_days" => Datatypes::BlDays.normalize(bl_days),
                  "bs_name" => Datatypes::BsName.normalize(line[0].strip),
                  "bs_time" => Datatypes::BlTime.normalize(line[col_index].strip),
                })
              }.compact
            }.flatten
          }.flatten
        end
      end
    end
  end
end
