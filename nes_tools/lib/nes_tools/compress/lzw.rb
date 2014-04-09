module NesTools
  module Compress
    module Lzw
      module_function

      def compress(data)
        w = BitWriter.new
        w.write_vln16 data.size
        idx = 0
        while idx < data.size
          match = find_match(data,idx)
          if match
            w.write 0, 1
            w.write_vln idx-match[0]
            w.write_vln match[1]
            idx += match[1]
          else
            w.write 1, 1
            w.write data[idx], 8
            idx += 1
          end
        end
        w.buf
      end

      def decompress(data)
        r = []
        b = BitReader.new(data)
        len = b.read_vln16
        while r.size < len
          if b.read(1) == 0
            idx = b.read_vln
            l = b.read_vln
            l.times do |i|
              r << r[-idx]
            end
          else
            r << b.read(8)
          end
        end
        r
      end
      
      def find_match(data,idx)
        max_idx = nil
        max_len = 0
        idx.times do |start|
          len = 0
          len += 1 while idx+len < data.size and data[start+len] == data[idx+len]
          if len > 1 and len < 256 and (idx-start) < 256 and len > max_len
            max_idx = start
            max_len = len
          end
        end
        if max_idx
          [max_idx, max_len]
        else
          nil
        end
      end

    end
  end
end
