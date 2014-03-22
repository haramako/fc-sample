module NesTools
  
  class BitWriter
    attr_reader :buf
    alias :to_a :buf
    
    def initialize(buf = [])
      @buf = buf
      @rest = 0
    end
    
    def write(n, bits)
      # pp [n,bits,@buf.size]
      while bits > 0
        if @rest == 0
          @buf << 0
          @rest = 8
        end
        if @rest >= bits
          @buf[-1] = @buf[-1] | ((n << (@rest-bits)) & 0xff)
          @rest -= bits
          bits = 0
        else
          @buf[-1] = @buf[-1] | ((n >> (bits-@rest)) & 0xff)
          bits -= @rest
          @rest = 0
        end
      end
    end

    def write_vln(n)
      if n < 16
        write 0,1
        write n,4
      else
        write 1,1
        write n,8
      end
    end

    def write_vln16(n)
      if n < 256
        write 0,1
        write n,8
      else
        write 1,1
        write n,16
      end
    end
    
  end

  class BitReader
    def initialize(buf)
      @buf = buf
      @pos = 0
      @bit_pos = 0
    end
    
    def read(bits)
      r = 0
      while bits > 0
        if 8-@bit_pos >= bits
          r = (r << bits) | ((@buf[@pos] >> (8-@bit_pos-bits)) & ((1 << bits) - 1))
          @bit_pos += bits
          bits = 0
        else
          read_bits = 8-@bit_pos
          r = (r << read_bits) | ((@buf[@pos] >> (8-@bit_pos-read_bits)) & ((1 << read_bits) - 1))
          bits -= read_bits
          @bit_pos = 0
          @pos += 1
        end
      end
      r
    end

    def read_vln
      if read(1) == 0
        read(4)
      else
        read(8)
      end
    end
    
    def read_vln16
      if read(1) == 0
        read(8)
      else
        read(16)
      end
    end
  end

end
