#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'bundler/setup'
require 'lego_tec'

run LegoTec::WebApp
