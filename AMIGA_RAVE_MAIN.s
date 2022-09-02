;*** MiniStartup by Photon ***
	INCDIR	"NAS:AMIGA/CODE/dsr_amiga_rave/"
	SECTION	"Code+PT12",CODE
	INCLUDE	"PhotonsMiniWrapper1.04!.S"
	INCLUDE	"custom-registers.i"	;use if you like ;)
	INCLUDE	"PT12_OPTIONS.i"
	INCLUDE	"P6112-Play-stripped.i"
;********** Constants **********
wi		EQU 320
he		EQU 256		; screen height
bpls		EQU 3		; depth
bypl		EQU wi/16*2	; byte-width of 1 bitplane line (40bytes)
bwid		EQU bpls*bypl	; byte-width of 1 pixel line (all bpls)
blitsize		EQU he*64+wi/16	; size of blitter operation
blitsizeF		EQU %000000000000010101	; size of FULL blitter operation
bplsize		EQU bypl*he	; size of 1 bitplane screen
hband		EQU 10		; lines reserved for textscroller
hblit		EQU he/2		;-hband	; size of blitter op without textscroller
wblit		EQU wi/2/16*2
bypl_real		EQU wi/16*2
TEXTURE_H		EQU 640+320
X_2X_SLICE	EQU 9
X_SLICE		EQU 26
Y_SLICE		EQU 32
;*************
MODSTART_POS	EQU 0		; start music at position # !! MUST BE EVEN FOR 16BIT
;*************

_PushColorsDown:	MACRO
	LEA	\1,A0
	ADD.W	\2,A0		; FASTER THAN LEA \1+16
	LEA	$DFF180,A1
	REPT 4
	MOVE.L	(A0)+,(A1)+
	ENDR
		ENDM
_PushColorsUp:	MACRO
	LEA	\1,A0
	ADD.W	\2,A0		; FASTER THAN LEA \1+16
	LEA	16(A0),A0		; FASTER THAN LEA \1+16
	LEA	$DFF182,A1
	REPT 4
	MOVE.L	-(A0),(A1)+
	ENDR
		ENDM
_WaitRasterCopper:	MACRO
	;MOVE.W	#$0FF0,$DFF180		; show rastertime left down to $12c
	BTST	#4,INTENAR+1
	;MOVE.W	#$0000,$DFF180		; show rastertime left down to $12c
	MOVE.W	#$8010,INTENA
		ENDM

;********** Demo **********	;Demo-specific non-startup code below.
Demo:			;a4=VBR, a6=Custom Registers Base addr
	;*--- init ---*
	MOVE.L	#VBint,$6C(A4)
	MOVE.W	#%1110000000100000,INTENA
	MOVE.W	#%1000001111100000,DMACON
	;*--- start copper ---*
	LEA	PIC,A0
	LEA	COPPER_PRE\.BplPtrs,A1
	BSR.W	PokePtrs
	ADD.L	#bypl*he,A0
	LEA	COPPER_PRE\.BplPtrs+8,A1
	BSR.W	PokePtrs
	ADD.L	#bypl*he,A0
	LEA	COPPER_PRE\.BplPtrs+16,A1
	BSR.W	PokePtrs
	ADD.L	#bypl*he,A0
	LEA	COPPER_PRE\.BplPtrs+24,A1
	BSR.W	PokePtrs
	ADD.L	#bypl*he,A0
	LEA	COPPER_PRE\.BplPtrs+32,A1
	BSR.W	PokePtrs
	BSR.W	WaitEOF			; TO SLOW DOWN :)
	MOVE.L	#COPPER_PRE,COP1LC

	LEA	BGPLANE0,A0
	LEA	COPPER\.BplPtrs,A1
	BSR.W	PokePtrs

	LEA	BGPLANE1,A0
	LEA	COPPER\.BplPtrs+8,A1
	BSR.W	PokePtrs

	LEA	BGPLANE2,A0
	LEA	COPPER\.BplPtrs+16,A1
	BSR.W	PokePtrs

	; #### CPU INTENSIVE TASKS BEFORE STARTING MUSIC
	MOVE.L	KICKSTART_ADDR,A3
	;LEA	PIXELS,A3			; NOW 3 BPLS
	LEA	X_TEXTURE_MIRROR,A4		; FILLS A PLANE
	BSR.W	__EXPAND_PIXELS		; WITH DITHERING

	LEA	X_TEXTURE_MIRROR,A3		; FILLS A PLANE
	LEA	X_TEXTURE_MIRROR,A4		; FILLS A PLANE
	BSR.W	__FILL_MIRROR_TEXTURE	; WITH DITHERING

	LEA	X_TEXTURE_MIRROR,A3		; CENTERS PIXEL 8x8
	BSR.W	__MIRROR_PLANE

	;MOVE.L	#DITHERPLANE,A4		; FILLS A PLANE #DITHERPLANE
	;MOVE.W	#0,D0
	;BSR.W	__DITHER_PLANE		; WITH DITHERING

	; ## PRECALCULATE BPL OFFSETS ##
	CLR.L	D0
	LEA	BPL_PRECALC,A2
	.loop:
	MOVE.W	D0,(A2)
	ADD.W	#bypl,D0
	CMP.W	#bypl*he,(A2)+
	BLO.S	.loop
	; ## PRECALCULATE BPL OFFSETS ##

	; ## CPU COPPER :) ##
	_PushColorsDown	BLUE_TBL,#$0
	; ## CPU COPPER :) ##

	BSR.W	__SWAP_ODD_EVEN_PTRS
	; #### CPU INTENSIVE TASKS BEFORE STARTING MUSIC

	; #### Point LOGO sprites
	BSR.W	__POKE_SPRITE_POINTERS
	; #### Point LOGO sprites

	MOVE.L	#COPPER,COP1LC

	; ---  Call P61_Init  ---
	MOVEM.L	D0-A6,-(SP)
	LEA	MODULE,A0
	SUB.L	A1,A1
	SUB.L	A2,A2
	MOVE.W	#MODSTART_POS,P61_InitPos	; TRACK START OFFSET
	JSR	P61_Init
	MOVEM.L (SP)+,D0-A6

;********************  main loop  ********************
MainLoop:
	;MOVE.W	#$12C,D0		; No buffering, so wait until raster
	;BSR.W	WaitRaster	;is below the Display Window.
	BSR.W	__SET_PT_VISUALS

	; do stuff here :)
	;SONG_BLOCKS_EVENTS:
	;* FOR TIMED EVENTS ON BLOCK ****
	;MOVE.W	P61_LAST_POS,D5
	;CLR.W	$100		; DEBUG | w 0 100 2
	MOVE.W	P61_Pos,D5
	;MOVE.W	#$0,D5
	LEA	TIMELINE,A3
	ADD.W	D5,D5		; CALCULATES OFFSET (OPTIMIZED)
	ADD.W	D5,D5		; CALCULATES OFFSET (OPTIMIZED)
	MOVE.L	(A3,D5),A3	; THANKS HEDGEHOG!!
	JSR	(A3)		; EXECUTE SUBROUTINE BLOCK#

	_WaitRasterCopper		; is below the Display Window.

	;TST.B	FRAME_STROBE
	;BNE.W	.oddFrame
	;MOVE.B	#1,FRAME_STROBE
	;
	;BRA.W	.evenFrame
	;.oddFrame:
	;MOVE.B	#0,FRAME_STROBE
	;
	;.evenFrame:

	;LSR.W	#$1,D7			; CHECK_ODD:
	;BCC.S	.odd
	;
	;BRA.S	.done
	;.odd:
	;
	;.done:

	;*--- main loop end ---*
	;ENDING_CODE:
	BTST	#6,$BFE001
	BNE.S	.DontShowRasterTime

	BSR.W	__BLK_JMP

	.DontShowRasterTime:
	BTST	#2,$DFF016	; POTINP - RMB pressed?
	BNE.W	MainLoop		; then loop
	;*--- exit ---*
	;;    ---  Call P61_End  ---
	MOVEM.L D0-A6,-(SP)
	JSR P61_End
	MOVEM.L (SP)+,D0-A6
	RTS

