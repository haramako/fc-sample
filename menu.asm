;;; IRQの設定
	.include "./macro.asm"
	
.segment "CODE" 				; 割り込みのためにCODEセグメントに配置
	
_menu_irq_setup:
	irq_set #31
	
	ldx #(_common_CBANK_TEXT+0)
	mmc3_cbank 0
	ldx #(_common_CBANK_TEXT+2)
	mmc3_cbank 1
	
	loadw _ppu_irq_next, menu_irq_1
	rts

;;; IRQ割り込み(上辺)
menu_irq_1:
	irq_set #95

	ldx _mmc3_cbank_bak+0
	mmc3_cbank 0
	ldx _mmc3_cbank_bak+1
	mmc3_cbank 1

	;; scene == SCENE_MAP のときは、ここで終わり
	lda _menu_scene
	cmp #_menu_SCENE_MAP
	bne @end
	sta _mmc3_IRQ_DISABLE
@end:

	loadw _ppu_irq_next, menu_irq_2
	rts

;;; IRQ割り込み(上辺)
menu_irq_2:
	sta _mmc3_IRQ_DISABLE

	ldx #(_common_CBANK_TEXT+0)
	mmc3_cbank 0
	ldx #(_common_CBANK_TEXT+2)
	mmc3_cbank 1

	rts
	
