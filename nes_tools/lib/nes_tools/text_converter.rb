#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'nes_tools'

module NesTools
  class TextConverter

    PRESET_CHAR = ("¶　↓゛゜０１２３４５６７８９！？ー。、"+
                   "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめも"+
                   "やゆよらゃゅょりるれろわをんっ").each_char.to_a

    CONVERT_CHAR = {
      ' ' => '　',
      "\n" => '↓',
      '?' => '？',
      '!' => '！',
      'ー' => '−',
      'が' => '゛か',
      'ぎ' => '゛き',
      'ぐ' => '゛く',
      'げ' => '゛け',
      'ご' => '゛こ',
      'ざ' => '゛さ',
      'じ' => '゛し',
      'ず' => '゛す',
      'ぜ' => '゛せ',
      'ぞ' => '゛そ',
      'だ' => '゛た',
      'ぢ' => '゛ち',
      'づ' => '゛つ',
      'で' => '゛て',
      'ど' => '゛と',
      'ば' => '゛は',
      'び' => '゛ひ',
      'ぶ' => '゛ふ',
      'べ' => '゛へ',
      'ぼ' => '゛ほ',
      'ぱ' => '゜は',
      'ぴ' => '゜ひ',
      'ぷ' => '゜ふ',
      'ぺ' => '゜へ',
      'ぽ' => '゜ほ',
      'ガ' => '゛カ',
      'ギ' => '゛キ',
      'グ' => '゛ク',
      'ゲ' => '゛ケ',
      'ゴ' => '゛コ',
      'ザ' => '゛サ',
      'ジ' => '゛シ',
      'ズ' => '゛ス',
      'ゼ' => '゛セ',
      'ゾ' => '゛ソ',
      'ダ' => '゛タ',
      'ヂ' => '゛チ',
      'ヅ' => '゛ツ',
      'デ' => '゛テ',
      'ド' => '゛ト',
      'バ' => '゛ハ',
      'ビ' => '゛ヒ',
      'ブ' => '゛フ',
      'ベ' => '゛ヘ',
      'ボ' => '゛ホ',
      'パ' => '゜ハ',
      'ピ' => '゜ヒ',
      'プ' => '゜フ',
      'ペ' => '゜ヘ',
      'ポ' => '゜ホ',
    }

    attr_reader :using
    attr_reader :font_image

    def initialize( _font_image = nil, _using = nil)
      if _font_image
        require 'gd2-ffij'
        @font_image = ::GD2::Image.import(_font_image)
      else
        @font_image = nil
      end
      @convert_char = CONVERT_CHAR.clone
      if _using
        @using = _using.chars.to_a
      else
        @using = PRESET_CHAR.clone
      end
    end

    def conv( str )
      str = str.tr('A-Za-z0-9.\-[](),:/";','Ａ-Ｚａ-ｚ０-９．−［］（），：／”；')
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
      GD2::Image.new(128,128) do |dest|
        @using.each.with_index do |c,i|
          c = '　' if i == 0 # 文字コード０は常に空白
          cj = c.encode('ISO-2022-JP')
          begin
            cp = cj.codepoints.to_a[3..4].map{|x| x-32 }
          rescue
            p c
          end
          dest.copy_from( @font_image, (i%16)*8, (i/16)*8, (cp[1]-1)*8, (cp[0]-1)*8, 8, 8 )
        end
        dest.export(filename)
      end
    end

  end
end
