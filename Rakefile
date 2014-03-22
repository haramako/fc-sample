MAP_JSON = ENV['map'] || 'map.json'

sounds = Dir.glob('res/sound/*.bin')
fc_files = Dir.glob('*.fc')

task :default => fc_files do
  sh "fcc compile -d -t nes main.fc"
  sh 'ca65 data.asm -o .fc-build/data.o'
  sh "ld65 -o castle.nes -m castle.map -C ld65.cfg #{Dir.glob('.fc-build/*.o').join(' ')} nsd/lib/NSD.LIB "
end

ENV['PATH'] += ':./nes_tools/bin'

file 'fs_config.fc' => [MAP_JSON] + sounds do
  sh "ruby tools/tiled_conv.rb #{MAP_JSON}"
end

rule '.bin' => '.mml' do |target|
  sh "nes_tools nsd #{target.source}"
end

task :clean do
  FileUtils.rm_rf Dir.glob(["castle.nes", "castle.map",
                            ".fc-build", "fs_config.fc", "resource.fc", "res/fs_data.bin"])
end
