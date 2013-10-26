# -*- coding: utf-8 -*-

require 'pp'
require 'json'

# map.json のタイル番号ARGV[0]の部分をARGV[1]に設定する

if ARGV.size < 3
  puts "usage: ruby clearmap.rb <map.json> <from> <to>"
  exit
end

data = JSON.parse( IO.read(ARGV[0]) )

from = ARGV[1].to_i+1
to = ARGV[2].to_i+1
m = data['layers'][0]['data']
num = 0
m.map!{|x| if x == from then num+=1; to else x end }

IO.write ARGV[0], JSON.dump( data )
puts "num = #{num}"