;********** Demo Routines **********
PokePtrs:				; SUPER SHRINKED REFACTOR
	MOVE.L	A0,-4(A0)		; Needs EMPTY plane to write addr
	MOVE.W	-4(A0),2(A1)	; high word of address
	MOVE.W	-2(A0),6(A1)	; low word of address
	;CLR.L	-4(A0)
	RTS

ClearScreen:			; a1=screen destination address to clear
	bsr	WaitBlitter
	clr.w	$66(a6)		; destination modulo
	move.l	#$01000000,$40(a6)	; set operation type in BLTCON0/1
	move.l	a1,$54(a6)	; destination address
	move.l	#blitsize*bpls,$58(a6)	;blitter operation size
	rts

VBint:				; Blank template VERTB interrupt
	movem.l	d0/a6,-(sp)	; Save used registers
	lea	$dff000,a6
	btst	#5,$1f(a6)	; check if it's our vertb int.
	beq.s	.notvb
	;*--- do stuff here ---*
	moveq	#$20,d0		; poll irq bit
	move.w	d0,$9c(a6)
	move.w	d0,$9c(a6)
	.notvb:	
	movem.l	(sp)+,d0/a6	; restore
	rte

__SWAP_ODD_EVEN_PTRS:
	LEA	COPPER\.Waits+6,A0
	LEA	12(A0),A1
	MOVE.W	(A0),(A1)
	MOVE.W	4(A1),(A0)
	MOVE.W	4(A1),4(A0)
	MOVE.W	(A1),4(A1)
	RTS

__SPLIT_COPPER_HALF:
	LEA	COPPER\.Waits+6,A0
	MOVE.W	#0,(A0)
	MOVE.W	#0,4(A0)
	MOVE.W	#-80,12(A0)
	MOVE.W	#-80,16(A0)
	RTS

__SPLIT_COPPER_QUARTER:
	LEA	COPPER\.Waits+6,A0
	MOVE.W	#-80,(A0)
	MOVE.W	#-80,4(A0)
	MOVE.W	#0,12(A0)
	MOVE.W	#0,16(A0)
	RTS

__SET_PT_VISUALS:
	; ## SONG POS RESETS ##
	;MOVE.W	P61_Pos,D7
	;MOVE.W	P61_DUMMY_POS,D5
	;CMP.W	D5,D7
	;BEQ.S	.dontReset
	;ADDQ.W	#$1,P61_DUMMY_POS
	;ADDQ.W	#$1,P61_LAST_POS
	;;ADD.W	#$0,P61_ROW_INDEX
	.dontReset:
	; ## SONG POS RESETS ##

	; ## STEP SEQUENCER ##
	MOVE.W	P61_rowpos,D7
	CMP.W	P61_DUMMY_SEQPOS,D7
	BEQ.S	.dontResetRowPos
	MOVE.W	D7,P61_DUMMY_SEQPOS
	MOVE.W	P61_SEQ_POS,D0
	ADDQ.W	#$1,D0
	AND.W	#$20,D0
	MOVE.W	D0,P61_SEQ_POS
	MOVE.W	P61_ROW_INDEX,D0
	ADDQ.W	#$1,D0
	AND.W	#$20,D0
	MOVE.W	D0,P61_ROW_INDEX
	.dontResetRowPos:
	SUBI.W	#63,D7		; NORMALIZE LIVE VALUE
	NEG.W	D7		; NOW D7 CONTAINS BLOCK ROW
	; ## STEP SEQUENCER ##

	MOVE.W	P61_CH0_INS,D0	; NEW VALUES FROM P61
	MOVE.W	P61_CH1_INS,D1	; NEW VALUES FROM P61
	MOVE.W	P61_CH2_INS,D2	; NEW VALUES FROM P61
	MOVE.W	P61_CH3_INS,D3	; NEW VALUES FROM P61

	TST.W	D7
	;BNE.S	.skip0
	;CLR.W	$100		; DEBUG | w 0 100 2
	.skip0:

	; ## MOD VISUALIZERS ##########
	LEA	P61_visuctr0(PC),A0	; which channel? 0-3
	MOVEQ	#$F,D0		; maxvalue
	SUB.W	(A0),D0		; -#frames/irqs since instrument trigger
	BPL.S	.ok0		; below minvalue?
	MOVEQ	#$0,D0		; then set to minvalue
	.ok0:
	MOVE.W	D0,AUDIOCHLEVEL0
	
	LEA	P61_visuctr1(PC),A0	; which channel? 0-3
	MOVEQ	#$F,D0		; maxvalue
	SUB.W	(A0),D0		; -#frames/irqs since instrument trigger
	BPL.S	.ok1		; below minvalue?
	MOVEQ	#$0,D0		; then set to minvalue
	.ok1:
	MOVE.W	D0,AUDIOCHLEVEL1

	LEA	P61_visuctr2(PC),A0	; which channel? 0-3
	MOVEQ	#$F,D0		; maxvalue
	SUB.W	(A0),D0		; -#frames/irqs since instrument trigger
	BPL.S	.ok2		; below minvalue?
	MOVEQ	#$0,D0		; then set to minvalue
	.ok2:
	MOVE.W	D0,AUDIOCHLEVEL2

	LEA	P61_visuctr3(PC),A0	; which channel? 0-3
	MOVEQ	#$F,D0		; maxvalue
	SUB.W	(A0),D0		; -#frames/irqs since instrument trigger
	BPL.S	.ok3		; below minvalue?
	MOVEQ	#$0,D0		; then set to minvalue
	.ok3:
	MOVE.W	D0,AUDIOCHLEVEL3
	; MOD VISUALIZERS *****

	;MOVE.W	P61_LAST_POS,D1
	;CMPI.W	#76,D1		; STOP AT END OF MUSIC
	;BNE.S	.dontStopMusic
	;MOVEM.L	D0-A6,-(SP)
	;JSR	P61_End
	;MOVEM.L	(SP)+,D0-A6
	;MOVE.W	#0,P61_DUMMY_POS
	;SUBI.W	#1,P61_LAST_POS
	.dontStopMusic:
	RTS

__BLK_JMP:
	;* Input:	D0.b=songposition. A6=your custombase ("$dff000")
	CLR.L	D0
	MOVE.B	#22,D0
	;MOVE.W	D0,P61_DUMMY_POS
	;MOVE.W	D0,P61_LAST_POS
	LEA	$DFF000,A6
	JSR	P61_SetPosition
	SUB.W	#1,P61_Pos
	RTS

__POKE_SPRITE_POINTERS:
	LEA	COPPER\.SpritePointers,A1
	MOVE.L	#SPRT_D,D0
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_E,D0
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_S,D0
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_E2,D0
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_I,D0
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_R,D0
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT__,D0
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)
	RTS

__DITHER_PLANE:
	;MOVE.L	A4,A4
	;MOVE.W	#he-1,D4		; QUANTE LINEE
	;MOVE.L	#$AAAAAAAA,D5
	;.outerloop:		; NUOVA RIGA
	;MOVE.W	#(bypl/4)-1,D6	; RESET D6
	;NOT.L	D5
	;.innerloop:		; LOOP KE CICLA LA BITMAP
	;MOVE.W	$DFF006,$DFF180	; SHOW ACTIVITY :)
	;MOVE.L	D5,(A4)+
	;DBRA	D6,.innerloop
	;TST.W	D0
	;BEQ.S	.noWait
	;BSR.W	WaitEOF		; TO SLOW DOWN :)
	;.noWait:
	;DBRA	D4,.outerloop
	;RTS

