require 'pathname'
require 'tempfile'
require 'fileutils'
require 'open3'

module NesTools
  class Nsd

    case RbConfig::CONFIG['target_os']
    when /mswin(?!ce)|mingw|cygwin|bccwin/ 
      NSC = 'nsc.exe'
      CA65 = 'ca65.exe'
      LD65 = 'ld65.exe'
    else
      NSC = 'nsc'
      CA65 = 'ca65'
      LD65 = 'ld65'
    end

    LD65_CONFIG = <<EOT
MEMORY { ROM: start = $0000, size = $8000, file = %O; }
SEGMENTS { RODATA: load = ROM, type = ro, define = yes; }
EOT

    attr_accessor :show_command
    
    def initialize(&block)
      @show_command = false
      yield self if block
    end

    def convert( filename, output = nil )
      path = Pathname.new(filename)
      asm_path = path.sub_ext('.s')
      obj_path = path.sub_ext('.o')
      bin_path = path.sub_ext('.bin')

      cfg = Tempfile.new('nsc.cfg')
      cfg.write LD65_CONFIG
      cfg.close

      sh NSC, '-a', path

      asm = IO.read(asm_path)
      asm.gsub!( /.segment	"RODATA"\n/ ){ |m| m+"\t.word _nsd_BGM0\n" }
      IO.write asm_path, asm
      
      sh CA65, asm_path

      output ||= path.sub_ext('.bin')
      sh LD65, '-o', output, '-C', cfg.path, obj_path

      FileUtils.rm_f [path.sub_ext('.o'), asm_path]
    end

    private
    def sh( *args )
      command = args.map(&:to_s)
      puts command.join(" ") if @show_command
      Open3.popen2e( *command ) do |i, oe, th|
        v = th.value
        output = oe.read
        if v != 0
          puts output
          raise "`#{command}` returns #{v}"
        end
        output
      end
    end

  end
end
