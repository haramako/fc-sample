require 'nes_tools/compress'

module NesTools::Compress
  
  describe "lzw" do
    
    def should_compress_random_data
      data = (0..1000).map{ rand(8) }
      compressed = subject.compress(data)
      decompressed = subject.decompress(compressed)
      expect(decompressed).to eq data
    end
    
    describe Lzw do
      it { should_compress_random_data }
    end
    
    describe Rle do
      it { should_compress_random_data }
    end

    describe Nbit do
      it do
        data = (0..1000).map{ rand(5) }
        compressed = Nbit.compress(data, 5)
        decompressed = Nbit.decompress(compressed, 5, 100)
      end
    end
  end
  
end
