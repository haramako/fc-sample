#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# NSD->BIN コンバーター

require 'pp'
require 'fc/compat'
require 'pathname'
require_relative 'nes_tool'

if ARGV.size <= 0
  puts 'ruby sound_conv.rb file.mml [...]'
  exit
end

nsd = NesTool::Nsd.new
ARGV.each do |filename|
  nsd.convert filename
end
