MAP_JSON = ENV['map'] || 'map.json'

sounds = Dir.glob('res/sound/*.mml')

task :default => 'fs_config.fc' do
  sh "fcc compile -d -t nes main.fc"
  sh 'ca65 data.asm -o .fc-build/data.o'
  sh "ld65 -o a.nes -m a.map -C ld65.cfg #{Dir.glob('.fc-build/*.o').join(' ')} nsd/lib/NSD.LIB "
end

file 'fs_config.fc' => [MAP_JSON] + sounds do
  sh "ruby tools/tiled_conv.rb #{MAP_JSON}"
end

rule '.bin' => '.mml' do |target|
  sh "ruby tools/sound_conv.rb #{target.source}"
end

task :clean do
  FileUtils.rm_rf Dir.glob(["a.*", ".fc-build", "fs_config.fc", "res/fs_data.bin"])
end
