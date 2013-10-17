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
	

