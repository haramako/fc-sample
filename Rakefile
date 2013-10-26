task :default => 'fs_config.fc' do
  sh "ruby ../bin/fc c -d -t nes main.fc"
  sh 'ca65 data.asm'
  sh "ld65 -o a.nes -m a.map -C ld65.cfg #{Dir.glob('*.o').join(' ')} nsd/lib/NSD.LIB "
end

task :makoto do
  sh 'ruby tools/tiled_conv.rb map-makoto.json'
  sh "ruby ../bin/fc c -d -t nes main.fc"
  sh 'ca65 data.asm'
  sh 'ld65 -o a.nes -m a.map -C ld65.cfg .fc-build/*.o data.o nsd/lib/NSD.LIB'
end

file 'fs_config.fc' => ['map.json'] do
  sh 'ruby tools/tiled_conv.rb map.json'
end

task :clean do
  FileUtils.rm_rf ["a.*", "*.o", "*.s", "_*.inc", "fs_config.fc", "res/fs_data.bin"]
end
