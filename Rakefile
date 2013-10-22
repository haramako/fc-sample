task :default => 'fs_config.fc' do
  sh "ruby ../bin/fc -d -t nes main.fc"
end

task :makoto do
  sh 'ruby tools/tiled_conv.rb map-makoto.json > fs_config.fc'
  sh "ruby ../bin/fc -d -t nes main.fc"
end

file 'fs_config.fc' => ['map.json'] do
  sh 'ruby tools/tiled_conv.rb map.json > fs_config.fc'
end

task :clean do
  sh 'rm -rf a.* fs_data* fs_config.fc'
end
