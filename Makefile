all: tmp build fetch build/tw-all.json

tmp build:
	mkdir $@

tmp/Village_NLSC_TWD97_1040330.shp: tmp/villages.zip
	7z x -y -otmp $<
	cd tmp && unrar x -y *rar
	touch $@
	
fetch: tmp/villages.zip tmp/villages.csv
	
NLSC_ARCHIVE='http://tgos.nat.gov.tw/tgos/VirtualDir/Temp/%E6%9D%91%E9%87%8C%E7%95%8C%E5%9C%96(WGS84%E7%B6%93%E7%B7%AF%E5%BA%A6).zip'
TWHGIS_ARCHIVE='https://raw.githubusercontent.com/g0v/twhgis/latest/villages.csv'
	
tmp/villages.zip:
	curl -o $@ $(NLSC_ARCHIVE)
	
tmp/villages.csv:
	curl -o $@ $(TWHGIS_ARCHIVE)
	
tmp/villages.json: tmp/Village_NLSC_TWD97_1040330.shp
	node_modules/.bin/mapshaper -i $< encoding=big5 -o $@
	
build/tw.json: tmp/villages.json
	lsc cleanup-nlsc.ls --file $< > $@

build/tw-town.json: build/tw.json
	topojson-merge -o $@ --io villages --oo towns -k d.properties.itid $<
	
build/tw-all.json: build/tw-town.json
	topojson-merge -o $@ --io towns --oo counties -k d.properties.icid $<
