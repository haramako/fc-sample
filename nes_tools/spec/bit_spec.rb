require 'nes_tools'
module NesTools
  describe BitWriter do
    subject { BitWriter.new }
    
    its(:buf){ should be_empty }

    it 'add one bit' do
      subject.write 1, 1
      expect(subject.buf).to eq [0x80]
    end

    it 'add some bits' do
      subject.write 1, 8
      expect(subject.buf).to eq [0x01]
    end

    it 'add some bits' do
      subject.write 1, 1
      subject.write 1, 7
      expect(subject.buf).to eq [0x81]
    end

    it 'add some bits' do
      subject.write 1, 7
      subject.write 1, 1
      expect(subject.buf).to eq [0x03]
    end
    
    it 'add some bits' do
      subject.write 1, 5
      subject.write 1, 4
      expect(subject.buf).to eq [0x08, 0x80]
    end

    it 'add some bits' do
      subject.write 1, 4
      subject.write 1, 5
      expect(subject.buf).to eq [0x10, 0x80]
    end

    it 'add word' do
      subject.write 1, 9
      expect(subject.buf).to eq [0x00, 0x80]
    end
    
    it 'add word' do
      subject.write 1, 15
      expect(subject.buf).to eq [0x00, 0x02]
    end

    it 'add word' do
      subject.write 1, 16
      expect(subject.buf).to eq [0x00, 0x01]
    end

    it 'add word' do
      subject.write 1, 17
      expect(subject.buf).to eq [0x00, 0x00, 0x80]
    end
    
  end
  
  describe 'BitWriter/Reader' do
    let(:writer){ BitWriter.new }
    let(:reader){ BitReader.new(writer.buf) }

    it 'with random data' do
      data = (0..100).map { b = rand(10); [rand(1 << b), b] }
      data.each do |d|
        writer.write d[0], d[1]
      end
      data.each do |d|
        expect(reader.read(d[1])).to eq d[0]
      end
    end

    it 'vln with random data' do
      data = (0..100).map { rand(1 << rand(16)) }
      data.each do |d|
        writer.write_vln16 d
      end
      data.each do |d|
        expect(reader.read_vln16).to eq d
      end
    end
    
  end
end
