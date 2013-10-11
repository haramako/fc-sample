
all: map_data.fc
	../bin/fc -d -t nes main.fc

map_data.fc: tiled-conv map.json
	./tiled-conv map.json > map_data.fc

clean:
	rm -rf a.*
