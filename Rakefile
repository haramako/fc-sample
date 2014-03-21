MAP_JSON = ENV['map'] || 'map.json'

sounds = Dir.glob('res/sound/*.mml')

task :default => 'fs_config.fc' do
  sh "fcc c -d -t nes main.fc"
  sh 'ca65 data.asm'
  sh "ld65 -o a.nes -m a.map -C ld65.cfg #{Dir.glob('*.o').join(' ')} nsd/lib/NSD.LIB "
end

file 'fs_config.fc' => [MAP_JSON] + sounds do
  sh "ruby tools/tiled_conv.rb #{MAP_JSON}"
end

rule '.bin' => '.mml' do |target|
  sh "ruby tools/sound_conv.rb #{target.source}"
end

task :clean do
  FileUtils.rm_rf Dir.glob(["a.*", "*.o", "*.s", "_*.inc", "fs_config.fc", "res/fs_data.bin"])
end
