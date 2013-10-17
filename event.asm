;;; 先頭で宣言したいアセンブラのマクロなど
	
load .macro
	lda \2
	sta \1
	.endm

loadw .macro
	lda #LOW(\2)
	sta \1+0
	lda #HIGH(\2)
	sta \1+1
	.endm
	

;;; mmc3_cbank select
;;;   select: 0-5
;;;   x     : 8KB bank number
;;; use 11cycle
mmc3_cbank .macro
	lda #(\1)
	sta _MMC3_BANK_SELECT
	stx _MMC3_BANK_DATA
	.endm

;;; wait N
;;; use N*5+1 cycle
xwait .macro
	ldx \1
	dex
	bne *-1
	.endm

;;; irq_set counter
;;; set IRQ for MMC3.
;;; use 18cycle( if \1 is zeropage )
irq_set .macro
	lda \1
	sta _MMC3_IRQ_LATCH
	sta _MMC3_IRQ_RELOAD
	sta _MMC3_IRQ_DISABLE
	sta _MMC3_IRQ_ENABLE
	.endm
	
;;; scanline中のスクロールを行う
;;; x: X座標 y: Y座標
;;; See: http://forums.nesdev.com/viewtopic.php?p=64111#p64111
;;; use 56cycle ( jsr含む、最後の'sta _PPU_ADDR'まで )
scroll:
	lda #0
	clc
	rol a
	asl a
	asl a
	sta _PPU_ADDR
	tya
	sta _PPU_SCROLL
	asl a
	asl a
	and #%11100000
	sta _scroll_x+0
	txa
	lsr a
	lsr a
	lsr a
	ora _scroll_x+0

	;finish setting the scroll during HBlank (11 cycles)
	stx _PPU_SCROLL
	sta _PPU_ADDR
	rts

;;; IRQの設定
_event_irq_setup:
	irq_set #95
	
	ldx _mmc3_cbank_bak+0
	mmc3_cbank #0
	ldx _mmc3_cbank_bak+1
	mmc3_cbank #1
	
	loadw _irq_next, title_irq_1
	rts

;;; IRQ割り込み(上辺)
title_irq_1:
	irq_set #63
	xwait #1
	
	ldx #0
	ldy #0
	jsr scroll

	lda #%00100001
	sta _PPU_CTRL1

	ldx #(_CBANK_TEXT+0)
	mmc3_cbank #0
	ldx #(_CBANK_TEXT+1)
	mmc3_cbank #1

	loadw _irq_next, title_irq_2
	rts

;;; IRQ割り込み(下辺)
title_irq_2:
	sta _MMC3_IRQ_DISABLE
	xwait #4
	nop

	ldy #160
	jsr scroll
	
	ldx _mmc3_cbank_bak+0
	mmc3_cbank #0
	ldx _mmc3_cbank_bak+1
	mmc3_cbank #1

	lda _ppu_ctrl1_bak
	sta _PPU_CTRL1

	rts
