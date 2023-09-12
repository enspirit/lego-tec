require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

require 'json'
require 'path'
require 'bmg'
require 'json'
require 'mustache'

module LegoTec
  ROOT_FOLDER = Path.backfind('.[Gemfile]')
  DATA_FOLDER = ROOT_FOLDER/'data'
  RAW_DATA_FOLDER = DATA_FOLDER/'raw_data'
  SEMINORMALIZED_DATA_FOLDER = DATA_FOLDER/'seminormalized'
end

loader.eager_load