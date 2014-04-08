module NesTools
  
  class Palette
    class << self
      def nespal(img)
        pal = []
        img.palette.each do |c|
          pal[c.index] = c if c.index
        end
        
        base_pal = JSON.parse( IO.read('res/images/nes_palette.json') )
        pal.map do |p|
          next 13 unless p
          min_idx = -1
          min = 999
          base_pal.each.with_index do |bp,i|
            d = (p.r - bp[0]).abs + (p.g - bp[1]).abs + (p.b - bp[2]).abs
            if d < min
              min = d
              min_idx = i
              break if d == 0
            end
          end
          min_idx
        end
      end
    end
  end
    
end
