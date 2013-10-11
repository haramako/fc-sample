task :default => ['a.nes']

file 'a.nes' => ['map_data.fc'] do
  sh "ruby ../bin/fc -d -t nes main.fc"
end

file 'map_data.fc' => ['tiled-conv', 'map.json'] do
  sh 'ruby ./tiled-conv map.json > map_data.fc'
end

task :clean do
  sh 'rm -rf a.*'
end
