module NesTools
  module Command
    
    class NsdCommand
      def initialize(args)
        @args = args
        @opt = Hash.new
        op = OptionParser.new("Convert NSD (NES Sound Driver) mml file to binary." +
                              "Play by 'nsd.fc'.\n" +
                              "Usage: nes_tools nsd [-o outfile] infile.mml ...\n"+
                              "Options:\n")
        op.on( '-h', '--help', 'show this help' ){ puts op; exit }
        op.on( '-v', '--verbose', 'verbouse mode' ){ @opt[:verbose] = true }
        op.on( '-o filename', 'specify output file (default: *.bin)' ){ |v| @opt[:output] = v }
        op.parse! @args
        if @args.empty?
          puts op
          exit
        end
      end
      
      def run

        if @opt[:output] and @args.size != 1
          puts 'cannot use -o with multiple files!'
          exit 1
        end
        
        nsd = NesTools::Nsd.new
        nsd.show_command = true if @opt[:verbose]
        
        @args.each do |filename|
          if @opt[:output]
            nsd.convert filename, @opt[:output]
          else
            nsd.convert filename
          end
        end
      end
    end
    
  end
end
