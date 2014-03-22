#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# NSD->BIN コンバーター

$LOAD_PATH << 'nes_tools/lib'

require 'nes_tools'

if ARGV.size <= 0
  puts 'ruby sound_conv.rb file.mml [...]'
  exit
end

nsd = NesTools::Nsd.new
ARGV.each do |filename|
  nsd.convert filename
end
