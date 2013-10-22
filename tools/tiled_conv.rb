#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'pp'
require 'json'
require 'erb'
require_relative 'rle'
require_relative 'text_conv'
require_relative 'nes_tool'


# 8KBごとのバンクに分けられたバッファ
class BankedBuffer
  BANK_SIZE = 0x2000

  attr_reader :buf, :sizes, :addrs

  def initialize
    @buf = []
    @sizes = []
    @addrs = []
  end

  def add( data )
    data = data.flatten

    # バンクをまたぐなら
    if ((@buf.size+data.size) / BANK_SIZE) != (@buf.size / BANK_SIZE)
      @buf.concat Array.new(BANK_SIZE - @buf.size % BANK_SIZE){0}
    end

    @addrs << @buf.size
    @sizes << data.size
    @buf.concat data
  end

  def cur
    @addrs.size
  end

  def bin
    @buf.pack('c*')
  end

  def bank_size
    (@buf.size.to_f / BANK_SIZE).ceil
  end

end

# タイルデータのコンバート
class TiledConverter

  AREA_WIDTH = 16
  AREA_HEIGHT = 15

  ENEMY_TYPE = {
    slime:1, wow:2, elevator:3, block:6, frog:7, cookie:8, chest:9, lamp:10, 
    gas:11, ghost:12, switch:13, flaged_door:14, portal:15,
  }

  ITEM_DATA = 
    [
     ['sandal', 'サンダル', 'すごくやわらかいものなら乗れるかも？'],
     ['lamp', 'ランプ', '燭台に火を灯す'],
     ['grobe', 'グローブ', 'これなら、岩を押してもケガしない'],
     ['boots', 'まきもの', '昔、カエルに乗る忍者がいたそうだ・・・'],
     ['omamori', 'お守り', 'ひとだまに触っても祟られない'],
     ['map', '地図', '迷宮で迷わないためには、地図が必要だ'],
     ['gas_mask', 'ガスマスク', 'ガスにあたっても死なない'],
     ['weight', 'おもり', '水に潜れるようになる'],
     ['craw', 'かぎ爪', 'はしごに飛び乗れる'],
     ['wing', '天使の羽', 'すきなチェックポイントに飛べる'],
    ]

  def initialize( filename )
    data = JSON.parse( File.read(filename) )

    w = data['width'].to_i
    h = data['height'].to_i
    raise if w % AREA_WIDTH != 0 or h % AREA_HEIGHT != 0
    @buf = BankedBuffer.new
    @world_width = w / AREA_WIDTH
    @world_height = h / AREA_HEIGHT

    @text_conv = TextConverter.new

    conv_text
    conv_tile( data )
    conv_item( data )
    conv_item_data
    make_font
    make_bg_image

    print ERB.new(DATA.read,nil,'-').result(binding)

    @buf.buf.each_slice( BankedBuffer::BANK_SIZE ).with_index do |bin,i|
      open("res/fs_data#{i}.bin",'wb'){|f| f.write bin.pack('c*') }
      open("fs_data#{i}.fc",'w') do |f|
        f.puts "options( bank: #{4+i} ); const _fs_data#{i} = incbin('res/fs_data#{i}.bin');"
      end
    end
  end

  # フォント画像の作成
  def make_font
    @text_conv.make_image('res/text.png')
    IO.write('text.txt', @text_conv.using.join)
    tile_set = NesTool::TileSet.new
    tile_set.add_from_img( GD2::Image.import('res/text.png'), pal: :monochrome )
    tile_set.save 'res/text.chr'
  rescue LoadError
    STDERR.puts 'WARING: make_font failed'
    STDERR.puts $!
  end

  # BGイメージの作成
  def make_bg_image
    begin
      require 'gd2-ffij'
      img = GD2::Image.import( 'res/character.chr.bmp' )

      tset = NesTool::TileSet.new
      tset.add_from_img( img )
      tset.reflow!

      pal = []
      img.palette.each do |c|
        pal[c.index] = c if c.index
      end
      pal = pal[0...64]

      base_pal = JSON.parse( IO.read('res/nes_palette.json') )
      pal_set = pal.map do |p|
        next 13 unless p
        min_idx = -1
        min = 999
        base_pal.each.with_index do |bp,i|
          d = (p.r - bp[0]).abs + (p.g - bp[1]).abs + (p.b - bp[2]).abs
          if d < min
            min = d
            min_idx = i
            break if d == 0
          end
        end
        min_idx
      end

      tile_pals = []
      tset.tiles.each_slice(128).each do |tiles|
        tile_pals << tiles.each_slice(4).map{|t| t[0].palette % 4}
      end

      JSON.dump( {pal_set:pal_set, tile_pals: tile_pals}, open('res/tmp_pal.json','w') ) # 一時的に保存

      common_tiles = tset.tiles.slice!(0,128) # 共通パーツ相当の128タイルを削除する
      bin = tset.bin
      IO.write("res/bg0.chr", bin[0...8192])
      IO.write("res/bg1.chr", bin[8192..-1])

      # 共通パーツの作成
      common = NesTool::TileSet.new
      4.times{ common.tiles.concat common_tiles }
      anim = NesTool::TileSet.new
      anim.add_from_img( GD2::Image.import('res/anim.bmp') )
      anim.reflow!
      [[0,24]].each do |src,dest|
        src *= 4
        dest *= 4
        4.times do |i| 
          common.tiles[dest+i*128...dest+i*128+4] = anim.tiles[src+i*4...src+i*4+4]
        end
      end
      IO.write("res/bg_common.chr", common.bin)

    rescue LoadError
      json = JSON.parse( IO.read('res/tmp_pal.json') ) 
      pal_set = json['pal_set']
      tile_pals = json['tile_pals']
    end

    @pal_set = pal_set
    @tile_pal_base = @buf.cur
    tile_pals.each do |pals|
      @buf.add pals
    end

  end

  # タイルデータの収集
  def conv_tile( data )
    a = Array.new(@world_width*@world_height*AREA_WIDTH*AREA_HEIGHT)

    # レイヤーを重ねる
    layers = data['layers'].select{|x| x['type'] == 'tilelayer'}.reverse
    a.size.times do |i|
      l = layers.find{|layer| layer['data'][i] != 0 }
      raise "Invalid map data" unless l
      a[i] = l['data'][i] - 1
    end

    @tile_base = @buf.cur
    @area_types = []
    @world_height.times do |ay|
      @world_width .times do |ax|
        area_type = 0
        d = []
        15.times do |cy|
          16.times do |cx|
            cell = a[(ay*15+cy)*AREA_WIDTH*@world_width + (ax*16+cx)]
            if cell > 32
              area_type = cell / 32 if area_type == 0
              cell = cell % 32 + 32
            end
            d[cy*16+cx] = cell
          end
        end
        @buf.add rle_compress( d )
        @area_types << area_type
      end
    end
  end

  # ピクセル数を[エリア番号, エリア内のセルX, エリア内のセルY]に変換する
  def px2area( x, y )
    x = x.to_i/16
    y = (y.to_i/16)-1
    area = (y/AREA_HEIGHT)*@world_width + x/AREA_WIDTH
    [area, x%AREA_WIDTH, y%AREA_HEIGHT]
  end

  # アイテムデータの収集
  def conv_item( data )
    objs = data['layers'].find{|x| x['name'] == 'objects'}
    checkpoints = []
    enemy = Array.new(@world_width*@world_height){[]}
    objs['objects'].each do |obj|
      prop = obj['properties']
      case obj['type']
      when 'checkpoint'
        area, x, y = px2area( obj['x'], obj['y'] )
        checkpoints[prop['id'].to_i] = {name:obj['name'], area:area, x:x*16, y:y*16}
      when 'enemy'
        area, x, y = px2area( obj['x'], obj['y'] )
        type = obj['name'].empty? ? prop['type'] : obj['name']
        enemy[area] << {type:type, x:x, y:y, p1:prop['p1'].to_i, p2:prop['p2'].to_i, p3:prop['p3'].to_i }
      when 'item'
        area, x, y = px2area( obj['x'], obj['y'] )
        id = ITEM_DATA.find_index{|i| i[0] == obj['name'].downcase}
        raise unless id
        enemy[area] << {type:'chest', x:x, y:y, p1:id, p2:0, p3:0 }
      end
    end

    @cp_buf = BankedBuffer.new
    checkpoints.each.with_index do |cp,i|
      name = @text_conv.conv( cp[:name] )
      @cp_buf.add [ cp[:area], cp[:x], cp[:y], name, 0].flatten
    end

    @en_base = @buf.cur
    enemy.each.with_index do |area,i|
      area = area.map do |en| 
        if /^portal:(.+)/ === en[:type].downcase
          # ポータルの場合
          type = (128 | ENEMY_TYPE[ $1.downcase.to_sym ])
        else
          type = ENEMY_TYPE[ en[:type].downcase.to_sym ]
          # それ以外
        end
        raise unless type
        [type, en[:x], en[:y], en[:p1] % 256, en[:p2] % 256, en[:p3] % 256]
      end
      @buf.add area
    end
  end

  def conv_item_data

    @item_ids = []
    ITEM_DATA.each do |item|
      @item_ids << item[0].upcase
    end

    @item_name_base = @buf.cur
    ITEM_DATA.each do |item|
      @buf.add @text_conv.conv(item[1])
    end

    @item_desc_base = @buf.cur
    ITEM_DATA.each do |item|
      @buf.add @text_conv.conv(item[2])
    end

  end

  def conv_text
    Dir.glob('*.fc') do |f|
      d = []
      txt = File.open(f,'rb:UTF-8'){|f| f.read }
      txt.gsub(/_T\(\"(.*?)\"\)/){ d << $1 }
      @text_conv.conv(d.join(''))
    end
  end

end

if ARGV.empty?
  puts "Convert Tiled json file to binary."
  puts "usage: ./tile-conv <mapfile.json>"
  exit
end

TiledConverter.new( ARGV[0] )

__END__
options(bank:-2);

<%- @buf.bank_size.times do |i| -%>
use fs_data<%=i%>;
<%- end -%>

const MAP_WIDTH = <%=@world_width%>;
const MAP_HEIGHT = <%=@world_height%>;
const AREA_TYPES = <%=@area_types%>;

const TILE_BASE = <%=@tile_base%>;
const ENEMY_BASE = <%=@en_base%>;
const TILE_PAL_BASE = <%=@tile_pal_base%>;

const MAP_CHECKPOINT_NUM = <%=@cp_buf.cur%>;
const MAP_CHECKPOINT = <%=@cp_buf.addrs%>;
const MAP_CHECKPOINT_DATA = <%=@cp_buf.buf%>;

const ITEM_NAME_BASE = <%=@item_name_base%>;
const ITEM_DESC_BASE = <%=@item_desc_base%>;
<%- @item_ids.each.with_index do |item,i| -%>
const ITEM_ID_<%=item%> = <%= i %>;
<%- end -%>

const _FS_ADDR = <%=@buf.addrs%>;
const _FS_SIZE = <%=@buf.sizes%>;

const PAL_SET = <%=@pal_set%>;
