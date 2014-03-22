# -*- coding: utf-8 -*-
module NesTools
  module Compress

    module Rle
      module_function
      def compress( data )
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

      def decompress( data )
        out = []
        i = 0
        while i<data.size
          if i>0 and data[i] == out[-1]
            break if data[i+1] == 0
            data[i+1].times { out << data[i] }
            i += 2
          else
            out << data[i]
            i += 1
          end
        end
        out
      end
    end
    
  end
end
