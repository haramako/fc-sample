task :default => 'fs_config.fc' do
  sh "ruby ../bin/fc -d -t nes main.fc"
end

file 'fs_config.fc' => ['tiled-conv', 'map.json'] do
  sh 'ruby ./tiled-conv map.json > fs_config.fc'
end

task :clean do
  sh 'rm -rf a.*'
end