__MIRROR_PLANE:
	LEA	40(A4),A5
	MOVE.W	#TEXTURE_H*bpls-1,D4 ; QUANTE LINEE
	.outerloop:		; NUOVA RIGA
	MOVE.W	#(bypl/2)-1,D6
	.innerloop:
	;MOVE.W	$DFF006,$DFF180	; SHOW ACTIVITY :)
	MOVE.B	(A3)+,D5

	MOVE.B	D5,D0
	REPT 8
	ROXR.B	#1,D0		; FLIP BITS
	ROXL.B	#1,D2		; FLIP BITS
	ENDR
	MOVE.B	D2,-(A5)		; BOTTOM RIGHT
	DBRA	D6,.innerloop
	ADD.L	#(bypl/2),A3
	ADD.L	#(bypl/2)*3,A5
	DBRA	D4,.outerloop
	RTS

__FILL_MIRROR_TEXTURE:
	MOVE.W	#TEXTURE_H*bpls-1,D4 ; QUANTE LINEE
	.outerloop:		; NUOVA RIGA
	MOVE.W	#(bypl/4)-1,D6	; RESET D6
	.innerloop:		; LOOP KE CICLA LA BITMAP
	;MOVE.W	$DFF006,$DFF180	; SHOW ACTIVITY :)

	CLR.L	D5
	MOVE.L	(A3),D5
	SWAP	D5		; SHIFT TO MIDDLE OF PIXEL
	ROR.L	#$4,D5		; SHIFT TO MIDDLE OF PIXEL
	SWAP	D5		; SHIFT TO MIDDLE OF PIXEL
	MOVE.W	D5,(A3)+
	DBRA	D6,.innerloop
	LEA	20(A3),A3
	DBRA	D4,.outerloop
	RTS

__EXPAND_PIXELS:
	MOVE.L	#$AAAAAAAA,D2
	MOVE.W	#TEXTURE_H/8*bpls-1,D7 ; 40 WORDS, 20PX, xBPL
	.outerloop:		; NUOVA RIGA
	;MOVE.W	$DFF006,$DFF180	; SHOW ACTIVITY :)
	;BSR.W	WaitEOF		; TO SLOW DOWN :)

	CLR.L	D0
	MOVE.W	(A3),D0		; FIRST 16 PIXEL
	SWAP	D0
	MOVE.B	2(A3),D0		; OTHER 4= PIXEL
	LSR.B	#$4,D0		; ALIGN WITH OTHER BITS
	SWAP	D0
	ADD.L	#$4,A3		; NEXT LINE. EACH LINE 20 + PADDING

	;BTST	#$0,D0
	;BNE.S	.dontDither
	;OR.W	D2,D0
	;ROL.L	#$1,D0
	.dontDither:
	OR.L	D2,D0		; COMBINE TEXTURE WITH MOCKED BITS
	;AND.L	D2,D0		; COMBINE TEXTURE WITH MOCKED BITS

	MOVEQ	#$A,D4		; 20 PIXEL, 2 BITS AT THE TIME = 10
	.lineLoop:
	CLR.W	D1		; EXPAND LINE
	BTST	#$1,D0		; SECOND BIT SET?
	BNE.S	.not1
	MOVE.B	#-1,D1
	.not1:
	ROL.W	#$8,D1
	BTST	#$0,D0		; FIRST BIT SET?
	BNE.S	.not0
	MOVE.B	#-1,D1
	.not0:			; D1 NOW CONTAINS FIRST TWO PIXELS EXPANDED

	MOVE.W	D1,40(A4)		; AND WE PUT IT AS WORD ON DEST
	MOVE.W	D1,80(A4)		; AND WE PUT IT AS WORD ON DEST
	MOVE.W	D1,120(A4)	; AND WE PUT IT AS WORD ON DEST
	MOVE.W	D1,160(A4)	; AND WE PUT IT AS WORD ON DEST
	MOVE.W	D1,200(A4)	; AND WE PUT IT AS WORD ON DEST
	MOVE.W	D1,240(A4)	; AND WE PUT IT AS WORD ON DEST
	MOVE.W	D1,280(A4)	; AND WE PUT IT AS WORD ON DEST
	MOVE.W	D1,(A4)+		; AND WE PUT IT AS WORD ON DEST
	ROR.L	#$2,D0		; NEXT TWO PIXELS
	ROR.L	#$2,D2		; MOCK
	DBRA	D4,.lineLoop

	ROR.L	#$1,D2		; NEXT TWO PIXELS
	;NOT	D2
	SWAP	D2

	LEA	18(A4),A4
	LEA	280(A4),A4
	DBRA	D7,.outerloop
	RTS

__BLIT_TEXTURE_BAND:
	MOVE.L	(A5),D0			; A5 PRELOADED WITH RESET ADDRESS
	MOVE.L	4(A5),A3			; NEXT LONG CONTAINS ACTUALE POINTER
	SUB.L	#(TEXTURE_H)*bypl,D0	; OFFSET FOR TEXTURE END
	CMP.L	D0,A3
	BHI.S	.notEnd
	MOVE.L	(A5),A3			; RELOAD RESET ADDRESS
	.notEnd:

	_WaitBlitterNasty			; MACRO IS FASTER
	MOVE.L	D4,BLTCON0		; BLTCON0
	MOVE.L	D5,BLTAFWM		; THEY'LL NEVER
	MOVE.L	D6,BLTAMOD		; BLTAMOD

	MOVE.L	A3,BLTAPTH		; BLTAPT
	MOVE.L	A4,BLTDPTH
	MOVE.W	#16*64+wi/16,BLTSIZE	; BLTSIZE

	MOVE.W	Y_HALF_SHIFT,D1
	;MULU.W	#bypl,D1
	LEA	BPL_PRECALC,A0
	ADD.W	D1,D1
	MOVE.W	(A0,D1.W),D1
	SUB.W	D1,A3
	;LEA	-40(A3),A3		; OPTIMIZED
	MOVE.L	A3,4(A5)			; REMEMBER POSITION
	RTS

__SCROLL_X_1_4_BIS:
	MOVE.W	#%1001111100000000,D2
	MOVE.B	D4,D2
	ROR.W	#$4,D2
	SWAP	D2

	MOVE.W	#$0,D2
	BTST	#$0,D5			; 1=DESC 0=NOT
	BEQ.B	.notDesc
	; ## MAIN BLIT ####
	BSET	#$1,D2			; BLTCON1 BIT 12 DESC MODE
	ADD.W	D6,A5
	MOVE.W	-18(A5),D7		; PATCH LOST WORD
	BRA.S	.skip
	.notDesc:
	LEA	-16(A5),A5
	MOVE.W	18(A5),D7			; PATCH LOST WORD
	.skip:

	MOVE.W	#$8400,DMACON		; BLIT NASTY ENABLE
	MOVE.W	#$400,DMACON		; BLIT NASTY DISABLE
	MOVE.L	D1,BLTAFWM		; THEY'LL NEVER

	MOVE.L	D2,BLTCON0		; BLTCON0
	;MOVE.W	D2,BLTCON1
	MOVE.L	#((bypl/2)<<16)+bypl/2,BLTAMOD ; BLTAMOD
	MOVE.L	A5,BLTAPTH		; BLTAPT
	MOVE.L	A5,BLTDPTH
	MOVE.W	#(X_SLICE)*64+(wi/2/16),BLTSIZE ; BLTSIZE

	BSR	WaitBlitter
	MOVE.W	D7,(A5)			; PATCH LOST WORD
	; ## MAIN BLIT ####
	RTS

