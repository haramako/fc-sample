uint8_p = Type[[:pointer, :uint8]]

$LOAD_PATH << '../nes_tools/lib'
require 'nes_tools'

conv = NesTools::TextConverter.new( nil, File.read('../text.txt') )

defmacro( :_T ) do |args|
  text = conv.conv( args[0].base_string ) + [0]
  [:array, text]
end

defmacro( :VERSION_STR ) do |args|
  [:array, conv.conv( 'VERSION ' + IO.read('../VERSION').chomp ) + [0]]
end
