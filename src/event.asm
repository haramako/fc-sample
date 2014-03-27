;;; IRQの設定
	.include "./macro.asm"
	.import scroll
	
.segment "event"
	
_event_irq_setup:
	irq_set #95

	ldx _mmc3_cbank_bak+0
	mmc3_cbank 0
	ldx _mmc3_cbank_bak+1
	mmc3_cbank 1

	loadw _ppu_irq_next, event_irq_1
	rts

;;; IRQ割り込み(上辺)
event_irq_1:
	xwait #5
	irq_set #61
	xwait #5
	nop
	nop
	nop
	lda #0
	sta _nes_PPU_CTRL2
	
	ldx #(_common_CBANK_TEXT+0)
	mmc3_cbank 0
	ldx #(_common_CBANK_TEXT+1)
	mmc3_cbank 1

	ldx #0
	ldy #0
	jsr scroll

	lda #%10100001
	sta _nes_PPU_CTRL1

	xwait #23
	nop
	lda _ppu_ctrl2_bak
	sta _nes_PPU_CTRL2
	
	loadw _ppu_irq_next, event_irq_2
	rts

;;; IRQ割り込み(下辺)
event_irq_2:
	sta _mmc3_IRQ_DISABLE
	xwait #14
	lda #0
	sta _nes_PPU_CTRL2

	nop
	nop
	ldx #0
	ldy #160
	jsr scroll
	
	ldx _mmc3_cbank_bak+0
	mmc3_cbank 0
	ldx _mmc3_cbank_bak+1
	mmc3_cbank 1

	lda _ppu_ctrl1_bak
	sta _nes_PPU_CTRL1

	;; xwait #1
	lda _ppu_ctrl2_bak
	sta _nes_PPU_CTRL2
	
	rts