__SCROLL_Y_HALF:
	MOVE.W	A6,D2
	;MULU.W	#bypl,D2
	LEA	BPL_PRECALC,A0
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2

	; ## MAIN BLIT ####
	ADD.W	D2,A3			; POSITION Y

	TST.W	D0			; IF LAST COLS COMBINE THEM
	BNE.S	.notLast
	BTST	#$0,D5
	BEQ.B	.skip
	.notLast:

	MOVE.W	#$8400,DMACON		; BLIT NASTY ENABLE
	MOVE.W	#$400,DMACON		; BLIT NASTY DISABLE

	MOVE.L	D1,BLTAFWM		; THEY'LL NEVER
	MOVE.L	#$09F00000,BLTCON0
	;MOVE.W	#%0000100111110000,BLTCON0
	;MOVE.W	#%0000000000000000,BLTCON1	; BLTCON1

	MOVE.L	A3,BLTAPTH		; BLTAPT SRC
	MOVE.L	A4,BLTDPTH		; DEST

	TST.W	D0			; IF LAST COLS COMBINE THEM
	BNE.S	.blitSingleColumn
	MOVE.L	#((bypl-Y_SLICE*2/16*2)<<16)+bypl-Y_SLICE*2/16*2,BLTAMOD	; BLTAMOD
	;MOVE.W	#bypl-Y_SLICE*2/16*2,BLTDMOD	; BLTDMOD
	MOVE.W	#(he/2+16)*(bpls+1)*64+(Y_SLICE*2/16),BLTSIZE		; BLTSIZE	DOUBLE
	BRA.S	.skip
	.blitSingleColumn:
	MOVE.L	#((bypl-Y_SLICE/16*2)<<16)+bypl-Y_SLICE/16*2,BLTAMOD	; BLTAMOD
	;MOVE.W	#bypl-Y_SLICE/16*2,BLTDMOD	; BLTDMOD
	MOVE.W	#(he/2+16)*(bpls+1)*64+(Y_SLICE/16),BLTSIZE		; BLTSIZE	SINGLE
	.skip:
	; ## MAIN BLIT ####
	RTS

__LFO_EASYING:
	MOVE.W	-2(A0),D0
	MOVE.W	(A0,D0.W),D1
	MOVE.W	D1,128(A0)
	ADDQ.W	#$2,D0
	AND.W	#$7F,D0
	MOVE.W	D0,-2(A0)

	;TST.W	D0
	;BEQ.S	__X_LFO_EASYING2
	RTS

__DO_HORIZ_TEXTURE:
	;## HORIZ TEXTURE ##############
	;MOVE.W	#16*64+wi/16,BLIT_SIZE
	MOVE.L	#$9F00000,D4
	;MOVE.W	#%0000100111110000,BLTCON0	; BLTCON0
	;MOVE.W	#%0000000000000000,BLTCON1	; BLTCON1 BIT 12 DESC MODE
	MOVE.L	#-1,D5
	CLR.L	D6
	LEA	BLEEDBOTTOM0,A4
	;ADD.L	#bypl*16,A4
	LEA	TEXTURERESET5,A5
	BSR.W	__BLIT_TEXTURE_BAND
	;## HORIZ TEXTURE ##############
	;MOVE.W	#16*64+wi/16,BLIT_SIZE
	;MOVE.W	Y_EASYING,Y_HALF_SHIFT
	;MOVE.L	#0,BLIT_A_MOD
	LEA	BLEEDBOTTOM1,A4
	;ADD.L	#bypl*16,A4
	LEA	TEXTURERESET6,A5
	BSR.W	__BLIT_TEXTURE_BAND
	;## HORIZ TEXTURE ##############
	;MOVE.W	#16*64+wi/16,BLIT_SIZE
	;MOVE.W	Y_EASYING,Y_HALF_SHIFT
	;MOVE.L	#0,BLIT_A_MOD
	LEA	BLEEDBOTTOM2,A4
	;ADD.L	#bypl*16,A4
	LEA	TEXTURERESET7,A5
	BSR.W	__BLIT_TEXTURE_BAND
	;## HORIZ TEXTURE ##############
	RTS

__BLK_2:
	LEA	Y_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
__BLK_0:
	CMPI.W	#28,D7			; WORKS STRAIGHT!
	BLO.S	.Skip
	LEA	Z_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	MOVE.W	D1,X_EASYING
	MOVE.W	D1,Y_HALF_SHIFT		; CFG
	LSL.W	#$4,D1
	_PushColorsDOWN	BLUE_TBL,D1
	BRA.S	.Dont
	.Skip:
	MOVE.W	#$0,Z_EASYING_IDX
	.Dont:

	BSR.S	__DO_HORIZ_TEXTURE

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1
	MOVE.W	#$0,X_INCREMENT
	MOVE.W	#$0,Y_INCREMENT
	MOVE.W	#$1,X_EASYING
	MOVE.W	#$2,Y_EASYING

	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_1
	;#################################

	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################
	MOVE.W	#$2,Y_HALF_SHIFT		; CFG
	RTS

__BLK_1:
	CMPI.W	#28,D7			; WORKS STRAIGHT!
	BLO.S	.Dont
	.full:
	LEA	Z_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	MOVE.W	D1,Y_HALF_SHIFT		; CFG
	LSL.W	#$4,D1
	_PushColorsDOWN	BLUE_TBL,D1

	LEA	X_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	LSR.W	D1
	ADD.W	#$2,D1
	MOVE.W	D1,X_EASYING
	LEA	Y_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	LSR.W	D1
	MOVE.W	D1,Y_EASYING
	BRA.S	.Dont2
	.Dont:

	MOVE.W	#$0,Y_EASYING_IDX
	MOVE.W	#$A,X_EASYING_IDX
	MOVE.W	#$1,X_EASYING
	MOVE.W	#$2,Y_EASYING
	BSR.W	__DO_HORIZ_TEXTURE
	.Dont2:

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1
	MOVE.W	#$0,X_INCREMENT
	MOVE.W	#$0,Y_INCREMENT

	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_1
	;#################################

	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################
	MOVE.W	#$2,Y_HALF_SHIFT		; CFG
	RTS

__BLK_3:
	MOVE.W	#$2,Y_HALF_SHIFT		; CFG
	BSR.W	__DO_HORIZ_TEXTURE
	MOVE.W	#$1,X_INCREMENT
	BRA.W	__BLK_1\.full

__BLK_4:
	MOVE.W	#$2,Y_HALF_SHIFT		; CFG
	BSR.W	__DO_HORIZ_TEXTURE

	LEA	Z_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	CMPI.W	#32,D7			; WORKS STRAIGHT!
	BLO.S	.Dont
	LSL.W	#$4,D1
	_PushColorsDOWN	PURPL_TBL,D1
	LEA	Y_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	BSR.W	__SPLIT_COPPER_QUARTER
	BRA.S	.Dont2
	.Dont:
	LSL.W	#$4,D1
	_PushColorsDOWN	BLUE_TBL,D1
	MOVE.W	Z_EASYING_IDX,Y_EASYING_IDX
	LEA	Y_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	LSR.W	D1
	MOVE.W	D1,Y_EASYING
	.Dont2:

	LEA	X_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	LSR.W	D1
	ADD.W	#$2,D1
	MOVE.W	D1,X_EASYING

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1
	MOVE.W	#$0,X_INCREMENT
	MOVE.W	#$0,Y_INCREMENT

	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_1
	;#################################

	;CMPI.W	#60,D7			; D7 SHOULD STILL HOLD P61_rowpos !
	;BGE.S	.DontDo2
	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################
	RTS

__BLK_5:
	TST.W	D7
	BNE.S	.noColorReset
	_PushColorsDOWN	MAIN_TBL,#$0
	BSR.W	__SPLIT_COPPER_HALF
	.noColorReset:
	MOVE.W	#$1,X_EASYING
	MOVE.W	#$1,Y_EASYING
	MOVE.W	Y_EASYING,Y_HALF_SHIFT
	BSR.W	__DO_HORIZ_TEXTURE

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1

	MOVE.W	#$0,X_INCREMENT
	MOVE.W	#$1,Y_INCREMENT
	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	MOVE.W	P61_CH2_INS,D7		; NEW VALUES FROM P61

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3

	;CMP.B	#$12,D7
	;BEQ.S	.DontDo3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_1
	;MOVE.W	#$0,X_EASYING_IDX
	;#################################
	;.DontDo3:

	CMP.B	#$11,D7
	BEQ.S	.DontDo1
	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################
	;MOVE.W	#$0,X_EASYING_IDX
	.DontDo1:

	;LEA	X_EASYING_TBL,A0
	;BSR.W	__LFO_EASYING
	.DontDo2:
	RTS

