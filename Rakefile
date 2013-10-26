task :default => 'fs_config.fc' do
  sh "ruby ../bin/fc c -d -t nes main.fc"
  sh 'ca65 data.asm'
  sh 'ld65 -m a.map -C ld65.cfg .fc-build/*.o data.o nsd/lib/NSD.LIB -o a.nes'
end

task :makoto do
  sh 'ruby tools/tiled_conv.rb map-makoto.json'
  sh "ruby ../bin/fc c -d -t nes main.fc"
  sh 'ca65 data.asm'
  sh 'ld65 -m a.map -C ld65.cfg .fc-build/*.o data.o nsd/lib/NSD.LIB -o a.nes'
end

file 'fs_config.fc' => ['map.json'] do
  sh 'ruby tools/tiled_conv.rb map.json'
end

task :clean do
  sh 'rm -rf a.* fs_data* fs_config.fc'
end
