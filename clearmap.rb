# -*- coding: utf-8 -*-

require 'pp'
require 'json'

# map.json のタイル番号１の部分をタイル番号０(透過）に設定する

data = JSON.parse( ARGF.read )

m = data['layers'][0]['data']
m.map!{|x| if x == 1 then 0 else x end }

print JSON.dump( data )
