require 'nes_tools'
require 'optparse'

module NesTools
  module Command
    
    module_function
    
    def run
      command = ARGV.shift
      case command
      when 'image'
      when 'nsd'
        NsdCommand.new(ARGV).run
      when 'help', '-h', '--help', nil
        show_help
      else
        puts "unknown <command> #{command}"
        puts
        show_help
      end
    end

    def show_help
      puts 'Usage: nes_tools <command> [options]'
      puts 'Commands:'
      puts '  help         show help for commands'
      puts '  image        convert image'
      puts '  nsd          convert NSD mml file'
      exit
    end

    autoload :NsdCommand, 'nes_tools/command/nsd_command'

  end
end
