require 'nes_tools'

module NesTools
  # file system for fs.fc
  class Fs
    BANK_SIZE = 0x2000

    attr_reader :buf, :sizes, :addrs, :datas, :tag_addr, :file_count

    def initialize(_files = [])
      @files = _files
      @buf = nil
      @sizes = nil
      @addrs = nil
      @tag_addr = Hash.new
      @file_count = 0
    end

    def bin
      @buf = []
      @sizes = []
      @addrs = []

      @files.each do |f|
        name, data = f
        @tag_addr[name] = @addrs.size if name
        if data
          _add data
        end
      end
      
      _bin
    end
    
    def add(data, name = nil)
      @files << [name, data]
      @file_count += 1 if data
    end

    def tag(name)
      add nil, name
    end

    def config
      out = []
      out << "options(bank:-2);"
      out << "var FILE_ADDR:uint16[] options( address:0xa000 );"
      out << "var FILE_SIZE:uint16[] options( address:#{0xa000+@file_count*2} );"
      
      @tag_addr.each do |k,v|
        out << "const #{k} = #{@tag_addr[k]};"
      end
      
      out.join("\n")
    end

    private
    
    def _add( data )
      data = data.flatten

      # over the bank
      if ((@buf.size+data.size) / BANK_SIZE) != (@buf.size / BANK_SIZE)
        @buf.concat Array.new(BANK_SIZE - @buf.size % BANK_SIZE){0}
      end

      @addrs << @buf.size
      @sizes << data.size
      @buf.concat data
    end

    def _bin
      head = @addrs.pack('v*') + @sizes.pack('v*')
      head = head + "\0" * (BANK_SIZE-head.size)
      head + @buf.pack('c*')
    end

    def bank_size
      (@buf.size.to_f / BANK_SIZE).ceil
    end

  end
end
