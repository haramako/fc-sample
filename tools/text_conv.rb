#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$LOAD_PATH << 'nes_tools/lib'
require 'nes_tools'

if ARGV.empty?
  puts 'Text Converter'
  puts 'Usage: ruby text-conv.rb infile.txt'
  exit
end

txt = IO.read(ARGV[0]).force_encoding('UTF-8')
conv = NesTools::TextConverter.new
conv.conv( txt )
conv.make_image( 'text.png' )
IO.write('text.txt', conv.using.join)
