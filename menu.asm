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
_menu_irq_setup:
	irq_set #128
	
	ldx _mmc3_cbank_bak+0
	mmc3_cbank #0
	ldx _mmc3_cbank_bak+1
	mmc3_cbank #1
	
	loadw _irq_next, menu_irq_1
	rts

;;; IRQ割り込み(上辺)
menu_irq_1:
	sta _MMC3_IRQ_DISABLE

	ldx #(_CBANK_TEXT+0)
	mmc3_cbank #0
	ldx #(_CBANK_TEXT+1)
	mmc3_cbank #1

	rts

