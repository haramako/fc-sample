require "nes_tools/version"
require 'backports'

module NesTools
  autoload :BitWriter, 'nes_tools/bit'
  autoload :BitReader, 'nes_tools/bit'
  autoload :BitArray, 'nes_tools/bit'
  autoload :Compress, 'nes_tools/compress'
  autoload :Nsd, 'nes_tools/nsd'
  autoload :Tile, 'nes_tools/tile'
  autoload :TileSet, 'nes_tools/tile'
  autoload :Fs, 'nes_tools/fs'
  autoload :TextConverter, 'nes_tools/text_converter'
  autoload :Command, 'nes_tools/command'
end

begin
  require 'ffi'
  module FFI::Library
    alias attach_function_old attach_function
    def attach_function(fun, ary, ret)
      return if [:gdFontCacheSetup, :gdFontCacheShutdown].include? fun
      attach_function_old(fun, ary, ret)
    end
  end
    
rescue LoadError
  puts 'cannot load ffi'
end
