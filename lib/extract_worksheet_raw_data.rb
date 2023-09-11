require "google_drive"
require "json"
require "path"

id = ARGV[0]
name = ARGV[1]
session = GoogleDrive::Session.from_service_account_key("service-account-key.json")
spreadsheet = session.spreadsheet_by_key(id)
worksheets = spreadsheet.worksheets

def extract_worksheet_data(worksheet)
  raw_data = (1..worksheet.num_rows).map do |row_num|
    (1..worksheet.num_cols).map do |col_num|
      worksheet[row_num, col_num]
    end
  end
  split = worksheet.title.split(' ')
  {
    bl_num: split[0],
    bl_variant: split[1],
    bl_title: worksheet.title,
    bl_raw_data: raw_data,
  }
end

data = worksheets.map do |worksheet|
  extract_worksheet_data(worksheet)
end

(Path.backfind('.[Gemfile]')/'data'/'raw'/"#{name}.json").write(JSON.pretty_generate data)
