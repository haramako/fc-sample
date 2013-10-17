;;; IRQの設定
_event_irq_setup:
	irq_set #95
	
	ldx _mmc3_cbank_bak+0
	mmc3_cbank #0
	ldx _mmc3_cbank_bak+1
	mmc3_cbank #1
	
	loadw _irq_next, event_irq_1
	rts

;;; IRQ割り込み(上辺)
event_irq_1:
	irq_set #63
	xwait #1
	
	ldx #0
	ldy #0
	jsr scroll

	lda #%10100001
	sta _PPU_CTRL1

	ldx #(_CBANK_TEXT+0)
	mmc3_cbank #0
	ldx #(_CBANK_TEXT+1)
	mmc3_cbank #1

	loadw _irq_next, event_irq_2
	rts

;;; IRQ割り込み(下辺)
event_irq_2:
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
