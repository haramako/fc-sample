uint8_p = Type[[:pointer, :uint8]]

require File.dirname(__FILE__)+'/tools/text_conv'

conv = TextConverter.new( File.read('text.txt') )

defmacro( :_T ) do |args|
  text = conv.conv( args[0].base_string ) + [0]
  [:array, text]
end
