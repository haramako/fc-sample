#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'json'
require 'pp'

class TextConverter

  PRESET_CHAR = "　↓゛゜０１２３４５６７８９！？ー。、あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらゃゅょりるれろわをんっ".each_char.to_a

  CONVERT_CHAR = {
    ' ' => '　',
    "\n" => '↓',
    '?' => '？',
    '!' => '！',
    '-' => 'ー',
    'が' => 'か゛',
    'ぎ' => 'き゛',
    'ぐ' => 'く゛',
    'げ' => 'け゛',
    'ご' => 'こ゛',
    'ざ' => 'さ゛',
    'じ' => 'し゛',
    'ず' => 'す゛',
    'ぜ' => 'せ゛',
    'ぞ' => 'そ゛',
    'だ' => 'た゛',
    'ぢ' => 'ち゛',
    'づ' => 'つ゛',
    'で' => 'て゛',
    'ど' => 'と゛',
    'ば' => 'は゛',
    'び' => 'ひ゛',
    'ぶ' => 'ふ゛',
    'べ' => 'へ゛',
    'ぼ' => 'ほ゛',
    'ぱ' => 'は゜',
    'ぴ' => 'ひ゜',
    'ぷ' => 'ふ゜',
    'ぺ' => 'へ゜',
    'ぽ' => 'ほ゜',
    'ガ' => 'カ゛',
    'ギ' => 'キ゛',
    'グ' => 'ク゛',
    'ゲ' => 'ケ゛',
    'ゴ' => 'コ゛',
    'ザ' => 'サ゛',
    'ジ' => 'シ゛',
    'ズ' => 'ス゛',
    'ゼ' => 'セ゛',
    'ゾ' => 'ソ゛',
    'ダ' => 'タ゛',
    'ヂ' => 'チ゛',
    'ヅ' => 'ツ゛',
    'デ' => 'テ゛',
    'ド' => 'ト゛',
    'バ' => 'ハ゛',
    'ビ' => 'ヒ゛',
    'ブ' => 'フ゛',
    'ベ' => 'ヘ゛',
    'ボ' => 'ホ゛',
    'パ' => 'ハ゜',
    'ピ' => 'ヒ゜',
    'プ' => 'フ゜',
    'ペ' => 'ヘ゜',
    'ポ' => 'ホ゜',
  }

  attr_reader :using

  def initialize( _using = nil)
    @convert_char = CONVERT_CHAR.clone
    if _using
      @using = _using.chars.to_a
    else
      @using = PRESET_CHAR.clone
    end
  end

  def conv( str )
    str = str.tr('A-Za-z0-9','Ａ-Ｚａ-ｚ０-９')
    str = str.chars.map {|c| @convert_char[c] || c }.join
    str = str.chars.map do |c| 
      i = @using.find_index(c)
      unless i
        @using << c
        i = @using.size - 1
      end
      i
    end
    str
  end

  def make_image( filename )
    require 'gd2-ffij'
    src = GD2::Image.import('res/misaki_gothic.png')
    GD2::Image.new(128,128) do |dest|
      @using.each.with_index do |c,i|
        cj = c.encode('ISO-2022-JP')
        cp = cj.codepoints.to_a[3..4].map{|x| x-32 }
        dest.copy_from( src, (i%16)*8, (i/16)*8, (cp[1]-1)*8, (cp[0]-1)*8, 8, 8 )
      end
      dest.export(filename)
    end
  end

end

if __FILE__ == $0
  if ARGV.empty?
    puts 'Text Converter'
    puts 'Usage: ruby text-conv.rb infile.txt'
    exit
  end
  require 'json'
  txt = IO.read(ARGV[0]).force_encoding('UTF-8')
  conv = TextConverter.new
  conv.conv( txt )
  conv.make_image( 'text.png' )
  IO.write('text.txt', conv.using.join)
end