__BLK_6:
	TST.W	D7
	BNE.S	.noColorReset
	_PushColorsUP	MAIN_TBL,#$0
	BSR.W	__SPLIT_COPPER_HALF
	.noColorReset:
	MOVE.W	#$1,X_EASYING
	MOVE.W	#$1,Y_EASYING
	;MOVE.W	Y_EASYING,Y_HALF_SHIFT
	BSR.W	__DO_HORIZ_TEXTURE

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1

	MOVE.W	#$0,X_INCREMENT
	MOVE.W	#$1,Y_INCREMENT
	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	MOVE.W	P61_CH2_INS,D7		; NEW VALUES FROM P61

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3

	CMP.B	#$12,D7
	BEQ.S	.DontDo3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_1
	;MOVE.W	#$0,X_EASYING_IDX
	;#################################
	.DontDo3:

	CMP.B	#$10,D7
	BEQ.S	.DontDo1
	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################
	MOVE.W	#$0,Y_EASYING_IDX
	MOVE.W	#$4,X_EASYING_IDX
	.DontDo1:

	;LEA	X_EASYING_TBL,A0
	;BSR.W	__LFO_EASYING
	.DontDo2:
	RTS

__BLK_7:
	TST.W	D7
	BNE.S	.noColorReset
	_PushColorsDOWN	PURPL_TBL,#$0
	BSR.W	__SPLIT_COPPER_HALF
	.noColorReset:

	TST.W	P61_visuctr0
	BNE.S	.noTexture
	MOVE.W	#$1,Y_HALF_SHIFT	; CFG
	BSR.W	__DO_HORIZ_TEXTURE
	.noTexture:

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1
	MOVE.W	#$0,X_INCREMENT
	MOVE.W	#$0,Y_INCREMENT

	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_1
	;#################################

	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################

	;## LONG LFO ##
	MOVE.B	DUMMY_FRAME_COUNT,D7
	TST.B	D7
	BNE.S	.skip
	LEA	Y_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	LEA	X_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	.skip:
	ADD.B	#$1,D7
	AND.B	#$3F,D7
	MOVE.B	D7,DUMMY_FRAME_COUNT
	RTS

__BLK_8:
	CMPI.W	#32,D7			; WORKS STRAIGHT!
	BNE.S	.Dont
	_PushColorsDOWN	MAIN_TBL,#$0
	MOVE.W	#$2,X_EASYING
	MOVE.W	#$3,Y_EASYING
	MOVE.W	#$1,X_INCREMENT
	.Dont:
	
	TST.W	P61_visuctr0
	BNE.S	.noTexture
	MOVE.W	#$F,Y_HALF_SHIFT		; CFG
	BSR.W	__DO_HORIZ_TEXTURE
	.noTexture:

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1
	;MOVE.W	#$0,X_INCREMENT
	MOVE.W	#$0,Y_INCREMENT

	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_1
	;#################################

	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################

	;## LONG LFO ##
	TST.W	D7
	BNE.S	.skip
	MOVE.W	#$40,Y_EASYING_IDX
	MOVE.W	#$2,X_EASYING_IDX
	.skip:
	RTS

__BLK_9:
	TST.W	D7
	BNE.S	.noCopperChange
	BSR.W	__SPLIT_COPPER_QUARTER
	.noCopperChange:

	TST.W	AUDIOCHLEVEL2
	BEQ.S	.Dont2
	MOVE.W	Y_EASYING,Y_HALF_SHIFT	; CFG
	BSR.W	__DO_HORIZ_TEXTURE
	MOVE.W	#$0,X_INCREMENT
	.Dont2:
	
	TST.W	P61_visuctr0
	BEQ.S	.Dont0
	LEA	Y_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	MOVE.W	#$1,X_INCREMENT
	.Dont0:
	
	TST.W	P61_visuctr3
	BEQ.S	.Dont1
	LEA	X_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	MOVE.W	#$0,X_INCREMENT
	.Dont1:

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1
	;MOVE.W	#$1,X_INCREMENT
	MOVE.W	#$1,Y_INCREMENT

	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_1
	;#################################

	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################

	;ADD.W	D7,D7
	;MOVE.W	D7,Y_EASYING_IDX
	;LEA	Y_EASYING_TBL,A0
	;BSR.W	__LFO_EASYING
	;LEA	X_EASYING_TBL,A0
	;BSR.W	__LFO_EASYING
	RTS

__BLK_A:
	MOVE.W	P61_CH0_INS,D1		; NEW VALUES FROM P61
	CMP.B	#$17,D1
	BNE.S	.noTexture
	;MOVE.W	#$2,Y_HALF_SHIFT
	;BSR.W	__DO_HORIZ_TEXTURE
	MOVE.W	#$0,X_EASYING_IDX
	MOVE.W	#$2,Y_EASYING_IDX
	.noTexture:

	TST.W	D7
	BNE.S	.noColorReset
	_PushColorsDOWN	MIXED_TBL,#$0
	BSR.W	__SPLIT_COPPER_QUARTER
	.noColorReset:

	LEA	X_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	LEA	Y_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	LSR.W	D1
	MOVE.W	D1,Y_EASYING

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1

	MOVE.W	#$0,X_INCREMENT
	MOVE.W	#$0,Y_INCREMENT
	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3
	MOVE.W	#$1,Y_INCREMENT
	ANDI.B	#$1,D7
	;## PERFORM ######################
	BEQ.W	__DO_PLANE_1		; IF THE RESULT WAS ZERO, THE Z FLAG IS SET, AND BEQ JUMPS.
	;## SETTINGS #####################

	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################
	MOVE.W	#$C,X_EASYING_IDX
	RTS

__BLK_B:
	TST.W	D7
	BNE.S	.noColorReset
	_PushColorsDOWN	MAIN_TBL,#$0
	.noColorReset:

	ADD.W	D7,D7
	MOVE.W	D7,Y_EASYING_IDX

	MOVE.W	P61_CH3_INS,D1		; NEW VALUES FROM P61
	MOVE.W	D1,P61_CH2_INS
	CMP.B	#$10,D1
	BEQ.W	__BLK_A_BIS
	CMP.B	#$11,D1
	BEQ.W	__BLK_7\.noColorReset
	CMP.B	#$12,D1
	BEQ.W	__BLK_9
	RTS

__BLK_A_BIS:
	LEA	X_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	LEA	Y_EASYING_TBL,A0
	BSR.W	__LFO_EASYING
	LSR.W	D1
	MOVE.W	D1,Y_EASYING

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1

	MOVE.W	#$0,X_INCREMENT
	MOVE.W	#$0,Y_INCREMENT
	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3
	MOVE.W	#$1,Y_INCREMENT
	ANDI.B	#$1,D7
	;## PERFORM ######################
	BEQ.W	__DO_PLANE_1		; IF THE RESULT WAS ZERO, THE Z FLAG IS SET, AND BEQ JUMPS.
	;## SETTINGS #####################

	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################
	MOVE.W	#$C,X_EASYING_IDX
	RTS

