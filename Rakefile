ENV['PATH'] += File::PATH_SEPARATOR+'./nes_tools/bin'
MAP_JSON = ENV['map'] || 'map.json'
images = Dir.glob('res/images/*.png')
sounds = Dir.glob('res/sound/*.bin')
fc_files = Dir.glob('src/*.fc') + ['src/fs_config.fc']

task :default => fc_files do
  Dir.chdir('src') do
    # sh "../../fc/bin/fcc compile -d -t nes main.fc"
    sh "fcc compile -d -t nes main.fc"
    sh 'ca65 data.asm -o .fc-build/data.o'
  end
  sh "ld65 -o castle.nes -m castle.map -C ld65.cfg #{Dir.glob('src/.fc-build/*.o').join(' ')} nsd/lib/NSD.LIB "
end

file 'src/fs_config.fc' => [MAP_JSON] + images + sounds do
  sh "ruby tools/tiled_conv.rb #{MAP_JSON}"
end

rule '.bin' => '.mml' do |target|
  sh "nes_tools nsd #{target.source}"
end

task :clean do
  FileUtils.rm_rf Dir.glob(["castle.nes", "castle.map",
                            "src/.fc-build", "src/fs_config.fc", "src/resource.fc", "res/fs_data.bin"])
end
