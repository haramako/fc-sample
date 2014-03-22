module NesTools
  module Compress
    
    module Nbit
      module_function
      def compress(data, bits)
        w = BitWriter.new
        data.each.with_index do |c,i|
          w.write c, bits
        end
        w.buf
      end

      def decompress(data, bits, len)
        r = BitReader.new(data)
        (0...len).map do
          r.read(bits)
        end
      end
    end
    
  end
end