__BLK_TEST:
	MOVE.W	Y_EASYING,Y_HALF_SHIFT	; CFG
	BSR.W	__DO_HORIZ_TEXTURE

	;## SETTINGS #####################
	MOVE.W	#(X_SLICE)*bypl,D3
	SWAP	D3
	MOVE.W	#(Y_SLICE)/16*2,D3
	MOVE.W	#bypl*(X_SLICE)+(bypl/2)-2,D6	; OPTIMIZE
	BSET	#$1,D5			; BIT 1=BLIT_COLUMN	- BLIT VERTICALLY ALL PLANES
	MOVE.L	#-1,D1
	MOVE.W	#$0,X_INCREMENT
	MOVE.W	#$0,Y_INCREMENT
	MOVE.W	#$1,X_EASYING
	MOVE.W	#$1,Y_EASYING

	;## PERFORM ######################
	BSR.W	__DO_PLANE_0
	;#################################

	;## SETTINGS #####################
	BCLR	#$1,D5			; NO BIT 1 = DONT BLIT VERTICALLY
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_1
	;#################################

	;## SETTINGS #####################
	NEG.W	D3
	;## PERFORM ######################
	BSR.W	__DO_PLANE_2
	;#################################

	;CMPI.W	#16,D7		; WORKS STRAIGHT!
	;BNE.S	.Skip
	;LEA	TEXTURERESET6,A0
	;MOVE.L	(A0),4(A0)
	;.Skip:
	;CMPI.W	#17,D7		; WORKS STRAIGHT!
	;BNE.S	.Skip2
	;LEA	TEXTURERESET7,A0
	;MOVE.L	(A0),4(A0)
	;.Skip2:
	;CMPI.W	#19,D7		; WORKS STRAIGHT!
	;BNE.S	.Skip3
	;LEA	TEXTURERESET5,A0
	;MOVE.L	(A0),4(A0)
	;.Skip3:
	RTS

__DO_PLANE_0:
	LEA	BGPLANE0,A3
	MOVE.L	A3,A4
	BSET	#$0,D5			; BIT 0 1=DESC 0=NOT
	BSR.W	__SCROLL_COMBINED
	; ## RIGHT ##
	NEG.W	D3
	LEA	BGPLANE0+36,A3
	MOVE.L	A3,A4
	BCLR	#$0,D5			; 1=DESC 0=NOT
	BSR.S	__SCROLL_COMBINED
	RTS

__DO_PLANE_1:
	LEA	BGPLANE1,A3
	MOVE.L	A3,A4
	BSET	#$0,D5			; 1=DESC 0=NOT
	BSR.S	__SCROLL_COMBINED

	NEG.W	D3
	LEA	BGPLANE1+36,A3
	MOVE.L	A3,A4
	BCLR	#$0,D5			; 1=DESC 0=NOT
	BSR.S	__SCROLL_COMBINED
	RTS

__DO_PLANE_2:
	LEA	BGPLANE2,A3
	MOVE.L	A3,A4
	BSET	#$0,D5			; 1=DESC 0=NOT
	BSR.S	__SCROLL_COMBINED

	NEG.W	D3
	LEA	BGPLANE2+36,A3
	MOVE.L	A3,A4
	BCLR	#$0,D5			; 1=DESC 0=NOT
	BSR.S	__SCROLL_COMBINED
	RTS

__SCROLL_COMBINED:
	MOVE.L	A3,A1
	MOVE.W	Y_EASYING,A6		; OPTMIZIZE TRICK :)
	MOVE.W	X_EASYING,D4
	;SUB.W	#$1,D4
	;AND.W	#$F,D4			; NOT TOO FAST! :)

	MOVEQ	#$5-1,D0
	.loop:
	BTST	#$1,D5
	BEQ.W	.skip

	;BSR.W	__SCROLL_Y_HALF
	;__SCROLL_Y_HALF: #################################################
	MOVE.W	A6,D2
	;MULU.W	#bypl,D2
	LEA	BPL_PRECALC,A0
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2

	ADD.W	D2,A3			; POSITION Y

	TST.W	D0			; IF LAST COLS COMBINE THEM
	BNE.S	.notLast
	BTST	#$0,D5
	BEQ.B	.skip3
	.notLast:

	_WaitBlitterNasty			; MACRO IS FASTER
	;## MAIN BLIT ####
	MOVE.L	D1,BLTAFWM		; THEY'LL NEVER
	MOVE.L	#$09F00000,BLTCON0
	;MOVE.W	#%0000100111110000,BLTCON0
	;MOVE.W	#%0000000000000000,BLTCON1	; BLTCON1

	MOVE.L	A3,BLTAPTH		; BLTAPT SRC
	MOVE.L	A4,BLTDPTH		; DEST

	TST.W	D0			; IF LAST COLS COMBINE THEM
	BNE.S	.blitSingleColumn
	MOVE.L	#((bypl-Y_SLICE*2/16*2)<<16)+bypl-Y_SLICE*2/16*2,BLTAMOD	; BLTAMOD
	;MOVE.W	#bypl-Y_SLICE*2/16*2,BLTDMOD	; BLTDMOD
	MOVE.W	#(he/2+16)*(bpls)*64+(Y_SLICE*2/16),BLTSIZE		; BLTSIZE	DOUBLE
	BRA.S	.skip3
	.blitSingleColumn:
	MOVE.L	#((bypl-Y_SLICE/16*2)<<16)+bypl-Y_SLICE/16*2,BLTAMOD	; BLTAMOD
	;MOVE.W	#bypl-Y_SLICE/16*2,BLTDMOD	; BLTDMOD
	MOVE.W	#(he/2+16)*(bpls)*64+(Y_SLICE/16),BLTSIZE		; BLTSIZE	SINGLE
	.skip3:
	;## MAIN BLIT ####
	;END __SCROLL_Y_HALF: #############################################

	SUB.W	D2,A3			; D2 COMES FROM SUBROUTINE
	SUB.W	Y_INCREMENT,A6
	CMP.W	#$0,A6
	BNE.S	.skip
	MOVE.W	#$1,A6
	.skip:

	;## NEW H BLIT ######
	MOVE.L	A1,A5

	;BSR.W	__SCROLL_X_1_4_BIS
	;__SCROLL_X_1_4_BIS: ##############################################
	TST.W	D4
	BEQ.S	.skipHorizSlice
	MOVE.W	#(%0000100111110000)<<4,D2
	MOVE.B	D4,D2
	ROR.W	#$4,D2
	SWAP	D2

	MOVE.W	#$0,D2
	BTST	#$0,D5			; 1=DESC 0=NOT
	BEQ.B	.notDesc
	;## MAIN BLIT ####
	BSET	#$1,D2			; BLTCON1 BIT 12 DESC MODE
	ADD.W	D6,A5
	;MOVE.W	-18(A5),D7		; PATCH LOST WORD
	BRA.S	.skip2
	.notDesc:
	LEA	-16(A5),A5
	;MOVE.W	18(A5),D7			; PATCH LOST WORD
	.skip2:

	_WaitBlitterNasty			; MACRO IS FASTER
	MOVE.L	D1,BLTAFWM		; THEY'LL NEVER
	MOVE.L	D2,BLTCON0		; BLTCON0
	;MOVE.W	D2,BLTCON1
	MOVE.L	#((bypl/2)<<16)+bypl/2,BLTAMOD ; BLTAMOD
	MOVE.L	A5,BLTAPTH		; BLTAPT
	MOVE.L	A5,BLTDPTH
	MOVE.W	#(X_SLICE)*64+(wi/2/16),BLTSIZE ; BLTSIZE
	;## MAIN BLIT ####
	ADD.W	X_INCREMENT,D4		; INCREMENT AT EACH SLICE
	;BSR	WaitBlitter
	;MOVE.W	D7,(A5)			; PATCH LOST WORD

	.skipHorizSlice:
	;END ;__SCROLL_X_1_4_BIS: #########################################
	SWAP	D3
	ADD.W	D3,A1
	SWAP	D3
	;## NEW H BLIT ######
	ADD.W	D3,A3
	ADD.W	D3,A4
	DBRA	D0,.loop
	RTS

__BLK_END:
	RTS

;********** Fastmem Data **********
TIMELINE:		DC.L __BLK_0,__BLK_0,__BLK_1,__BLK_3
		DC.L __BLK_0,__BLK_1,__BLK_0,__BLK_4
		DC.L __BLK_5,__BLK_5,__BLK_6,__BLK_6
		DC.L __BLK_7,__BLK_7,__BLK_7,__BLK_8
		DC.L __BLK_9,__BLK_9,__BLK_9,__BLK_9
		DC.L __BLK_9,__BLK_9,__BLK_9,__BLK_9\.Dont0
		DC.L __BLK_A\.noTexture,__BLK_A,__BLK_A,__BLK_A
		DC.L __BLK_B,__BLK_B,__BLK_B,__BLK_B
		DC.L __BLK_1,__BLK_1,__BLK_1,__BLK_1
		DC.L __BLK_A,__BLK_A,__BLK_A,__BLK_A
		DC.L __BLK_A,__BLK_A,__BLK_A,__BLK_A
		DC.L __BLK_5,__BLK_5,__BLK_6,__BLK_6
		DC.L __BLK_5,__BLK_5,__BLK_6,__BLK_6

