module LegoTec
  module Data
    module Collector
      class WorksheetRawDataCollector
        def run(id, name)
          # we keep this one here because it's hard to get it installed
          # on macosx
          require "google_drive"
          session = GoogleDrive::Session.from_service_account_key("service-account-key.json")
          spreadsheet = session.spreadsheet_by_key(id)
          worksheets = spreadsheet.worksheets
          data = worksheets.map do |worksheet|
            extract_worksheet_data(worksheet)
          end
          (RAW_DATA_FOLDER/'old'/"#{name}.json").write(JSON.pretty_generate data)
        end

      private

        def extract_worksheet_data(worksheet)
          raw_data = (1..worksheet.num_rows).map do |row_num|
            (1..worksheet.num_cols).map do |col_num|
              worksheet[row_num, col_num]
            end
          end
          split = worksheet.title.split(' - ')
          {
            b_name: split[0].strip,
            bl_variant: split[1].strip,
            bl_direction: split[2].strip,
            bl_title: worksheet.title.strip,
            bl_raw_data: raw_data,
          }
        end
      end
    end
  end
end