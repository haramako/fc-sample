#!/usr/bin/env ruby
require 'pp'

category = nil
sub_category = nil
segments = Hash.new
ARGF.each do |line|
  case line
  when /^(.+):$/
    sub_category = $1
  when /^-------------$/
    category = sub_category
    sub_category = nil
    puts category
  else
    case category
    when 'Segment list'
      data = line.split(/\s+/)
      next if data.size != 4 or data[0] == 'Name'
      segments[data[0]] = [data[1].to_i(16), data[2].to_i(16), data[3].to_i(16)]
    end
  end
end

PAGE = 1024
segments.each do |k,v|
  s = v[0]/PAGE
  e = v[1]/PAGE+1
  e = 64 if e >= 64
  str = ' '*s + '+'*(e-s) + ' '*(64-e)
  0.step(64,8) do |i|
    str[i] = '|' if str[i] == ' '
  end
  puts "%16s %64s| %8d (0x%04X-0x%04X)" % [k,str,v[2], v[0], v[1]]
end