BPL_PTR_BUF:	DC.L 0
AUDIOCHLEVEL0NRM:	DC.W 0
AUDIOCHLEVEL0:	DC.W 1
AUDIOCHLEVEL1:	DC.W 1
AUDIOCHLEVEL2:	DC.W 1
AUDIOCHLEVEL3:	DC.W 1
P61_LAST_POS:	DC.W MODSTART_POS
P61_DUMMY_POS:	DC.W 0
P61_FRAMECOUNT:	DC.W 0
P61_SEQ_POS:	DC.W 0
P61_DUMMY_SEQPOS:	DC.W 63
P61_ROW_INDEX:	DC.W 0		; $0-$F
SCROLL_INDEX:	DC.W 0
SCROLL_PLANE:	DC.L 0
SCROLL_SRC:	DC.L 0
SPR_0_POS:	DC.B $7C		; K
SPR_1_POS:	DC.B $84		; O
SPR_2_POS:	DC.B $8C		; N
SPR_3_POS:	DC.B $94		; E
SPR_4_POS:	DC.B $9C		; Y
SCROLL_SHIFT:	DC.B 0
BLIT_COLUMN:	DC.B 0
SCROLL_SHIFT_Y:	DC.B 2
SCROLL_DIR_X:	DC.B 1		; 0=LEFT 1=RIGHT
SCROLL_DIR_Y:	DC.B 0		; 0=LEFT 1=RIGHT
SCROLL_DIR_0:	DC.B 1
SCROLL_DIR_1:	DC.B 1
SCROLL_DIR_2:	DC.B 1
SCROLL_DIR_3:	DC.B 1
TEXTINDEX:	DC.W 0
DUMMY_FRAME_COUNT:	DC.B 0
FRAME_STROBE:	DC.B 0
BLIT_Y_MASK:	DC.W $FFFF
BLIT_X_MASK:	DC.W $FFFF
BLIT_A_MOD:	DC.W 0
BLIT_D_MOD:	DC.W 0
BLIT_SIZE:	DC.W 2*64+wi/2/16

X_CYCLES_COUNTER:	DC.W 15
X_1_4_DIR:	DC.B -1		; -1=LEFT 1=RIGHT
Y_1_4_DIR:	DC.B -1		; -1=LEFT 1=RIGHT
X_1_4_SHIFT:	DC.W 3
Y_1_4_SHIFT:	DC.W 10
X_HALF_DIR:	DC.B -1
Y_HALF_DIR:	DC.B 1
X_HALF_SHIFT:	DC.W 0
Y_HALF_SHIFT:	DC.W 2
X_INCREMENT:	DC.W 1
Y_INCREMENT:	DC.W 1

X_PROGR_DIR:	DC.B -1
Y_PROGR_DIR:	DC.B 1
X_PROGR_TYPE:	DC.B 1
Y_PROGR_TYPE:	DC.B 1		; SOLO POSITIVO
X_PROGR_SHIFT:	DC.W 1

KICKSTART_ADDR:	DC.L $F80000			; POINTERS TO BITMAPS
TEXTURERESET5:	DC.L X_TEXTURE_MIRROR+TEXTURE_H*bypl
		DC.L X_TEXTURE_MIRROR+TEXTURE_H*bypl
TEXTURERESET6:	DC.L X_TEXTURE_MIRROR+TEXTURE_H*bypl*2
		DC.L X_TEXTURE_MIRROR+TEXTURE_H*bypl*2
TEXTURERESET7:	DC.L X_TEXTURE_MIRROR+TEXTURE_H*bwid
		DC.L X_TEXTURE_MIRROR+TEXTURE_H*bwid

Y_EASYING_IDX:	DC.W 2
Y_EASYING_TBL:	DC.W $1,$2,$1,$2,$1,$2,$1,$2,$2,$3,$2,$3,$2,$3,$3,$3,$4,$3,$4,$4,$4,$4,$4,$4,$5,$4,$5,$4,$5,$4,$6,$5
		DC.W $5,$6,$5,$6,$5,$6,$5,$6,$5,$5,$5,$5,$4,$5,$4,$5,$4,$5,$4,$3,$4,$3,$4,$3,$2,$3,$2,$3,$2,$1,$2,$1
Y_EASYING:	DC.W 1

X_EASYING_IDX:	DC.W 0
X_EASYING_TBL:	DC.W $1,$2,$1,$2,$2,$2,$2,$3,$3,$3,$4,$3,$4,$4,$4,$4,$5,$4,$5,$5,$6,$5,$6,$6,$7,$6,$5,$5,$4,$5,$4,$4
		DC.W $4,$3,$4,$3,$4,$3,$4,$3,$4,$3,$3,$3,$3,$2,$3,$2,$3,$2,$3,$2,$2,$2,$1,$2,$1,$2,$1,$2,$1,$1,$1,$1
X_EASYING:	DC.W 1

Z_EASYING_IDX:	DC.W 0
Z_EASYING_TBL:	DC.W $0,$1,$1,$2,$2,$3,$3,$4,$4,$5,$5,$6,$6,$7,$7,$7,$8,$8,$8,$8,$7,$7,$7,$7,$7,$6,$6,$6,$6,$5,$5,$5
		DC.W $5,$5,$4,$4,$4,$4,$3,$3,$3,$3,$3,$2,$2,$2,$2,$1,$1,$1,$1,$1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
Z_EASYING:	DC.W 0

	;*******************************************************************************
	SECTION	ChipData,DATA_C	;declared data that must be in chipmem
	;*******************************************************************************

BLUE_TBL:		DC.W $0002,$0004,$0007,$0009,$000B,$000C,$000E,$000F	; BLUE
		DC.W $0002,$0105,$0106,$0109,$010B,$010C,$010E,$010E
		DC.W $0002,$0205,$0207,$0108,$020B,$0108,$020D,$020D
		DC.W $0002,$0305,$0306,$0208,$020A,$020B,$040C,$030C
		DC.W $0002,$0405,$0407,$0207,$030A,$0209,$050B,$040B
		DC.W $0002,$0505,$0506,$0206,$0309,$0409,$070B,$050A
		DC.W $0002,$0405,$0407,$0307,$0408,$0509,$080A,$060A
		DC.W $0002,$0305,$0306,$0306,$0407,$0508,$0A09,$0B09
		DC.W $0002,$0305,$0205,$0406,$0507,$0608,$0B08,$0A08

PURPL_TBL:	DC.W $0003,$0305,$0205,$0406,$0507,$0708,$0808,$0908	; PURPLE
		DC.W $0003,$0205,$0206,$0406,$0507,$0708,$0908,$0908
		DC.W $0003,$0205,$0205,$0407,$0507,$0708,$0908,$0A08
		DC.W $0003,$0105,$0206,$0406,$0507,$0708,$0A08,$0A07
		DC.W $0003,$0105,$0205,$0407,$0607,$0808,$0B08,$0B07
		DC.W $0003,$0105,$0206,$0406,$0507,$0807,$0C08,$0C06
		DC.W $0003,$0006,$0205,$0407,$0607,$0807,$0C07,$0D06
		DC.W $0003,$0006,$0206,$0406,$0507,$0907,$0D07,$0E06

MAIN_TBL:		DC.W $0003,$0006,$0207,$0407,$0607,$0907,$0D07,$0F06	; MAIN
MIXED_TBL:	DC.W $0001,$000F,$0F00,$0F0F,$0B01,$0506,$070F,$0708	; MIXED

