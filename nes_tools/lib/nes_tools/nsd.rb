require 'pathname'
require 'tempfile'
require 'fileutils'

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

    def initiaize
    end
    
    def sh( *args )
      require 'open3'
      command = args.map(&:to_s)
      puts command.join(" ")
      Open3.popen2e( *command ) do |i, oe, th|
        v = th.value
        if v != 0
          raise "`#{command}` returns #{v}"
          puts oe.read
        end
        oe.read
      end
    end

    def convert( filename )
      path = Pathname.new(filename)
      asm_path = path.sub_ext('.s')
      obj_path = path.sub_ext('.o')
      bin_path = path.sub_ext('.bin')

      cfg = Tempfile.new('nsc.cfg')
      cfg.write LD65_CONFIG
      cfg.close

      sh NSC, '-a', path

      sh CA65, asm_path
      asm = IO.read(asm_path)
      asm.gsub!( /.segment	"RODATA"\n/ ){ |m| m+"\t.word _nsd_BGM0\n" }
      IO.write asm_path, asm

      sh LD65, '-o', path.sub_ext('.bin'), '-C', cfg.path, obj_path

      FileUtils.rm_f [path.sub_ext('.o'), asm_path]
    end

  end
end
