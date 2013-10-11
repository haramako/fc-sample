#!/usr/bin/env ruby

def rle_compress( data )
  out = []
  i = 0
  while i<data.size
    if i>0 and data[i] == data[i-1]
      out << data[i]
      n = 0
      while i<data.size and n < 256 and data[i] == data[i-1]
        n += 1
        i += 1
      end
      out << n
    else
      out << data[i]
      i += 1
    end
  end
  out << data[-1] << 0
  out
end

if __FILE__ == $0

  if ARGV[0] == '-h'
    puts "run-length compress"
    puts "usage: ./rle <file>"
    exit
  end

  ARGF.set_encoding 'ASCII-8BIT'
  p rle_compress( ARGF.read.unpack('c*') )
end