DSR_LOGO:		INCLUDE "sprites_logo.i"
MODULE:		INCBIN "subi-rave_amiga_demo-preview_5_fix.P61"	; code $960F
PIC:		INCBIN "intro_colorfix.raw"

COPPER:
	DC.W $1FC,0	; Slow fetch mode, remove if AGA demo.
	DC.W $8E,$2C81	; 238h display window top, left | DIWSTRT - 11.393
	DC.W $90,$2CC1	; and bottom, right.	| DIWSTOP - 11.457
	DC.W $92,$38	; Standard bitplane dma fetch start
	DC.W $94,$D0	; and stop for standard screen.
	DC.W $106,$0C00	; (AGA compat. if any Dual Playf. mode)
	DC.W $108,0	; BPL1MOD	 Bitplane modulo (odd planes)
	DC.W $10A,0	; BPL2MOD Bitplane modulo (even planes)
	DC.W $102,0	; SCROLL REGISTER (AND PLAYFIELD PRI)

	.Palette:
	;DC.W $0180,$0004,$0182,$0006,$0184,$0207,$0186,$0407
	;DC.W $0188,$0607,$018A,$0907,$018C,$0D07,$018E,$0F06

	;DC.W $0180,$0003,$0182,$0005,$0184,$0007,$0186,$0009
	;DC.W $0188,$000B,$018A,$000D,$018C,$000F,$018E,$020F

	;DC.W $0180,$0003,$0182,$0104,$0184,$0106,$0186,$0207
	;DC.W $0188,$0209,$018A,$030B,$018C,$030D,$018E,$040E

	DC.W $0190,$0888,$0192,$0F00,$0194,$00F0,$0196,$000F
	DC.W $0198,$0FFF,$019A,$000A,$019C,$0FFF,$019E,$000F

	.BplPtrs:
	DC.W $E0,0
	DC.W $E2,0
	DC.W $E4,0
	DC.W $E6,0
	DC.W $E8,0
	DC.W $EA,0
	DC.W $EC,0
	DC.W $EE,0
	DC.W $F0,0
	DC.W $F2,0
	DC.W $F4,0
	DC.W $F6,0		;full 6 ptrs, in case you increase bpls
	DC.W $100,bpls*$1000+$200	;enable bitplanes

	.SpritePointers:
	DC.W $120,0,$122,0	; 0
	DC.W $124,0,$126,0	; 1
	DC.W $128,0,$12A,0	; 2
	DC.W $12C,0,$12E,0	; 3
	DC.W $130,0,$132,0	; 4
	DC.W $134,0,$136,0	; 5
	DC.W $138,0,$13A,0	; 6
	DC.W $13C,0,$13E,0	; 7

	.SpriteColors:
	DC.W $1A0,$0000
	DC.W $1A2,$0FFF
	DC.W $1A4,$018F
	DC.W $1A6,$07DF

	DC.W $1A8,$0000
	DC.W $1AA,$0FFF
	DC.W $1AC,$018F
	DC.W $1AE,$07DF

	DC.W $1B0,$0000
	DC.W $1B2,$0FFF
	DC.W $1B4,$018F
	DC.W $1B6,$07DF

	DC.W $1B8,$0000
	DC.W $1BA,$0FFF
	DC.W $1BC,$018F
	DC.W $1BE,$07DF

	.Waits:
	DC.W $6E01,$FF00
	DC.W $0108,-80	; FROM HALF SCREEN NEGATIVE MODULOS
	DC.W $010A,-80	; TO SHOW THE SAME IMG H-FLIPPED
	DC.W $AE01,$FF00
	DC.W $0108,0	; FROM HALF SCREEN NEGATIVE MODULOS
	DC.W $010A,0	; TO SHOW THE SAME IMG H-FLIPPED

	.SpritesRecolor:
	DC.W $B001,$FF00
	DC.W $01BC,$0459
	DC.W $B501,$FF00
	DC.W $01A4,$0459
	DC.W $01AC,$0459

	DC.W $EE01,$FF00
	DC.W $0108,-80	; FROM HALF SCREEN NEGATIVE MODULOS
	DC.W $010A,-80	; TO SHOW THE SAME IMG H-FLIPPED

	DC.W $FFDF,$FFFE	; allow VPOS>$ff
	DC.W $3501,$FF00	; ## RASTER END ## #$12C?
	DC.W $009A,$0010	; CLEAR RASTER BUSY FLAG
	DC.W $FFFF,$FFFE	; magic value to end copperlist

COPPER_PRE:
	DC.W $1FC,0	; Slow fetch mode, remove if AGA demo.
	DC.W $8E,$2C81	; 238h display window top, left | DIWSTRT - 11.393
	DC.W $90,$2CC1	; and bottom, right.	| DIWSTOP - 11.457
	DC.W $92,$38	; Standard bitplane dma fetch start
	DC.W $94,$D0	; and stop for standard screen.
	DC.W $106,$0C00	; (AGA compat. if any Dual Playf. mode)
	DC.W $108,0	; BPL1MOD	 Bitplane modulo (odd planes)
	DC.W $10A,0	; BPL2MOD Bitplane modulo (even planes)
	DC.W $102,0	; SCROLL REGISTER (AND PLAYFIELD PRI)

	.Palette:
	DC.W $0180,$0102,$0182,$0001,$0184,$0103,$0186,$0113
	DC.W $0188,$0114,$018A,$0126,$018C,$005D,$018E,$009F
	DC.W $0190,$00CF,$0192,$0300,$0194,$0214,$0196,$0321
	DC.W $0198,$0314,$019A,$0238,$019C,$0258,$019E,$025A
	DC.W $01A0,$017F,$01A2,$0421,$01A4,$0426,$01A6,$0436
	DC.W $01A8,$01EF,$01AA,$0623,$01AC,$0538,$01AE,$0558
	DC.W $01B0,$0832,$01B2,$074A,$01B4,$066A,$01B6,$0967
	DC.W $01B8,$0A8B,$01BA,$099F,$01BC,$0000,$01BE,$0000

	.BplPtrs:
	DC.W $E0,0
	DC.W $E2,0
	DC.W $E4,0
	DC.W $E6,0
	DC.W $E8,0
	DC.W $EA,0
	DC.W $EC,0
	DC.W $EE,0
	DC.W $F0,0
	DC.W $F2,0
	DC.W $F4,0
	DC.W $F6,0		;full 6 ptrs, in case you increase bpls
	DC.W $100,(bpls+2)*$1000+$200	;enable bitplanes

	.SpritePointers:
	DC.W $120,0,$122,0	; 0
	DC.W $124,0,$126,0	; 1
	DC.W $128,0,$12A,0	; 2
	DC.W $12C,0,$12E,0	; 3
	DC.W $130,0,$132,0	; 4
	DC.W $134,0,$136,0	; 5
	DC.W $138,0,$13A,0	; 6
	DC.W $13C,0,$13E,0	; 7
	DC.W $FFDF,$FFFE	; allow VPOS>$ff
	DC.W $3501,$FF00	; ## RASTER END ## #$12C?
	DC.W $009A,$0010	; CLEAR RASTER BUSY FLAG
	DC.W $FFFF,$FFFE	; magic value to end copperlist

;*******************************************************************************
	SECTION ChipBuffers,BSS_C	;BSS doesn't count toward exe size
;*******************************************************************************

BPL_PRECALC:	DS.W bypl*2	; Precalculated offsets
BLEEDTOP0:	DS.B 16*bypl*2
BGPLANE0:		DS.B he/2*bypl
BLEEDBOTTOM0:	DS.B 16*bypl
BGPLANE1:		DS.B he/2*bypl
BLEEDBOTTOM1:	DS.B 16*bypl
BGPLANE2:		DS.B he/2*bypl
BLEEDBOTTOM2:	DS.B 16*bypl
X_TEXTURE_MIRROR:	DS.B TEXTURE_H*bwid	; mirrored texture
END