
__nsd_init = $A010
__nsd_main = $A01A
__nsd_play_bgm = $A096
__nsd_play_se = $A1AE

_nsd_init:
	txa
	pha
	jsr __nsd_init
	pla
	tax
	rts

_nsd_main_nsd:
	ldx #_common_PBANK_NSD
	mmc3_pbank #1
	ldx #_common_PBANK_MUSIC
	mmc3_pbank #0
	jsr __nsd_main
	ldx _mmc3_pbank_bak+0
	mmc3_pbank #0
	ldx _mmc3_pbank_bak+1
	mmc3_pbank #1
	rts

_nsd_play_bgm:
	txa
	pha
	
	ldx #_common_PBANK_NSD
	mmc3_pbank #1
	ldx #_common_PBANK_MUSIC
	mmc3_pbank #0
	
	lda #$62
	ldx #$80
	jsr __nsd_play_bgm
	
	ldx _mmc3_pbank_bak+0
	mmc3_pbank #0
	ldx _mmc3_pbank_bak+1
	mmc3_pbank #1
	
	pla
	tax
	rts

_nsd_play_se:
	txa
	pha
	
	lda S+0,x
	pha
	lda S+1,x
	pha
	
	ldx #_common_PBANK_NSD
	mmc3_pbank #1
	
	pla
	tax
	pla
	jsr __nsd_play_se
	
	ldx _mmc3_pbank_bak+1
	mmc3_pbank #1
	
	pla
	tax
	rts
