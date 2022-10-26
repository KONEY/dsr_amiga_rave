nowaveforms=noshorts
copdma=1-lev6
Custom_Block_Size=16
	ifnd player61_i
player61_i:	set 1
	ifnd exec_types_i
exec_types_i:	set 1
include_version:	equ 40
extern_lib:	macro
	xref _lvo\1
	endm
structure: macro
\1:	equ 0
soffset:	set \2
	endm
fptr:	macro
\1:	equ soffset
soffset:	set soffset+4
	endm
bool:	macro
\1:	equ soffset
soffset:	set soffset+2
	endm
byte:	macro
\1:	equ soffset
soffset:	set soffset+1
	endm
ubyte:	macro
\1:	equ soffset
soffset:	set soffset+1
	endm
word:	macro
\1:	equ soffset
soffset:	set soffset+2
	endm
uword:	macro
\1:	equ soffset
soffset:	set soffset+2
	endm
short:	macro
\1:	equ soffset
soffset:	set soffset+2
	endm
ushort:	macro
\1:	equ soffset
soffset:	set soffset+2
	endm
long:	macro
\1:	equ soffset
soffset:	set soffset+4
	endm
ulong:	macro
\1:	equ soffset
soffset:	set soffset+4
	endm
float:	macro
\1:	equ soffset
soffset:	set soffset+4
	endm
double:	macro
\1:	equ soffset
soffset:	set soffset+8
	endm
aptr:	macro
\1:	equ soffset
soffset:	set soffset+4
	endm
cptr:	macro
\1:	equ soffset
soffset:	set soffset+4
	endm
rptr:	macro
\1:	equ soffset
soffset:	set soffset+2
	endm
label:	macro
\1:	equ soffset
	endm
struct:	macro
\1:	equ soffset
soffset:	set soffset+\2
	endm
alignword:	macro
soffset:	set (soffset+1)&$fffffffe
	endm
alignlong:	macro
soffset:	set (soffset+3)&$fffffffc
	endm
enum:	macro
	ifc '\1',''
eoffset:	set 0
	endc
	ifnc '\1',''
eoffset:	set \1
	endc
	endm
eitem:	macro
\1:	equ eoffset
eoffset:	set eoffset+1
	endm
bitdef0:	macro
\1\3\2:	equ \4
	endm
bitdef:	macro
	bitdef0 \1,\2,b_,\3
\@bitdef:	set 1<<\3
	bitdef0 \1,\2,f_,\@bitdef
	endm
library_minimum:	equ 33
	endc

	structure Player_Header,0
	ulong P61_InitOffset
	ulong P61_MusicOffset
	ulong P61_EndOffset
	ulong P61_SetRepeatOffset
	ulong P61_SetPositionOffset
	uword P61_MasterVolume
	uword P61_UseTempo
	uword P61_PlayFlag
	uword P61_E8_info
	aptr P61_UseVBR
	uword P61_Position
	uword P61_Pattern
	uword P61_Row
	aptr P61_Cha0Offset
	aptr P61_Cha1Offset
	aptr P61_Cha2Offset
	aptr P61_Cha3Offset
	label Player_Header_SIZE

	structure Channel_Block,0
	ubyte P61_SN_Note
	ubyte P61_Command
	ubyte P61_Info
	ubyte P61_Pack
	aptr P61_Sample
	uword P61_OnOff
	aptr P61_ChaPos
	aptr P61_TempPos
	uword P61_TempLen
	uword P61_Note
	uword P61_Period
	uword P61_Volume
	uword P61_Fine
	uword P61_Offset
	uword P61_LOffset
	uword P61_ToPeriod
	uword P61_TPSpeed
	ubyte P61_VibCmd
	ubyte P61_VibPos
	ubyte P61_TreCmd
	ubyte P61_TrePos
	uword P61_RetrigCount
	ubyte P61_Funkspd
	ubyte P61_Funkoff
	aptr P61_Wave
	uword P61_TData
	aptr P61_TChaPos
	aptr P61_TTempPos
	uword P61_TTempLen
	uword P61_Shadow
	ifne oscillo
	aptr P61_oscptr
	uword P61_oscptrrem
	aptr P61_oscptrWrap
	endc
	uword P61_DMABit
	label Channel_Block_Size

	structure Sample_Block,0
	aptr P61_SampleOffset
	uword P61_SampleLength
	aptr P61_RepeatOffset
	uword P61_RepeatLength
	uword P61_SampleVolume
	uword P61_FineTune
	label Sample_Block_SIZE

P61_ft=usecode&1
P61_pu=usecode&2
P61_pd=usecode&4
P61_tp=usecode&40
P61_vib=usecode&80
P61_tpvs=usecode&32
P61_vbvs=usecode&64
P61_tre=usecode&$80
P61_arp=usecode&$100
P61_sof=usecode&$200
P61_vs=usecode&$400
P61_pj=usecode&$800
P61_vl=usecode&$1000
P61_pb=usecode&$2800
P61_sd=usecode&$8000
P61_ec=usecode&$ffff0000
P61_fi=usecode&$10000
P61_fsu=usecode&$20000
P61_fsd=usecode&$40000
P61_sft=usecode&$200000
P61_pl=usecode&$400000&((1-split4)*$400000)
P61_timing=usecode&$1000000
P61_rt=usecode&$2000000
P61_fvu=usecode&$4000000
P61_fvd=usecode&$8000000
P61_nc=usecode&$10000000
P61_nd=usecode&$20000000
P61_pde=usecode&$40000000
P61_il=usecode&$80000000

	endc
	ifne asmonereport
	printt ""
	printt "Options used:"
	printt "-------------"
	ifne p61fade
	printt "Mastervolume on"
	else
	printt "Mastervolume off"
	endc
	ifne p61system
	printt "System friendly"
	else
	printt "System killer"
	endc
	ifne p61cia
	printt "CIA-tempo on"
	else
	printt "CIA-tempo off"
	endc
	ifne p61exec
	printt "ExecBase valid"
	else
	printt "ExecBase invalid"
	endc
	ifne lev6
	printt "Level 6 IRQ on"
	else
	ifeq (noshorts&(1-p61system))
	printt "FAIL: Non-lev6 NOT available for p61system=1 or noshorts=0!"
	else
	printt "Non-lev6 implemented with 'poke DMAbits byte to a specified address'."
	printt "* READ DOCS for how to specify it and how it works."
	endc
	endc
	ifne opt020
	printt "MC68020 optimizations"
	else
	printt "Normal MC68000 code"
	endc
	printt "Channels:"
	printv channels
	ifgt channels-4
	printt "FAIL: More than 4 channels."
	endc
	ifeq channels
	printt "FAIL: Can't have 0 channels."
	endc
	printt "UseCode:"
	printv usecode
	printt "Player binary size:"
	printv P61E-P61B
	endc
P61B:
P61_motuuli:
	jmp P61_Init(PC)
	ifeq p61cia
	jmp P61_Music(PC)
	else
	rts
	rts
	endc
	jmp P61_End(PC)
	rts
	rts
	ifne p61jump
	jmp P61_SetPosition(PC)
	else
	rts
	rts
	endc
P61_Master:
	dc.w 64
P61_Tempo:
	dc.w 1
P61_Play:
	dc.w 1
P61_E8:
	dc.w 0
P61_VBR:
	dc.l 0
P61_Pos:
	dc.w 0
P61_Patt:
	dc.w 0
P61_CRow:
	dc.w 0
P61_Temp0Offset:
	dc.l P61_temp0-P61_motuuli
P61_Temp1Offset:
	dc.l P61_temp1-P61_motuuli
P61_Temp2Offset:
	dc.l P61_temp2-P61_motuuli
P61_Temp3Offset:
	dc.l P61_temp3-P61_motuuli
P61_getnote: macro
	moveq #$7e,d0
	and.b (a5),d0
	beq.b .nonote
	ifne P61_vib
	clr.b P61_VibPos(a5)
	endc
	ifne P61_tre
	clr.b P61_TrePos(a5)
	endc
	ifne P61_ft
	add P61_Fine(a5),d0
	endc
	move d0,P61_Note(a5)
	move P61_periods-P61_cn(a3,d0),P61_Period(a5)
.nonote:
	endm
	ifeq p61system
	ifne p61cia
P61_intti:
	movem.l d0-a6,-(sp)
	tst.b $bfdd00
	lea $dff000+C,a6
	move #$2000,$9c-C(a6)
	move #$2000,$9c-C(a6)
	bsr P61_Music
	movem.l (sp)+,d0-a6
	nop
	rte
	endc
	endc
	ifne p61system
P61_lev6server:
	movem.l d2-d7/a2-a6,-(sp)
	lea P61_timeron(pc),a0
	tst (a0)
	beq.b P61_ohi
	lea $dff000+C,a6
	move P61_server(pc),d0
	beq.b P61_musica
	subq #1,d0
	beq P61_dmason
	ifeq nowaveforms
	bra P61_setrepeat
	else
	bra.b P61_ohi
	endc
P61_musica:
	bsr P61_Music
P61_ohi:
	movem.l (sp)+,d2-d7/a2-a6
	moveq #1,d0
	rts
	endc
P61_Init:
	lea $dff000+C,a6
	ifeq p61system
	ifne quietstart
	move.w #$f,$96-C(A6)
	lea $a0-C(A6),a5
	lea P61_Quiet(PC),a3
	moveq #0,d1
	moveq #channels-1,d5
.choffl:	move.l a3,(a5)+
	move.l #1<<16+124,(a5)+
	move.l d1,(a5)+
	addq.w #4,a5
	dbf d5,.choffl
	endc
	endc
	cmp.l #"P61A",(a0)+
	beq.b .modok
	subq.l #4,a0
.modok:
	ifne p61cia
	move d0,-(sp)
	endc
	moveq #0,d0
	cmp.l d0,a1
	bne.b .redirect
	move (a0),d0
	lea (a0,d0.l),a1
.redirect:
	move.l a2,a6
	lea 8(a0),a2
	moveq #$40,d0
	and.b 3(a0),d0
	bne.b .buffer
	move.l a1,a6
	subq.l #4,a2
.buffer:
	lea P61_cn(pc),a3
	move.w #$ff00,d1
	move.w d1,P61_OnOff+P61_temp0-P61_cn(a3)
	move.w d1,P61_OnOff+P61_temp1-P61_cn(a3)
	move.w d1,P61_OnOff+P61_temp2-P61_cn(a3)
	move.w d1,P61_OnOff+P61_temp3-P61_cn(a3)
	ifne copdma
	move.l a4,p61_DMApokeAddr-P61_cn(a3)
	endc
	moveq #$1f,d1
	and.b 3(a0),d1
	move.l a0,-(sp)
	lea P61_samples(pc),a4
	subq #1,d1
	moveq #0,d4
P61_lopos:
	move.l a6,(a4)+
	move (a2)+,d4
	bpl.b P61_kook
	neg d4
	lea P61_samples-16(pc),a5
	ifeq opt020
	asl #4,d4
	move.l (a5,d4),d6
	else
	add d4,d4
	move.l (a5,d4*8),d6
	endc
	move.l d6,-4(a4)
	ifeq opt020
	move 4(a5,d4),d4
	else
	move 4(a5,d4*8),d4
	endc
	sub.l d4,a6
	sub.l d4,a6
	bra.b P61_jatk
P61_kook:
	move.l a6,d6
	tst.b 3(a0)
	bpl.b P61_jatk
	tst.b (a2)
	bmi.b P61_jatk
	move d4,d0
	subq #2,d0
	bmi.b P61_jatk
	move.l a1,a5
	move.b (a5)+,d2
	sub.b (a5),d2
	move.b d2,(a5)+
.loop:	sub.b (a5),d2
	move.b d2,(a5)+
	sub.b (a5),d2
	move.b d2,(a5)+
	dbf d0,.loop
P61_jatk:
	move d4,(a4)+
	moveq #0,d2
	move.b (a2)+,d2
	moveq #0,d3
	move.b (a2)+,d3
	moveq #0,d0
	move (a2)+,d0
	bmi.b .norepeat
	move d4,d5
	sub d0,d5
	move.l d6,a5
	add.l d0,a5
	add.l d0,a5
	move.l a5,(a4)+
	move d5,(a4)+
	bra.b P61_gene
.norepeat:
	move.l d6,(a4)+
	move #1,(a4)+
P61_gene:
	move d3,(a4)+
	moveq #$f,d0
	and d2,d0
	mulu #74,d0
	move d0,(a4)+
	tst -6(a2)
	bmi.b .nobuffer
	moveq #$40,d0
	and.b 3(a0),d0
	beq.b .nobuffer
	move d4,d7
	tst.b d2
	bpl.b .copy
	subq #1,d7
	moveq #0,d5
	moveq #0,d4
.lo:	move.b (a1)+,d4
	moveq #$f,d3
	and d4,d3
	lsr #4,d4
	sub.b .table(pc,d4),d5
	move.b d5,(a6)+
	sub.b .table(pc,d3),d5
	move.b d5,(a6)+
	dbf d7,.lo
	bra.b .kop
.copy:
	add d7,d7
	subq #1,d7
.cob:
	move.b (a1)+,(a6)+
	dbf d7,.cob
	bra.b .kop
.table:
	dc.b 0,1,2,4,8,16,32,64,128,-64,-32,-16,-8,-4,-2,-1
.nobuffer:
	move.l d4,d6
	add.l d6,d6
	add.l d6,a6
	add.l d6,a1
.kop:
	dbf d1,P61_lopos
	move.l (sp)+,a0
	and.b #$7f,3(a0)
	move.l a2,-(sp)
	lea P61_temp0(pc),a1
	lea P61_temp1(pc),a2
	lea P61_temp2(pc),a4
	lea P61_temp3(pc),a5
	moveq #Channel_Block_Size/2-2,d0
	moveq #0,d1
.cl:	move d1,(a1)+
	move d1,(a2)+
	move d1,(a4)+
	move d1,(a5)+
	dbf d0,.cl
	lea P61_temp0-P61_cn(a3),a1
	lea P61_emptysample-P61_cn(a3),a2
	moveq #channels-1,d0
.loo:
	move.l a2,P61_Sample(a1)
	lea Channel_Block_Size(a1),a1
	dbf d0,.loo
	move.l (sp)+,a2
	move.l a2,P61_positionbase-P61_cn(a3)
	moveq #$7f,d1
	and.b 2(a0),d1
	ifeq opt020
	lsl #3,d1
	lea (a2,d1.l),a4
	else
	lea (a2,d1.l*8),a4
	endc
	move.l a4,P61_possibase-P61_cn(a3)
	move.l a4,a1
	moveq #-1,d0
.search:
	cmp.b (a1)+,d0
	bne.b .search
	move.l a1,P61_patternbase-P61_cn(a3)
	move.l a1,d0
	sub.l a4,d0
	subq.w #1,d0
	move d0,P61_slen-P61_cn(a3)
	add.w P61_InitPos(pc),a4
	moveq #0,d0
	move.b (a4)+,d0
	move.l a4,P61_spos-P61_cn(a3)
	lsl #3,d0
	add.l d0,a2
	move.l a1,a4
	moveq #0,d0
	move (a2)+,d0
	lea (a4,d0.l),a1
	move.l a1,P61_ChaPos+P61_temp0-P61_cn(a3)
	move (a2)+,d0
	lea (a4,d0.l),a1
	move.l a1,P61_ChaPos+P61_temp1-P61_cn(a3)
	move (a2)+,d0
	lea (a4,d0.l),a1
	move.l a1,P61_ChaPos+P61_temp2-P61_cn(a3)
	move (a2)+,d0
	lea (a4,d0.l),a1
	move.l a1,P61_ChaPos+P61_temp3-P61_cn(a3)
	ifeq nowaveforms
	lea P61_setrepeat(pc),a0
	move.l a0,P61_intaddr-P61_cn(a3)
	endc
	move #63,P61_rowpos-P61_cn(a3)
	move #6,P61_speed-P61_cn(a3)
	move #5,P61_speed2-P61_cn(a3)
	clr P61_speedis1-P61_cn(a3)
	ifne P61_pl
	clr.l P61_plcount-P61_cn(a3)
	endc
	ifne P61_pde
	clr P61_pdelay-P61_cn(a3)
	clr P61_pdflag-P61_cn(a3)
	endc
	clr (a3)
	moveq #2,d0
	and.b $bfe001,d0
	move.b d0,P61_ofilter-P61_cn(a3)
	bset #1,$bfe001
	ifeq p61system
	ifne p61exec
	move.l 4.w,a6
	moveq #0,d0
	btst d0,297(a6)
	beq.b .no68010
	lea P61_liko(pc),a5
	jsr -$1e(a6)
.no68010:
	move.l d0,P61_VBR-P61_cn(a3)
	endc
	move.l P61_VBR-P61_cn(a3),a0
	lea $78(a0),a0
	move.l a0,P61_vektori-P61_cn(a3)
	move.l (a0),P61_oldlev6-P61_cn(a3)
	ifeq copdma
	lea P61_dmason(pc),a1
	move.l a1,(a0)
	endc
	endc
	moveq #$f,d0
	lea $dff000+C,a6
	ifeq quietstart
	moveq #$0,d1
	move d1,$a8-C(a6)
	move d1,$b8-C(a6)
	move d1,$c8-C(a6)
	move d1,$d8-C(a6)
	move d0,$96-C(a6)
	endc
	ifne nowaveforms
	move.w d0,P61_NewDMA-P61_cn(a3)
	endc
	ifeq p61system
	ifeq copdma
	lea P61_dmason(pc),a1
	move.l a1,(a0)
	endc
	move #$2000,$9a-C(a6)
	lea $bfd000,a0
	lea P61_timers(pc),a1
	move.b #$7f,$d00(a0)
	ifne p61cia
	move.b #$10,$e00(a0)
	endc
	move.b #$10,$f00(a0)
	ifne p61cia
	move.b $400(a0),(a1)+
	move.b $500(a0),(a1)+
	else
	addq.w #2,a1
	endc
	move.b $600(a0),(a1)+
	move.b $700(a0),(a1)
	endc
	ifeq (p61system+p61cia)
	move.b #$82,$d00(a0)
	endc
	ifne p61cia
	move (sp)+,d0
	subq #1,d0
	beq.b P61_ForcePAL
	subq #1,d0
	beq.b P61_NTSC
	ifne p61exec
	move.l 4.w,a1
	cmp.b #60,$213(a1)
	beq.b P61_NTSC
	endc
P61_ForcePAL:
	move.l #1773447,d0
	bra.b P61_setcia
P61_NTSC:
	move.l #1789773,d0
P61_setcia:
	move.l d0,P61_timer-P61_cn(a3)
	divu #125,d0
	move d0,P61_thi2-P61_cn(a3)
	sub #$1f0*2,d0
	move d0,P61_thi-P61_cn(a3)
	ifeq p61system
	move P61_thi2-P61_cn(a3),d0
	move.b d0,$400(a0)
	lsr #8,d0
	move.b d0,$500(a0)
	lea P61_intti(pc),a1
	move.l a1,P61_tintti-P61_cn(a3)
	move.l P61_vektori(pc),a2
	move.l a1,(a2)
	move.b #$83,$d00(a0)
	move.b #$11,$e00(a0)
	endc
	endc
	ifeq p61system
	ifeq copdma
	move #$e000,$9a-C(a6)
	else
	move #$c000,$9a-C(a6)
	endc
	ifne quietstart
	move.w #$800f,$96-C(A6)
	endc
	moveq #0,d0
	rts
	ifne p61exec
P61_liko:
	dc.l $4E7A0801
	rte
	endc
	endc
	ifne p61system
	move.l a6,-(sp)
	ifne p61cia
	clr P61_server-P61_cn(a3)
	else
	move #1,P61_server-P61_cn(a3)
	endc
	move.l 4.w,a6
	moveq #-1,d0
	jsr -$14a(a6)
	move.b d0,P61_sigbit-P61_cn(a3)
	bmi P61_err
	lea P61_allocport(pc),a1
	move.l a1,P61_portti-P61_cn(a3)
	move.b d0,15(a1)
	move.l a1,-(sp)
	suba.l a1,a1
	jsr -$126(a6)
	move.l (sp)+,a1
	move.l d0,16(a1)
	lea P61_reqlist(pc),a0
	move.l a0,(a0)
	addq.l #4,(a0)
	clr.l 4(a0)
	move.l a0,8(a0)
	lea P61_dat(pc),a1
	move.l a1,P61_reqdata-P61_cn(a3)
	lea P61_allocreq(pc),a1
	lea P61_audiodev(pc),a0
	moveq #0,d0
	moveq #0,d1
	jsr -$1bc(a6)
	tst.l d0
	bne P61_err
	st.b P61_audioopen-P61_cn(a3)
	lea P61_timerint(pc),a1
	move.l a1,P61_timerdata-P61_cn(a3)
	lea P61_lev6server(pc),a1
	move.l a1,P61_timerdata+8-P61_cn(a3)
	moveq #0,d3
	lea P61_cianame(pc),a1
P61_openciares:
	moveq #0,d0
	move.l 4.w,a6
	jsr -$1f2(a6)
	move.l d0,P61_ciares-P61_cn(a3)
	beq.b P61_err
	move.l d0,a6
	lea P61_timerinterrupt(pc),a1
	moveq #0,d0
	jsr -6(a6)
	tst.l d0
	beq.b P61_gottimer
	addq.l #4,d3
	lea P61_timerinterrupt(pc),a1
	moveq #1,d0
	jsr -6(a6)
	tst.l d0
	bne.b P61_err
P61_gottimer:
	lea P61_craddr+8(pc),a6
	move.l P61_ciaaddr(pc,d3),d0
	move.l d0,(a6)
	sub #$100,d0
	move.l d0,-(a6)
	moveq #2,d3
	btst #9,d0
	bne.b P61_timerB
	subq.b #1,d3
	add #$100,d0
P61_timerB:
	add #$900,d0
	move.l d0,-(a6)
	move.l d0,a0
	and.b #%10000000,(a0)
	move.b d3,P61_timeropen-P61_cn(a3)
	moveq #0,d0
	ifne p61cia
	move.l P61_craddr+4(pc),a1
	move.b P61_tlo(pc),(a1)
	move.b P61_thi(pc),$100(a1)
	endc
	or.b #$19,(a0)
	st P61_timeron-P61_cn(a3)
P61_pois:
	move.l (sp)+,a6
	rts
P61_err:	moveq #-1,d0
	bra.b P61_pois
P61_ciaaddr:
	dc.l $bfd500,$bfd700
	endc
P61_End:
	lea $dff000+C,a6
	moveq #0,d0
	move d0,$a8-C(a6)
	move d0,$b8-C(a6)
	move d0,$c8-C(a6)
	move d0,$d8-C(a6)
	move #$f,$96-C(a6)
	and.b #%11111101,$bfe001
	move.b P61_ofilter(pc),d0
	or.b d0,$bfe001
	ifeq p61system
	move #$2000,$9a-C(a6)
	move.l P61_vektori(pc),a0
	move.l P61_oldlev6(pc),(a0)
	lea $bfd000,a0
	lea P61_timers(pc),a1
	ifne p61cia
	move.b (a1)+,$400(a0)
	move.b (a1)+,$500(a0)
	else
	addq.w #2,a1
	endc
	move.b (a1)+,$600(a0)
	move.b (a1)+,$700(a0)
	ifne p61cia
	move.b #$10,$e00(a0)
	endc
	move.b #$10,$f00(a0)
	else
	move.l a6,-(sp)
	lea P61_cn(pc),a3
	moveq #0,d0
	clr P61_timeron-P61_cn(a3)
	move.b P61_timeropen(pc),d0
	beq.b P61_rem1
	move.l P61_ciares(pc),a6
	lea P61_timerinterrupt(pc),a1
	subq.b #1,d0
	jsr -12(a6)
P61_rem1:
	move.l 4.w,a6
	tst.b P61_audioopen-P61_cn(a3)
	beq.b P61_rem2
	lea P61_allocreq(pc),a1
	jsr -$1c2(a6)
	clr.b P61_audioopen-P61_cn(a3)
P61_rem2:
	moveq #0,d0
	move.b P61_sigbit(pc),d0
	bmi.b P61_rem3
	jsr -$150(a6)
	st P61_sigbit-P61_cn(a3)
P61_rem3:
	move.l (sp)+,a6
	endc
	rts
	ifne p61fade
P61_mfade:
	lea $dff0a8,a4
	move P61_Master(pc),d0
	move P61_temp0+P61_Shadow(pc),d1
	mulu d0,d1
	lsr #6,d1
	move d1,(a4)
	ifgt channels-1
	move P61_temp1+P61_Shadow(pc),d1
	mulu d0,d1
	lsr #6,d1
	move d1,$10(a4)
	endc
	ifgt channels-2
	move P61_temp2+P61_Shadow(pc),d1
	mulu d0,d1
	lsr #6,d1
	move d1,$20(a4)
	endc
	ifgt channels-3
	move P61_temp3+P61_Shadow(pc),d1
	mulu d0,d1
	lsr #6,d1
	move d1,$30(a4)
	endc
	rts
	endc
	ifne oscillo
oscextloops=0
oscbigempty=0
ticksframePAL=70937*4+2
ticksframeNTSC=59719*4+3
P61_osc:
	move.w P61_Period(a0),d4
	bne.b .non0
.div0:	lea Channel_Block_Size(a0),a0
	moveq #0,d1
	rts
.non0:
	lea P61_oscptr(a0),a0
	move.l (a0)+,d0
	moveq #3,d3
	and.l d0,d3
	move.l d0,d2
	addq.l #2,d2
	lsr.l #2,d2
	move.l d2,a2
	move.l #ticksframePAL,d2
	divu d4,d2
	moveq #0,d1
	move.w d2,d1
	clr.w d2
	divu d4,d2
	add.w d2,(a0)+
	addx.l d1,d0
	move.l d0,-6(a0)
	move.l d0,d1
	addq.l #2,d1
	lsr.l #2,d1
	sub.l a2,d1
	moveq #0,d2
	sub.l (a0)+,d0
	blt.b .nowr
	move.l P61_Sample-P61_DMABit(a0),a1
	ifeq oscbigempty
	move.w 10(a1),d2
	subq.w #1,d2
	endc
	move.l 6(a1),a1
	ifne oscbigempty
	bne.b .nol1
	lea P61_emptyloop578(PC),a1
.nol1:
	endc
	ifeq oscbigempty
	addq.l #1,d2
	add.l d2,d2
	else
	move.l #P61_emptyquiet578E-P61_emptyquiet578,d2
	endc
	move.l a1,d4
	lsl.l #2,d4
	or.b d3,d4
	addq.w #2,d0
	lsr.w #2,d0
	move.l d0,d3
	ifeq oscextloops
	divu d2,d3
	clr.w d3
	swap d3
	endc
	add.w d3,d3
	add.w d3,d3
	add.l d4,d3
	move.l d3,-10(a0)
	move.l d2,d4
	add.l a1,d2
	move.l d2,d3
	lsl.l #2,d3
	move.l d3,-4(a0)
	bra.s .ct
.nowr:
	move.l d2,d4
	addq.l #2,d0
	asr.l #2,d0
.ct:
	addq.w #2,a0
	tst.w d1
	RTS
	ifne oscbigempty
P61_emptyloop578:
	dcb.w 578/2,0
P61_emptyloop578E:
	endc
	endc
	ifne p61jump
P61_SetPosition:
	lea P61_cn(pc),a3
	ifne split4
	move.w P61_speed2(PC),d1
	subq.w #3,d1
	else
	move.w P61_speed2(PC),d1
	subq.w #1,d1
	endc
	move.w d1,(a3)
	ifne P61_pl
	clr P61_plflag-P61_cn(a3)
	endc
	moveq #0,d1
	move.b d0,d1
	move.l d1,d0
	ifeq optjmp
	cmp P61_slen-P61_cn(a3),d0
	blo.b .e
	moveq #0,d0
.e:
	endc
	move d0,P61_Pos-P61_cn(a3)
	add.l P61_possibase(pc),d0
	move.l d0,P61_spos-P61_cn(a3)
	moveq #63,d0
	move d0,P61_rowpos-P61_cn(a3)
	clr P61_CRow-P61_cn(a3)
	move.l P61_spos(pc),a1
	move.l P61_patternbase(pc),a0
	addq #1,P61_Pos-P61_cn(a3)
	move.b (a1)+,d0
	move.l a1,P61_spos-P61_cn(a3)
	move.l P61_positionbase(pc),a1
	move d0,P61_Patt-P61_cn(a3)
	lsl #3,d0
	add.l d0,a1
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp0-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp1-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp2-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp3-P61_cn(a3)
	lea P61_temp0(PC),a3
	clr.b P61_Pack+Channel_Block_Size*0(a3)
	clr.b P61_Pack+Channel_Block_Size*1(a3)
	clr.b P61_Pack+Channel_Block_Size*2(a3)
	clr.b P61_Pack+Channel_Block_Size*3(a3)
	clr.b P61_TempLen+1+Channel_Block_Size*0(a3)
	clr.b P61_TempLen+1+Channel_Block_Size*1(a3)
	clr.b P61_TempLen+1+Channel_Block_Size*2(a3)
	clr.b P61_TempLen+1+Channel_Block_Size*3(a3)
	move.w #$ff00,d0
	move.w d0,P61_OnOff+Channel_Block_Size*0(a3)
	move.w d0,P61_OnOff+Channel_Block_Size*1(a3)
	move.w d0,P61_OnOff+Channel_Block_Size*2(a3)
	move.w d0,P61_OnOff+Channel_Block_Size*3(a3)
	clr.b P61_dma+1-P61_temp0(a3)
	move.w #$000f,$96-C(A6)
	ifne nowaveforms
	clr P61_NewDMA-P61_temp0(a3)
	endc
	ifne copdma
	move.l p61_DMApokeAddr(PC),a3
	clr.b (a3)
	endc
	rts
	endc
P61_Music:
	lea P61_cn(pc),a3
	moveq #0,d7
	lea $a0-C(a6),a4
	ifne playflag
	tst P61_Play-P61_cn(a3)
	bne.b P61_ohitaaa
	ifne p61cia
	ifne p61system
	move.l P61_craddr+4(pc),a0
	move.b P61_tlo2(pc),(a0)
	move.b P61_thi2(pc),$100(a0)
	endc
	endc
	rts
	endc
P61_ohitaaa:
	ifne visuctrs
	addq.w #1,P61_visuctr0-P61_cn(a3)
	addq.w #1,P61_visuctr1-P61_cn(a3)
	addq.w #1,P61_visuctr2-P61_cn(a3)
	addq.w #1,P61_visuctr3-P61_cn(a3)
	endc
	ifne p61fade
	pea P61_mfade(pc)
	endc
	move.w (a3),d4
	cmp.w P61_speed2(pc),d4
	beq.w P61_playtime
	ifeq suppF01
	blt.b P61_nowrap
	endc
	ifeq suppF01
	ifne nowaveforms
	move.b P61_dma+1-P61_cn(a3),P61_NewDMA+1-P61_cn(a3)
	endc
	clr.w d4
	subq #1,P61_rowpos-P61_cn(a3)
	bpl.b P61_nonewpatt
P61_nextpattern:
	ifne P61_pl
	move d7,P61_plflag-P61_cn(a3)
	endc
	move.l P61_patternbase(pc),a0
	moveq #63,d0
	move d0,P61_rowpos-P61_cn(a3)
	move d7,P61_CRow-P61_cn(a3)
	move.l P61_spos(pc),a1
	addq #1,P61_Pos-P61_cn(a3)
	move.b (a1)+,d0
	bpl.b P61_dk
	move.l P61_possibase(pc),a1
	move.b (a1)+,d0
	move d7,P61_Pos-P61_cn(a3)
P61_dk:
	move.l a1,P61_spos-P61_cn(a3)
	move d0,P61_Patt-P61_cn(a3)
	lsl #3,d0
	move.l P61_positionbase(pc),a1
	add.l d0,a1
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp0-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp1-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp2-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp3-P61_cn(a3)
	bra.b P61_nowrap
P61_nonewpatt:
	moveq #63,d0
	sub P61_rowpos-P61_cn(a3),d0
	move d0,P61_CRow-P61_cn(a3)
	endc
P61_nowrap:
	addq.w #1,d4
	move d4,(a3)
P61_delay:
	ifne nowaveforms
	move.w P61_NewDMA(PC),d5
	beq.b .nosetloops
	move.l P61_Sample+P61_temp0(PC),a0
	move.l 6(a0),(a4)
	move.w 10(a0),4(a4)
	ifgt channels-1
	move.l P61_Sample+P61_temp1(PC),a0
	move.l 6(a0),$10(a4)
	move.w 10(a0),$14(a4)
	endc
	ifgt channels-2
	move.l P61_Sample+P61_temp2(PC),a0
	move.l 6(a0),$20(a4)
	move.w 10(a0),$24(a4)
	endc
	ifgt channels-3
	move.l P61_Sample+P61_temp3(PC),a0
	move.l 6(a0),$30(a4)
	move.w 10(a0),$34(a4)
	endc
	move.w d7,P61_NewDMA-P61_cn(a3)
.nosetloops:
	endc
	ifne p61cia
	ifne p61system
	move.l P61_craddr+4(pc),a0
	move.b P61_tlo2(pc),(a0)
	move.b P61_thi2(pc),$100(a0)
	endc
	endc
	lea P61_temp0(pc),a5
	moveq #channels-1,d5
P61_lopas:
	tst.b P61_OnOff+1(a5)
	beq.w P61_contfxdone
	moveq #$f,d0
	and (a5),d0
	ifeq opt020
	add d0,d0
	move P61_jtab2(pc,d0),d0
	else
	move P61_jtab2(pc,d0*2),d0
	endc
	jmp P61_jtab2(pc,d0)
P61_jtab2:
	dc P61_contfxdone-P61_jtab2
	ifne P61_pu
	dc P61_portup-P61_jtab2
	else
	dc P61_contfxdone-P61_jtab2
	endc
	ifne P61_pd
	dc P61_portdwn-P61_jtab2
	else
	dc P61_contfxdone-P61_jtab2
	endc
	ifne P61_tp
	dc P61_toneport-P61_jtab2
	else
	dc P61_contfxdone-P61_jtab2
	endc
	ifne P61_vib
	dc P61_vib2-P61_jtab2
	else
	dc P61_contfxdone-P61_jtab2
	endc
	ifne P61_tpvs
	dc P61_tpochvslide-P61_jtab2
	else
	dc P61_contfxdone-P61_jtab2
	endc
	ifne P61_vbvs
	dc P61_vibochvslide-P61_jtab2
	else
	dc P61_contfxdone-P61_jtab2
	endc
	ifne P61_tre
	dc P61_tremo-P61_jtab2
	else
	dc P61_contfxdone-P61_jtab2
	endc
	ifne P61_arp
	dc P61_arpeggio-P61_jtab2
	else
	dc P61_contfxdone-P61_jtab2
	endc
	dc P61_contfxdone-P61_jtab2
	ifne P61_vs
	dc P61_volslide-P61_jtab2
	else
	dc P61_contfxdone-P61_jtab2
	endc
	dc P61_contfxdone-P61_jtab2
	dc P61_contfxdone-P61_jtab2
	dc P61_contfxdone-P61_jtab2
	ifne P61_ec
	dc P61_contecommands-P61_jtab2
	else
	dc P61_contfxdone-P61_jtab2
	endc
	dc P61_contfxdone-P61_jtab2
	ifne P61_ec
P61_contecommands:
	move.b P61_Info(a5),d0
	and #$f0,d0
	lsr #3,d0
	move P61_etab2(pc,d0),d0
	jmp P61_etab2(pc,d0)
P61_etab2:
	dc P61_contfxdone-P61_etab2
	ifne P61_fsu
	dc P61_fineup2-P61_etab2
	else
	dc P61_contfxdone-P61_etab2
	endc
	ifne P61_fsd
	dc P61_finedwn2-P61_etab2
	else
	dc P61_contfxdone-P61_etab2
	endc
	dc P61_contfxdone-P61_etab2
	dc P61_contfxdone-P61_etab2
	dc P61_contfxdone-P61_etab2
	dc P61_contfxdone-P61_etab2
	dc P61_contfxdone-P61_etab2
	dc P61_contfxdone-P61_etab2
	ifne P61_rt
	dc P61_retrig-P61_etab2
	else
	dc P61_contfxdone-P61_etab2
	endc
	ifne P61_fvu
	dc P61_finevup2-P61_etab2
	else
	dc P61_contfxdone-P61_etab2
	endc
	ifne P61_fvd
	dc P61_finevdwn2-P61_etab2
	else
	dc P61_contfxdone-P61_etab2
	endc
	ifne P61_nc
	dc P61_notecut-P61_etab2
	else
	dc P61_contfxdone-P61_etab2
	endc
	ifne P61_nd
	dc P61_notedelay-P61_etab2
	else
	dc P61_contfxdone-P61_etab2
	endc
	dc P61_contfxdone-P61_etab2
	dc P61_contfxdone-P61_etab2
	endc
	ifne P61_fsu
P61_fineup2:
	tst (a3)
	bne.w P61_contfxdone
	moveq #$f,d0
	and.b P61_Info(a5),d0
	sub d0,P61_Period(a5)
	moveq #113,d0
	cmp P61_Period(a5),d0
	ble.b .jup
	move d0,P61_Period(a5)
.jup:	move P61_Period(a5),6(a4)
	bra.w P61_contfxdone
	endc
	ifne P61_fsd
P61_finedwn2:
	tst (a3)
	bne.w P61_contfxdone
	moveq #$f,d0
	and.b P61_Info(a5),d0
	add d0,P61_Period(a5)
	cmp #856,P61_Period(a5)
	ble.b .jup
	move #856,P61_Period(a5)
.jup:	move P61_Period(a5),6(a4)
	bra.w P61_contfxdone
	endc
	ifne P61_fvu
P61_finevup2:
	tst (a3)
	bne.w P61_contfxdone
	moveq #$f,d0
	and.b P61_Info(a5),d0
	add d0,P61_Volume(a5)
	moveq #64,d0
	cmp P61_Volume(a5),d0
	bge.b .jup
	move d0,P61_Volume(a5)
.jup:	move P61_Volume(a5),8(a4)
	bra.w P61_contfxdone
	endc
	ifne P61_fvd
P61_finevdwn2:
	tst (a3)
	bne.w P61_contfxdone
	moveq #$f,d0
	and.b P61_Info(a5),d0
	sub d0,P61_Volume(a5)
	bpl.b .jup
	move d7,P61_Volume(a5)
.jup:	move P61_Volume(a5),8(a4)
	bra.w P61_contfxdone
	endc
	ifne P61_nc
P61_notecut:
	moveq #$f,d0
	and.b P61_Info(a5),d0
	cmp (a3),d0
	bne.w P61_contfxdone
	ifeq p61fade
	move d7,8(a4)
	else
	move d7,P61_Shadow(a5)
	endc
	move d7,P61_Volume(a5)
	bra.w P61_contfxdone
	endc
	ifne P61_nd
P61_notedelay:
	moveq #$f,d0
	and.b P61_Info(a5),d0
	cmp (a3),d0
	bne.w P61_contfxdone
	moveq #$7e,d0
	and.b (a5),d0
	beq.w P61_contfxdone
	move P61_DMABit(a5),d0
	move d0,$96-C(a6)
	or d0,P61_dma-P61_cn(a3)
	ifne nowaveforms
	or d0,P61_NewDMA-P61_cn(a3)
	endc
	move.l P61_Sample(a5),a1
	ifeq oscillo
	move.l (a1)+,(a4)
	move (a1),4(a4)
	else
	moveq #0,d1
	move.l (a1)+,d0
	move (a1),d1
	move.l d0,(a4)
	move.w d1,4(a4)
	subq.w #1,d1
	addq.l #1,d1
	lsl.l #2,d0
	move.l d0,P61_oscptr(a5)
	move.w d7,P61_oscptrrem(a5)
	lsl.l #3,d1
	add.l d0,d1
	move.l d1,P61_oscptrWrap(a5)
	endc
	move P61_Period(a5),6(a4)
	ifne copdma
	move.l p61_DMApokeAddr(PC),a0
	move.b P61_dma+1-P61_cn(a3),(a0)
	endc
	ifeq copdma&nowaveforms
	ifeq p61system
	lea P61_dmason(pc),a1
	move.l P61_vektori(pc),a0
	move.l a1,(a0)
	move.b #$f0,$bfd600
	move.b #$01,$bfd700
	move.b #$19,$bfdf00
	else
	move #1,P61_server-P61_cn(a3)
	move.l P61_craddr+4(pc),a1
	move.b #$f0,(a1)
	move.b #1,$100(a1)
	endc
	endc
	bra.w P61_contfxdone
	endc
	ifne P61_rt
P61_retrig:
	subq #1,P61_RetrigCount(a5)
	bne.w P61_contfxdone
	move P61_DMABit(a5),d0
	move d0,$96-C(a6)
	or d0,P61_dma-P61_cn(a3)
	ifne nowaveforms
	or d0,P61_NewDMA-P61_cn(a3)
	endc
	move.l P61_Sample(a5),a1
	ifeq oscillo
	move.l (a1)+,(a4)
	move (a1),4(a4)
	else
	moveq #0,d1
	move.l (a1)+,d0
	move (a1),d1
	move.l d0,(a4)
	move.w d1,4(a4)
	subq.w #1,d1
	addq.l #1,d1
	lsl.l #2,d0
	move.l d0,P61_oscptr(a5)
	move.w d7,P61_oscptrrem(a5)
	lsl.l #3,d1
	add.l d0,d1
	move.l d1,P61_oscptrWrap(a5)
	endc
	ifne copdma
	move.l p61_DMApokeAddr(PC),a0
	move.b P61_dma+1-P61_cn(a3),(a0)
	endc
	ifeq copdma&nowaveforms
	ifeq p61system
	lea P61_dmason(pc),a1
	move.l P61_vektori(pc),a0
	move.l a1,(a0)
	move.b #$f0,$bfd600
	move.b #$01,$bfd700
	move.b #$19,$bfdf00
	else
	move #1,P61_server-P61_cn(a3)
	move.l P61_craddr+4(pc),a1
	move.b #$f0,(a1)
	move.b #1,$100(a1)
	endc
	endc
	moveq #$f,d0
	and.b P61_Info(a5),d0
	move d0,P61_RetrigCount(a5)
	bra.w P61_contfxdone
	endc
	ifne P61_arp
P61_arplist:
	dc.b 0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0
	dc.b 1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1
P61_arpeggio:
	move (a3),d0
	move.b P61_arplist(pc,d0),d0
	beq.b .arp0
	bmi.b .arp1
	move.b P61_Info(a5),d0
	lsr #4,d0
	bra.b .arp3
.arp0:
	move P61_Note(a5),d0
	move P61_periods-P61_cn(a3,d0),6(a4)
	bra.w P61_contfxdone
.arp1:
	moveq #$f,d0
	and.b P61_Info(a5),d0
.arp3:
	add d0,d0
	add P61_Note(a5),d0
	move P61_periods-P61_cn(a3,d0),6(a4)
	bra.w P61_contfxdone
	endc
	ifne P61_vs
P61_volslide:
	move.b P61_Info(a5),d0
	sub.b d0,P61_Volume+1(a5)
	bpl.b .test
	move d7,P61_Volume(a5)
	ifeq p61fade
	move d7,8(a4)
	else
	move d7,P61_Shadow(a5)
	endc
	bra.w P61_contfxdone
.test:
	moveq #64,d0
	cmp P61_Volume(a5),d0
	bge.b .ncs
	move d0,P61_Volume(a5)
	ifeq p61fade
	move d0,8(a4)
	else
	move d0,P61_Shadow(a5)
	endc
	bra.w P61_contfxdone
.ncs:
	ifeq p61fade
	move P61_Volume(a5),8(a4)
	else
	move P61_Volume(a5),P61_Shadow(a5)
	endc
	bra.w P61_contfxdone
	endc
	ifne P61_tpvs
P61_tpochvslide:
	move.b P61_Info(a5),d0
	sub.b d0,P61_Volume+1(a5)
	bpl.b .test
	move d7,P61_Volume(a5)
	ifeq p61fade
	move d7,8(a4)
	else
	move d7,P61_Shadow(a5)
	endc
	bra.b P61_toneport
.test:
	moveq #64,d0
	cmp P61_Volume(a5),d0
	bge.b .ncs
	move d0,P61_Volume(a5)
.ncs:
	ifeq p61fade
	move P61_Volume(a5),8(a4)
	else
	move P61_Volume(a5),P61_Shadow(a5)
	endc
	endc
	ifne P61_tp
P61_toneport:
	move P61_ToPeriod(a5),d0
	beq.w P61_contfxdone
	move P61_TPSpeed(a5),d1
	cmp P61_Period(a5),d0
	blt.b .topoup
	add d1,P61_Period(a5)
	cmp P61_Period(a5),d0
	bgt.b .setper
	move d0,P61_Period(a5)
	move d7,P61_ToPeriod(a5)
	move d0,6(a4)
	bra.b P61_contfxdone
.topoup:
	sub d1,P61_Period(a5)
	cmp P61_Period(a5),d0
	blt.b .setper
	move d0,P61_Period(a5)
	move d7,P61_ToPeriod(a5)
.setper:
	move P61_Period(a5),6(a4)
	else
	nop
	endc
	bra.w P61_contfxdone
	ifne P61_pu
P61_portup:
	moveq #0,d0
	move.b P61_Info(a5),d0
	ifne use1Fx
	cmp.b #$f0,d0
	bhs.b P61_contfxdone
	endc
	sub d0,P61_Period(a5)
	moveq #113,d0
	cmp P61_Period(a5),d0
	ble.b .skip
	move d0,P61_Period(a5)
	move d0,6(a4)
	bra.b P61_contfxdone
.skip:
	move P61_Period(a5),6(a4)
	bra.w P61_contfxdone
	endc
	ifne P61_pd
P61_portdwn:
	moveq #0,d0
	move.b P61_Info(a5),d0
	add d0,P61_Period(a5)
	cmp #856,P61_Period(a5)
	ble.b .skip
	move #856,d0
	move d0,P61_Period(a5)
	move d0,6(a4)
	bra.b P61_contfxdone
.skip:
	move P61_Period(a5),6(a4)
	endc
P61_contfxdone:
	ifne P61_il
	bsr.w P61_funk2
	endc
	lea Channel_Block_Size(a5),a5
	lea Custom_Block_Size(a4),a4
	dbf d5,P61_lopas
	ifeq split4
	cmp P61_speed2(PC),d4
	bne.w P61_ret2
P61_preplay2:
.pr:	ifle (channels-splitchans)
	printt "splitchans >=channels! Must be less."
	else
	moveq #(channels-splitchans)-1,d5
	lea P61_temp0(pc),a5
	bra.w P61_preplay
	endc
	else
CHANCPY:	macro
	movem.l (a0),d0-d4
	movem.l d0-d4,(a5)
	ifne P61_ft
	move.l P61_Volume(a0),P61_Volume(a5)
	else
	move.w P61_Volume(a0),P61_Volume(a5)
	endc
	ifne P61_sof
	move.w P61_Offset(a0),P61_Offset(a5)
	endc
	ifne P61_il
	move.l P61_Wave(a0),P61_Wave(a5)
	endc
	endm
P61_split4:
	move.w P61_speed2(PC),d5
	cmp.w d5,d4
	beq.b .pr2
	subq.w #1,d5
	cmp.w d5,d4
	beq.b .pr1
	subq.w #1,d5
	cmp.w d5,d4
	bne.w P61_ret2
.pr0:
	lea P61_temp0copy(PC),a5
	lea P61_temp0(PC),a0
	CHANCPY
	bra.w P61_preplay
.pr1:
	ifgt channels-1
	lea P61_temp1copy(PC),a5
	lea P61_temp1(PC),a0
	CHANCPY
	bra.w P61_preplay
	else
	rts
	endc
.pr2:
	lea P61_temp0copy(PC),a0
	lea P61_temp0(PC),a5
	CHANCPY
	ifgt channels-1
	lea P61_temp1copy(PC),a0
	lea P61_temp1(PC),a5
	CHANCPY
	endc
	ifgt channels-2
	lea P61_temp2(PC),a5
	bra.w P61_preplay
	else
	rts
	endc
	endc
P61_MyJpt:
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_all(PC)
	jmp P61_all2(PC)
	jmp P61_cmd(PC)
	jmp P61_cmd2(PC)
	jmp P61_cmd(PC)
	jmp P61_cmd2(PC)
	jmp P61_noote(PC)
	jmp P61_note2(PC)
	jmp P61_empty(PC)
	jmp P61_empty2(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_allS(PC)
	jmp P61_all2S(PC)
	jmp P61_cmdS(PC)
	jmp P61_cmd2S(PC)
	jmp P61_cmdS(PC)
	jmp P61_cmd2S(PC)
	jmp P61_noteS(PC)
	jmp P61_note2S(PC)
	jmp P61_emptyS(PC)
P61_empty2S:
	move d7,(a5)+
	move.b d7,(a5)+
P61_proccompS:
	move.b (a0)+,d1
	move.b d1,d0
	add.b d1,d1
	bpl.b P61_permexit
.b6set:	bcs.b .bit16
.bit8:	move.b d7,(a5)
	subq.l #3,a5
	and.w d4,d0
	move.b d0,P61_TempLen+1(a5)
	move.b (a0)+,d0
	move.l a0,P61_ChaPos(a5)
	sub.l d0,a0
.jedi1:	move.b (a0)+,d0
	moveq #-8,d1
	and.b d0,d1
	jmp P61_MyJpt+256(PC,d1.w)
.bit16:	move.b d7,(a5)
	subq.l #3,a5
	and.w d4,d0
	move.b d0,P61_TempLen+1(a5)
	ifeq opt020
	move.b (a0)+,d0
	lsl #8,d0
	move.b (a0)+,d0
	else
	move.w (a0)+,d0
	endc
	move.l a0,P61_ChaPos(a5)
	sub.l d0,a0
.jedi2:	move.b (a0)+,d0
	moveq #-8,d1
	and.b d0,d1
	jmp P61_MyJpt+256(PC,d1.w)
P61_Take:
	tst.b P61_TempLen+1(a5)
	bne.b P61_takeone
P61_TakeNorm:
	move.l P61_ChaPos(a5),a0
	move.b (a0)+,d0
	moveq #-8,d1
	and.b d0,d1
	jmp P61_MyJpt+256+4(PC,d1.w)
P61_takeone:
	subq.b #1,P61_TempLen+1(a5)
	move.l P61_TempPos(a5),a0
P61_Jedi:
	move.b (a0)+,d0
	moveq #-8,d1
	and.b d0,d1
	jmp P61_MyJpt+256(PC,d1.w)
P61_permexit:
	move.b d0,(a5)
	move.l a0,P61_ChaPos-3(a5)
	bra.w P61_permdko
	ifne P61_pde
P61_return:
	rts
	endc
	ifne P61_pde
P61_preplay:
	tst P61_pdflag-P61_cn(a3)
	bne.b P61_return
	else
P61_preplay:
	endc
	ifne P61_ft
	lea (P61_samples-16)-P61_cn(a3),a2
	endc
	moveq #$3f,d4
	moveq #-$10,d6
	moveq #0,d0
P61_loaps:
	ifne P61_pl
	lea P61_TData(a5),a1
	move 2(a5),(a1)+
	move.l P61_ChaPos(a5),(a1)+
	move.l P61_TempPos(a5),(a1)+
	move P61_TempLen(a5),(a1)
	endc
	moveq #-65,d1
	and.b P61_Pack(a5),d1
	add.b d1,d1
	beq.b P61_Take
	bcc.b P61_nodko
	addq #3,a5
	subq.b #1,(a5)
	bra.w P61_permdko
P61_nodko:
	move.b d7,P61_OnOff+1(a5)
	subq.b #1,P61_Pack(a5)
	addq #3,a5
	bra.w P61_koto
P61_empty:
	move d7,(a5)+
	move.b d7,(a5)+
	bra.w P61_ex
P61_all:
	move.b d0,(a5)+
	ifeq opt020
	move.b (a0)+,(a5)+
	move.b (a0)+,(a5)+
	else
	move (a0)+,(a5)+
	endc
	bra.w P61_ex
P61_cmd:
	moveq #$f,d1
	and d0,d1
	move d1,(a5)+
	move.b (a0)+,(a5)+
	bra.w P61_ex
P61_noote:
	moveq #7,d1
	and d0,d1
	lsl #8,d1
	move.b (a0)+,d1
	lsl #4,d1
	move d1,(a5)+
	move.b d7,(a5)+
	bra.w P61_ex
P61_emptyS:
	move d7,(a5)+
	move.b d7,(a5)+
	bra.w P61_exS
P61_allS:
	move.b d0,(a5)+
	ifeq opt020
	move.b (a0)+,(a5)+
	move.b (a0)+,(a5)+
	else
	move (a0)+,(a5)+
	endc
	bra.b P61_exS
P61_cmdS:
	moveq #$f,d1
	and d0,d1
	move d1,(a5)+
	move.b (a0)+,(a5)+
	bra.b P61_exS
P61_empty2:
	move d7,(a5)+
	move.b d7,(a5)+
	move.l a0,P61_ChaPos-3(a5)
	bra.b P61_permdko
P61_all2:
	move.b d0,(a5)+
	ifeq opt020
	move.b (a0)+,(a5)+
	move.b (a0)+,(a5)+
	else
	move (a0)+,(a5)+
	endc
	move.l a0,P61_ChaPos-3(a5)
	bra.b P61_permdko
P61_cmd2:
	moveq #$f,d1
	and d0,d1
	move d1,(a5)+
	move.b (a0)+,(a5)+
	move.l a0,P61_ChaPos-3(a5)
	bra.b P61_permdko
P61_note2:
	moveq #7,d1
	and d0,d1
	lsl #8,d1
	move.b (a0)+,d1
	lsl #4,d1
	move d1,(a5)+
	move.b d7,(a5)+
	move.l a0,P61_ChaPos-3(a5)
	bra.b P61_permdko
P61_note2S:
	moveq #7,d1
	and d0,d1
	lsl #8,d1
	move.b (a0)+,d1
	lsl #4,d1
	move d1,(a5)+
	move.b d7,(a5)+
	bra.w P61_proccompS
P61_all2S:
	move.b d0,(a5)+
	ifeq opt020
	move.b (a0)+,(a5)+
	move.b (a0)+,(a5)+
	else
	move (a0)+,(a5)+
	endc
	bra.w P61_proccompS
P61_cmd2S:
	moveq #$f,d1
	and d0,d1
	move d1,(a5)+
	move.b (a0)+,(a5)+
	bra.w P61_proccompS
P61_noteS:
	moveq #7,d1
	and d0,d1
	lsl #8,d1
	move.b (a0)+,d1
	lsl #4,d1
	move d1,(a5)+
	move.b d7,(a5)+
P61_exS:
	move.b (a0)+,(a5)
P61_ex:
	move.l a0,P61_TempPos-3(a5)
P61_permdko:
	move.w d6,P61_OnOff-3(a5)
	move -3(a5),d0
	and #$1f0,d0
	beq.b .koto
	ifne P61_ft
	lea (a2,d0),a1
	else
	lea (P61_samples-16)-P61_cn(a3),a1
	add d0,a1
	endc
	move.l a1,P61_Sample-3(a5)
	ifne P61_ft
	move.l P61_SampleVolume(a1),P61_Volume-3(a5)
	else
	move P61_SampleVolume(a1),P61_Volume-3(a5)
	endc
	ifne P61_il
	move.l P61_RepeatOffset(a1),P61_Wave-3(a5)
	endc
	ifne P61_sof
	move d7,P61_Offset-3(a5)
	endc
.koto:
P61_koto:
	ifeq split4
	lea Channel_Block_Size-3(a5),a5
	dbf d5,P61_loaps
	endc
P61_ret2:
	rts
	ifeq dupedec
P61_playtime:
	addq.w #1,(a3)
	ifeq split4
	ifgt splitchans
	moveq #splitchans-1,d5
	lea P61_temp0+Channel_Block_Size*(channels-splitchans)(PC),a5
	bsr P61_preplay
	endc
	else
	ifgt channels-3
	lea P61_temp3(PC),a5
	bsr P61_preplay
	endc
	endc
	endc
	ifgt (splitchans+split4)
	ifne dupedec
P61_MyJptB:
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_allB(PC)
	jmp P61_all2B(PC)
	jmp P61_cmdB(PC)
	jmp P61_cmd2B(PC)
	jmp P61_cmdB(PC)
	jmp P61_cmd2B(PC)
	jmp P61_nooteB(PC)
	jmp P61_note2B(PC)
	jmp P61_emptyB(PC)
	jmp P61_empty2B(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_allSB(PC)
	jmp P61_all2SB(PC)
	jmp P61_cmdSB(PC)
	jmp P61_cmd2SB(PC)
	jmp P61_cmdSB(PC)
	jmp P61_cmd2SB(PC)
	jmp P61_noteSB(PC)
	jmp P61_note2SB(PC)
	jmp P61_emptySB(PC)
	jmp P61_empty2SB(PC)
P61_empty2SB:
	move d7,(a5)+
	move.b d7,(a5)+
P61_proccompSB:
	move.b (a0)+,d1
	move.b d1,d0
	add.b d1,d1
	bpl.b P61_permexitB
.b6setB:	bcs.b .bit16B
.bit8B:	move.b d7,(a5)
	subq.l #3,a5
	and.w d4,d0
	move.b d0,P61_TempLen+1(a5)
	move.b (a0)+,d0
	move.l a0,P61_ChaPos(a5)
	sub.l d0,a0
.jedi1B:	move.b (a0)+,d0
	moveq #-8,d1
	and.b d0,d1
	jmp P61_MyJptB+256(PC,d1.w)
.bit16B:	move.b d7,(a5)
	subq.l #3,a5
	and.w d4,d0
	move.b d0,P61_TempLen+1(a5)
	ifeq opt020
	move.b (a0)+,d0
	lsl #8,d0
	move.b (a0)+,d0
	else
	move.w (a0)+,d0
	endc
	move.l a0,P61_ChaPos(a5)
	sub.l d0,a0
.jedi2B:	move.b (a0)+,d0
	moveq #-8,d1
	and.b d0,d1
	jmp P61_MyJptB+256(PC,d1.w)
P61_TakeB:
	tst.b P61_TempLen+1(a5)
	bne.b P61_takeoneB
P61_TakeNormB:
	move.l P61_ChaPos(a5),a0
	move.b (a0)+,d0
	moveq #-8,d1
	and.b d0,d1
	jmp P61_MyJptB+256+4(PC,d1.w)
P61_takeoneB:
	subq.b #1,P61_TempLen+1(a5)
	move.l P61_TempPos(a5),a0
P61_JediB:
	move.b (a0)+,d0
	moveq #-8,d1
	and.b d0,d1
	jmp P61_MyJptB+256(PC,d1.w)
P61_permexitB:
	move.b d0,(a5)
	move.l a0,P61_ChaPos-3(a5)
	bra.w P61_permdkoB
P61_playtime:
	addq.w #1,(a3)
	ifne split4
	ifgt channels-3
	lea P61_temp3(PC),a5
	else
	bra.w P61_playtimeCont
	endc
	else
	moveq #splitchans-1,d5
	lea P61_temp0+Channel_Block_Size*(channels-splitchans)(PC),a5
	endc
	ifne P61_pde
P61_preplayB:
	tst P61_pdflag-P61_cn(a3)
	bne.w P61_return
	else
P61_preplayB:
	endc
	moveq #$3f,d4
	moveq #-$10,d6
	moveq #0,d0
P61_loapsB:
	ifne P61_pl
	lea P61_TData(a5),a1
	move 2(a5),(a1)+
	move.l P61_ChaPos(a5),(a1)+
	move.l P61_TempPos(a5),(a1)+
	move P61_TempLen(a5),(a1)
	endc
	moveq #-65,d1
	and.b P61_Pack(a5),d1
	add.b d1,d1
	beq.b P61_TakeB
	bcc.b P61_nodkoB
	addq #3,a5
	subq.b #1,(a5)
	bra.w P61_permdkoB
P61_nodkoB:
	move.b d7,P61_OnOff+1(a5)
	subq.b #1,P61_Pack(a5)
	addq #3,a5
	bra.w P61_kotoB
P61_emptyB:
	move d7,(a5)+
	move.b d7,(a5)+
	bra.w P61_exB
P61_allB:
	move.b d0,(a5)+
	ifeq opt020
	move.b (a0)+,(a5)+
	move.b (a0)+,(a5)+
	else
	move (a0)+,(a5)+
	endc
	bra.w P61_exB
P61_cmdB:
	moveq #$f,d1
	and d0,d1
	move d1,(a5)+
	move.b (a0)+,(a5)+
	bra.w P61_exB
P61_nooteB:
	moveq #7,d1
	and d0,d1
	lsl #8,d1
	move.b (a0)+,d1
	lsl #4,d1
	move d1,(a5)+
	move.b d7,(a5)+
	bra.w P61_exB
P61_emptySB:
	move d7,(a5)+
	move.b d7,(a5)+
	bra.w P61_exSB
P61_allSB:
	move.b d0,(a5)+
	ifeq opt020
	move.b (a0)+,(a5)+
	move.b (a0)+,(a5)+
	else
	move (a0)+,(a5)+
	endc
	bra.b P61_exSB
P61_cmdSB:
	moveq #$f,d1
	and d0,d1
	move d1,(a5)+
	move.b (a0)+,(a5)+
	bra.b P61_exSB
P61_empty2B:
	move d7,(a5)+
	move.b d7,(a5)+
	move.l a0,P61_ChaPos-3(a5)
	bra.b P61_permdkoB
P61_all2B:
	move.b d0,(a5)+
	ifeq opt020
	move.b (a0)+,(a5)+
	move.b (a0)+,(a5)+
	else
	move (a0)+,(a5)+
	endc
	move.l a0,P61_ChaPos-3(a5)
	bra.b P61_permdkoB
P61_cmd2B:
	moveq #$f,d1
	and d0,d1
	move d1,(a5)+
	move.b (a0)+,(a5)+
	move.l a0,P61_ChaPos-3(a5)
	bra.b P61_permdkoB
P61_note2B:
	moveq #7,d1
	and d0,d1
	lsl #8,d1
	move.b (a0)+,d1
	lsl #4,d1
	move d1,(a5)+
	move.b d7,(a5)+
	move.l a0,P61_ChaPos-3(a5)
	bra.b P61_permdkoB
P61_note2SB:
	moveq #7,d1
	and d0,d1
	lsl #8,d1
	move.b (a0)+,d1
	lsl #4,d1
	move d1,(a5)+
	move.b d7,(a5)+
	bra.w P61_proccompSB
P61_all2SB:
	move.b d0,(a5)+
	ifeq opt020
	move.b (a0)+,(a5)+
	move.b (a0)+,(a5)+
	else
	move (a0)+,(a5)+
	endc
	bra.w P61_proccompSB
P61_cmd2SB:
	moveq #$f,d1
	and d0,d1
	move d1,(a5)+
	move.b (a0)+,(a5)+
	bra.w P61_proccompSB
P61_noteSB:
	moveq #7,d1
	and d0,d1
	lsl #8,d1
	move.b (a0)+,d1
	lsl #4,d1
	move d1,(a5)+
	move.b d7,(a5)+
P61_exSB:
	move.b (a0)+,(a5)
P61_exB:
	move.l a0,P61_TempPos-3(a5)
P61_permdkoB:
	move.w d6,P61_OnOff-3(a5)
	move -3(a5),d0
	and #$1f0,d0
	beq.b .kotoB
	lea (P61_samples-16)-P61_cn(a3),a1
	add d0,a1
	move.l a1,P61_Sample-3(a5)
	ifne P61_ft
	move.l P61_SampleVolume(a1),P61_Volume-3(a5)
	else
	move P61_SampleVolume(a1),P61_Volume-3(a5)
	endc
	ifne P61_il
	move.l P61_RepeatOffset(a1),P61_Wave-3(a5)
	endc
	ifne P61_sof
	move d7,P61_Offset-3(a5)
	endc
.kotoB:
P61_kotoB:
	ifeq split4
	lea Channel_Block_Size-3(a5),a5
	dbf d5,P61_loapsB
	endc
	endc
	endc
P61_playtimeCont:
	ifne P61_pde
	tst P61_pdelay-P61_cn(a3)
	beq.b .djdj
	subq #1,P61_pdelay-P61_cn(a3)
	bne.w P61_delay
	tst P61_speedis1-P61_cn(a3)
	bne.w P61_delay
	move d7,P61_pdflag-P61_cn(a3)
	bra.w P61_delay
.djdj:
	move d7,P61_pdflag-P61_cn(a3)
	endc
	ifne suppF01
	tst P61_speedis1-P61_cn(a3)
	beq.b .mo
	lea P61_temp0(pc),a5
	moveq #channels-1,d5
.chl:	bsr.w P61_preplay
	ifeq split4
	lea Channel_Block_Size-3(a5),a5
	dbf d5,.chl
	endc
.mo:
	endc
	ifeq copdma&nowaveforms
	ifeq p61system
	lea P61_dmason(pc),a1
	move.l P61_vektori(pc),a0
	move.l a1,(a0)
	move.b #$f0,$bfd600
	move.b #$01,$bfd700
	move.b #$19,$bfdf00
	else
	move #1,P61_server-P61_cn(a3)
	move.l P61_craddr+4(pc),a1
	move.b #$f0,(a1)
	move.b #1,$100(a1)
	endc
	endc
	moveq #0,d4
	moveq #channels-1,d5
	lea P61_temp0(pc),a5
	
	bra.w P61_loscont
	
	ifne p61bigjtab
	rept 16*15
	dc.w P61_nocha-.j
	endr
	endc

	dc P61_fxdone-.j		;$0xx
	ifne use1Fx
	dc P61_Trigger-.j
	else
	dc P61_fxdone-.j
	endc

	dc P61_fxdone-.j
	ifne P61_tp
	dc P61_settoneport-.j
	else
	dc P61_fxdone-.j
	endc

	ifne P61_vib
	dc P61_vibrato-.j
	else
	dc P61_fxdone-.j
	endc

	ifne P61_tpvs
	dc P61_toponochange-.j
	else
	dc P61_fxdone-.j
	endc

	dc P61_fxdone-.j
	ifne P61_tre
	dc P61_settremo-.j
	else
	dc P61_fxdone-.j
	endc

	dc P61_fxdone-.j
	ifne P61_sof
	dc P61_sampleoffse-.j
	else
	dc P61_fxdone-.j
	endc

	dc P61_fxdone-.j
	ifne P61_pj
	dc P61_posjmp-.j
	else
	dc P61_fxdone-.j
	endc

	ifne P61_vl
	dc P61_volum-.j
	else
	dc P61_fxdone-.j
	endc

	ifne P61_pb
	dc P61_pattbreak-.j
	else
	dc P61_fxdone-.j
	endc

	ifne P61_ec
	dc P61_ecommands-.j
	else
	dc P61_fxdone-.j
	endc

	ifne P61_sd
	dc P61_cspeed-.j
	else
	dc P61_fxdone-.j
	endc
.j:
P61_jtab:
P61_los:
	lea Custom_Block_Size(a4),a4
	lea Channel_Block_Size(a5),a5
P61_loscont:
	move P61_OnOff(a5),d0
	ifeq p61bigjtab
	tst.b d0
	beq.s P61_nocha
	endc

	ifne useinsnum
	;P61_setCurINS:		; ## KONEY ##
	MOVE.W	#P61_CH3_INST-P61_cn,D2
	ADD.W	D5,D2		; D5 = TRACK# 3-0
	ADD.W	D5,D2		; TWO ADDS ARE FASTER THAN MULU :)
	MOVE.W	P61_SN_Note(A5),(A3,D2.W)
	endc			; ## KONEY ##

	or (a5),d0
	add d0,d0
	move P61_jtab(PC,d0),d0
	jmp P61_jtab(PC,d0)
P61_fxdone:
	moveq #$7e,d0
	and.b (a5),d0
	beq.b P61_nocha
	ifne P61_vib
	move.b d7,P61_VibPos(a5)
	endc
	ifne P61_tre
	move.b d7,P61_TrePos(a5)
	endc
	ifne P61_ft
	add P61_Fine(a5),d0
	endc
	move d0,P61_Note(a5)
	move P61_periods-P61_cn(a3,d0),P61_Period(a5)
P61_zample:
	ifne P61_sof
	tst P61_Offset(a5)
	bne.w P61_pek
	endc
	or P61_DMABit(a5),d4
	move.l P61_Sample(a5),a1
	ifeq oscillo
	move.l (a1)+,(a4)
	move (a1),4(a4)
	else
	moveq #0,d1
	move.l (a1)+,d0
	move (a1),d1
	move.l d0,(a4)
	move.w d1,4(a4)
	subq.w #1,d1
	addq.l #1,d1
	lsl.l #2,d0
	move.l d0,P61_oscptr(a5)
	move.w d7,P61_oscptrrem(a5)
	lsl.l #3,d1
	add.l d0,d1
	move.l d1,P61_oscptrWrap(a5)
	endc
P61_nocha:
	ifeq p61fade
	move.l P61_Period(a5),6(a4)
	else
	move P61_Period(a5),6(a4)
	move P61_Volume(a5),P61_Shadow(a5)
	endc
P61_skip:
	ifne P61_il
	bsr.w P61_funk2
	endc
	DBF d5,P61_los
P61_chansdone:
	ifne clraudxdat
	move.w d4,d5
	lsl.w #3,d5
	add.b d5,d5
	bpl.b .noch3
	move.w d7,$da-C(A6)
.noch3:	add.b d5,d5
	bpl.b .noch2vi
	move.w d7,$ca-C(A6)
.noch2:	add.b d5,d5
	bpl.b .noch1
	move.w d7,$ba-C(A6)
.noch1:	add.b d5,d5
	bpl.b .noch0
	move.w d7,$aa-C(A6)
.noch0:
	endc
	move d4,$96-C(a6)
	ifne visuctrs
	lea P61_visuctr0+channels*2(PC),a0
	moveq #channels-1,d5
.visul:	subq.w #2,a0
	btst d5,d4
	beq.s .noctr0
	move.w d7,(a0)
.noctr0:
	dbf d5,.visul
	endc
	ifne copdma
	move.l p61_DMApokeAddr(PC),a0
	move.b d4,(a0)
	endc
	move.b d4,P61_dma+1-P61_cn(a3)
	ifne suppF01
	ifne nowaveforms
	move.b d4,P61_NewDMA+1-P61_cn(a3)
	endc
	move.w d7,(a3)
	ifne P61_pl
	tst.b P61_plflag+1-P61_cn(a3)
	beq.b P61_ohittaa
	lea P61_temp0(pc),a1
	lea P61_looppos(pc),a0
	moveq #channels-1,d0
.talt:
	move.b 1(a0),3(a1)
	addq.l #2,a0
	move.l (a0)+,P61_ChaPos(a1)
	move.l (a0)+,P61_TempPos(a1)
	move (a0)+,P61_TempLen(a1)
	lea Channel_Block_Size(a1),a1
	dbf d0,.talt
	move P61_plrowpos(pc),P61_rowpos-P61_cn(a3)
	move.b d7,P61_plflag+1-P61_cn(a3)
	moveq #63,d0
	sub P61_rowpos-P61_cn(a3),d0
	move d0,P61_CRow-P61_cn(a3)
	rts
P61_ohittaa:
	endc
	subq #1,P61_rowpos-P61_cn(a3)
	bpl.b P61_nonewpatt
P61_nextpattern:
	ifne P61_pl
	move d7,P61_plflag-P61_cn(a3)
	endc
	move.l P61_patternbase(pc),a0
	moveq #63,d0
	move d0,P61_rowpos-P61_cn(a3)
	move d7,P61_CRow-P61_cn(a3)
	move.l P61_spos(pc),a1
	addq #1,P61_Pos-P61_cn(a3)
	move.b (a1)+,d0
	bpl.b P61_dk
	move.l P61_possibase(pc),a1
	move.b (a1)+,d0
	move d7,P61_Pos-P61_cn(a3)
P61_dk:
	move.l a1,P61_spos-P61_cn(a3)
	move d0,P61_Patt-P61_cn(a3)
	lsl #3,d0
	move.l P61_positionbase(pc),a1
	add.l d0,a1
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp0-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp1-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp2-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp3-P61_cn(a3)
	rts
P61_nonewpatt:
	moveq #63,d0
	sub P61_rowpos-P61_cn(a3),d0
	move d0,P61_CRow-P61_cn(a3)
	endc
	rts
	ifne use1Fx
P61_Trigger:
	move.b	P61_Info(a5),d0
	cmp.b	#$f0,d0
	blo.w	P61_fxdone
	; ## KONEY FIX ##
	MOVEQ	#$F,D0			; Taken from P61_sete8
	AND.B	P61_Info(A5),D0		; now returns value
	MOVE.W	D0,P61_1F-P61_cn(A3)	; before only 1F
	; ## KONEY FIX ##
	;move.w	d0,P61_PTrig+1-P61_cn(a3)	; Original line of code
	bra.w	P61_fxdone
	endc
	ifne P61_tp
P61_settoneport:
	move.b P61_Info(a5),d0
	beq.b P61_toponochange
	move.b d0,P61_TPSpeed+1(a5)
P61_toponochange:
	moveq #$7e,d0
	and.b (a5),d0
	beq.w P61_nocha
	add P61_Fine(a5),d0
	move d0,P61_Note(a5)
	move P61_periods-P61_cn(a3,d0),P61_ToPeriod(a5)
	bra.w P61_nocha
	endc
	ifne P61_sof
P61_sampleoffse:
	moveq #0,d1
	move #$ff00,d1
	and 2(a5),d1
	bne.b .deq
	move P61_LOffset(a5),d1
.deq:
	move d1,P61_LOffset(a5)
	add d1,P61_Offset(a5)
	moveq #$7e,d0
	and.b (a5),d0
	beq.w P61_nocha
	move P61_Offset(a5),d2
	add d1,P61_Offset(a5)
	move d2,d1
	ifne P61_vib
	move.b d7,P61_VibPos(a5)
	endc
	ifne P61_tre
	move.b d7,P61_TrePos(a5)
	endc
	ifne P61_ft
	add P61_Fine(a5),d0
	endc
	move d0,P61_Note(a5)
	move P61_periods-P61_cn(a3,d0),P61_Period(a5)
	bra.b P61_hup
P61_pek:
	moveq #0,d1
	move P61_Offset(a5),d1
P61_hup:
	or P61_DMABit(a5),d4
	move.l P61_Sample(a5),a1
	move.l (a1)+,d0
	add.l d1,d0
	move.l d0,(a4)
	lsr #1,d1
	move (a1),d6
	sub d1,d6
	bpl.b P61_offok
	move.l -4(a1),(a4)
	moveq #1,d6
P61_offok:
	move d6,4(a4)
	ifne oscillo
	moveq #0,d1
	move.w d6,d1
	subq.w #1,d1
	addq.l #1,d1
	lsl.l #2,d0
	move.l d0,P61_oscptr(a5)
	move.w d7,P61_oscptrrem(a5)
	lsl.l #3,d1
	add.l d0,d1
	move.l d1,P61_oscptrWrap(a5)
	endc
	bra.w P61_nocha
	endc
	ifne P61_vl
P61_volum:
	move.b P61_Info(a5),P61_Volume+1(a5)
	bra.w P61_fxdone
	endc
	ifne P61_pj
P61_posjmp:
	moveq #0,d0
	move.b P61_Info(a5),d0
	ifeq optjmp
	cmp P61_slen-P61_cn(a3),d0
	blo.b .e
	moveq #0,d0
	endc
.e:	move d0,P61_Pos-P61_cn(a3)
	add.l P61_possibase(pc),d0
	move.l d0,P61_spos-P61_cn(a3)
	endc
	ifne P61_pb
P61_pattbreak:
	moveq #64,d0
	move d0,P61_rowpos-P61_cn(a3)
	move d7,P61_CRow-P61_cn(a3)
P61_Bc:	move.l P61_spos(pc),a1
	move.l P61_patternbase(pc),a0
	addq #1,P61_Pos-P61_cn(a3)
	move.b (a1)+,d0
	bpl.b P61_dk2
	move.l P61_possibase(pc),a1
	move.b (a1)+,d0
	move d7,P61_Pos-P61_cn(a3)
P61_dk2:
	move.l a1,P61_spos-P61_cn(a3)
	move.l P61_positionbase(pc),a1
	move d0,P61_Patt-P61_cn(a3)
	lsl #3,d0
	add.l d0,a1
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp0-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp1-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp2-P61_cn(a3)
	moveq #0,d0
	move.w (a1)+,d0
	add.l a0,d0
	move.l d0,P61_ChaPos+P61_temp3-P61_cn(a3)
	bra.w P61_fxdone
	endc
	ifne P61_vib
P61_vibrato:
	move.b P61_Info(a5),d0
	beq.w P61_fxdone
	move.b d0,d1
	move.b P61_VibCmd(a5),d2
	and.b #$f,d0
	beq.b P61_vibskip
	and.b #$f0,d2
	or.b d0,d2
P61_vibskip:
	and.b #$f0,d1
	beq.b P61_vibskip2
	and.b #$f,d2
	or.b d1,d2
P61_vibskip2:
	move.b d2,P61_VibCmd(a5)
	bra.w P61_fxdone
	endc
	ifne P61_tre
P61_settremo:
	move.b P61_Info(a5),d0
	beq.w P61_fxdone
	move.b d0,d1
	move.b P61_TreCmd(a5),d2
	moveq #$f,d3
	and.b d3,d0
	beq.b P61_treskip
	and.b #$f0,d2
	or.b d0,d2
P61_treskip:
	and.b #$f0,d1
	beq.b P61_treskip2
	and.b d3,d2
	or.b d1,d2
P61_treskip2:
	move.b d2,P61_TreCmd(a5)
	bra.w P61_fxdone
	endc
	ifne P61_ec
P61_ecommands:
	move.b P61_Info(a5),d0
	and.w #$f0,d0
	lsr #3,d0
	move P61_etab(pc,d0),d0
	jmp P61_etab(pc,d0)
P61_etab:
	ifne P61_fi
	dc P61_filter-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	ifne P61_fsu
	dc P61_fineup-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	ifne P61_fsd
	dc P61_finedwn-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	dc P61_fxdone-P61_etab
	dc P61_fxdone-P61_etab
	ifne P61_sft
	dc P61_setfinetune-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	ifne P61_pl
	dc P61_patternloop-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	dc P61_fxdone-P61_etab
	ifne P61_timing
	dc P61_sete8-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	ifne P61_rt
	dc P61_setretrig-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	ifne P61_fvu
	dc P61_finevup-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	ifne P61_fvd
	dc P61_finevdwn-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	dc P61_fxdone-P61_etab
	ifne P61_nd
	dc P61_ndelay-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	ifne P61_pde
	dc P61_pattdelay-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	ifne P61_il
	dc P61_funk-P61_etab
	else
	dc P61_fxdone-P61_etab
	endc
	endc
	ifne P61_fi
P61_filter:
	move.b P61_Info(a5),d0
	and.b #$fd,$bfe001
	or.b d0,$bfe001
	bra.w P61_fxdone
	endc
	ifne P61_fsu
P61_fineup:
	P61_getnote
	moveq #$f,d0
	and.b P61_Info(a5),d0
	sub d0,P61_Period(a5)
	moveq #113,d0
	cmp P61_Period(a5),d0
	ble.b .jup
	move d0,P61_Period(a5)
.jup:
	moveq #$7e,d0
	and.b (a5),d0
	bne.w P61_zample
	bra.w P61_nocha
	endc
	ifne P61_fsd
P61_finedwn:
	P61_getnote
	moveq #$f,d0
	and.b P61_Info(a5),d0
	add d0,P61_Period(a5)
	cmp #856,P61_Period(a5)
	ble.b .jup
	move #856,P61_Period(a5)
.jup:	moveq #$7e,d0
	and.b (a5),d0
	bne.w P61_zample
	bra.w P61_nocha
	endc
	ifne P61_sft
P61_setfinetune:
	moveq #$f,d0
	and.b P61_Info(a5),d0
	ifeq opt020
	add d0,d0
	move P61_mulutab(pc,d0),P61_Fine(a5)
	else
	move P61_mulutab(pc,d0*2),P61_Fine(a5)
	endc
	bra.w P61_fxdone
P61_mulutab:
	dc 0,74,148,222,296,370,444,518,592,666,740,814,888,962,1036,1110
	endc
	ifne P61_pl
P61_patternloop:
	moveq #$f,d0
	and.b P61_Info(a5),d0
	beq.b P61_setloop
	tst.b P61_plflag-P61_cn(a3)
	bne.b P61_noset
	move d0,P61_plcount-P61_cn(a3)
	st.b P61_plflag-P61_cn(a3)
P61_noset:
	tst P61_plcount-P61_cn(a3)
	bne.b P61_looppaa
	move.b d7,P61_plflag-P61_cn(a3)
	bra.w P61_fxdone
P61_looppaa:
	st.b P61_plflag+1-P61_cn(a3)
	subq #1,P61_plcount-P61_cn(a3)
	bra.w P61_fxdone
P61_setloop:
	tst.b P61_plflag-P61_cn(a3)
	bne.w P61_fxdone
	move P61_rowpos(pc),P61_plrowpos-P61_cn(a3)
	lea P61_temp0+P61_TData(pc),a1
	lea P61_looppos(pc),a0
	moveq #channels-1,d0
.talt:
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1),(a0)+
	lea Channel_Block_Size-8(a1),a1
	dbf d0,.talt
	bra.w P61_fxdone
	endc
	ifne P61_fvu
P61_finevup:
	moveq #$f,d0
	and.b P61_Info(a5),d0
	add d0,P61_Volume(a5)
	moveq #64,d0
	cmp P61_Volume(a5),d0
	bge.w P61_fxdone
	move d0,P61_Volume(a5)
	bra.w P61_fxdone
	endc
	ifne P61_fvd
P61_finevdwn:
	moveq #$f,d0
	and.b P61_Info(a5),d0
	sub d0,P61_Volume(a5)
	bpl.w P61_fxdone
	move d7,P61_Volume(a5)
	bra.w P61_fxdone
	endc
	ifne P61_timing
P61_sete8:
	moveq #$f,d0
	and.b P61_Info(a5),d0
	move d0,P61_E8-P61_cn(a3)
	bra.w P61_fxdone
	endc
	ifne P61_rt
P61_setretrig:
	moveq #$f,d0
	and.b P61_Info(a5),d0
	move d0,P61_RetrigCount(a5)
	bra.w P61_fxdone
	endc
	ifne P61_nd
P61_ndelay:
	moveq #$7e,d0
	and.b (a5),d0
	beq.w P61_skip
	ifne P61_vib
	move.b d7,P61_VibPos(a5)
	endc
	ifne P61_tre
	move.b d7,P61_TrePos(a5)
	endc
	ifne P61_ft
	add P61_Fine(a5),d0
	endc
	move d0,P61_Note(a5)
	move P61_periods-P61_cn(a3,d0),P61_Period(a5)
	ifeq p61fade
	move P61_Volume(a5),8(a4)
	else
	move P61_Volume(a5),P61_Shadow(a5)
	endc
	bra.w P61_skip
	endc
	ifne P61_pde
P61_pattdelay:
	moveq #$f,d0
	and.b P61_Info(a5),d0
	move d0,P61_pdelay-P61_cn(a3)
	st P61_pdflag-P61_cn(a3)
	bra.w P61_fxdone
	endc
	ifne P61_sd
P61_cspeed:
	moveq #0,d0
	move.b P61_Info(a5),d0
	ifne p61cia
	tst P61_Tempo-P61_cn(a3)
	beq.b P61_VBlank
	cmp.b #32,d0
	bhs.b P61_STempo
	endc
P61_VBlank:
	cmp.b #1,d0
	beq.b P61_jkd
	move.b d0,P61_speed+1-P61_cn(a3)
	subq.b #1,d0
	move.b d0,P61_speed2+1-P61_cn(a3)
	move d7,P61_speedis1-P61_cn(a3)
	bra.w P61_fxdone
P61_jkd:
	move.b d0,P61_speed+1-P61_cn(a3)
	move.b d0,P61_speed2+1-P61_cn(a3)
	st P61_speedis1-P61_cn(a3)
	bra.w P61_fxdone
	ifne p61cia
P61_STempo:
	move.l P61_timer(pc),d1
	divu d0,d1
	move d1,P61_thi2-P61_cn(a3)
	sub #$1f0*2,d1
	move d1,P61_thi-P61_cn(a3)
	ifeq p61system
	move P61_thi2-P61_cn(a3),d1
	move.b d1,$bfd400
	lsr #8,d1
	move.b d1,$bfd500
	endc
	bra P61_fxdone
	endc
	endc
	ifne P61_vbvs
P61_vibochvslide:
	move.b P61_Info(a5),d0
	sub.b d0,P61_Volume+1(a5)
	bpl.b P61_test62
	move d7,P61_Volume(a5)
	ifeq p61fade
	move d7,8(a4)
	else
	move d7,P61_Shadow(a5)
	endc
	bra.b P61_vib2
P61_test62:
	moveq #64,d0
	cmp P61_Volume(a5),d0
	bge.b .ncs2
	move d0,P61_Volume(a5)
.ncs2:
	ifeq p61fade
	move P61_Volume(a5),8(a4)
	else
	move P61_Volume(a5),P61_Shadow(a5)
	endc
	endc
	ifne P61_vib
P61_vib2:
	move #$f00,d0
	move P61_VibCmd(a5),d1
	and d1,d0
	lsr #3,d0
	lsr #2,d1
	and #$1f,d1
	add d1,d0
	move P61_Period(a5),d1
	moveq #0,d2
	move.b P61_vibtab(pc,d0),d2
	tst.b P61_VibPos(a5)
	bmi.b .vibneg
	add d2,d1
	bra.b P61_vib4
.vibneg:	sub d2,d1
P61_vib4:
	move d1,6(a4)
	move.b P61_VibCmd(a5),d0
	lsr.b #2,d0
	and #$3c,d0
	add.b d0,P61_VibPos(a5)
	bra.w P61_contfxdone
	endc
	ifne P61_tre
P61_tremo:
	move #$f00,d0
	move P61_TreCmd(a5),d1
	and d1,d0
	lsr #3,d0
	lsr #2,d1
	and #$1f,d1
	add d1,d0
	move P61_Volume(a5),d1
	moveq #0,d2
	move.b P61_vibtab(pc,d0),d2
	tst.b P61_TrePos(a5)
	bmi.b .treneg
	add d2,d1
	cmp #64,d1
	ble.b P61_tre4
	moveq #64,d1
	bra.b P61_tre4
.treneg:
	sub d2,d1
	bpl.b P61_tre4
	moveq #0,d1
P61_tre4:
	ifeq p61fade
	move d1,8(a4)
	else
	move d1,P61_Shadow(a5)
	endc
	move.b P61_TreCmd(a5),d0
	lsr.b #2,d0
	and #$3c,d0
	add.b d0,P61_TrePos(a5)
	bra.w P61_contfxdone
	endc
	ifne (P61_vib+P61_tre)
P61_vibtab:
	dc.b $00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$01,$01
	dc.b $01,$01,$01,$01,$01,$01,$01,$01
	dc.b $01,$01,$01,$01,$01,$01,$01,$01
	dc.b $01,$01,$01,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$01,$01,$01,$02,$02
	dc.b $02,$03,$03,$03,$03,$03,$03,$03
	dc.b $03,$03,$03,$03,$03,$03,$03,$03
	dc.b $02,$02,$02,$01,$01,$01,$00,$00
	dc.b $00,$00,$01,$01,$02,$02,$03,$03
	dc.b $04,$04,$04,$05,$05,$05,$05,$05
	dc.b $05,$05,$05,$05,$05,$05,$04,$04
	dc.b $04,$03,$03,$02,$02,$01,$01,$00
	dc.b $00,$00,$01,$02,$03,$03,$04,$05
	dc.b $05,$06,$06,$07,$07,$07,$07,$07
	dc.b $07,$07,$07,$07,$07,$07,$06,$06
	dc.b $05,$05,$04,$03,$03,$02,$01,$00
	dc.b $00,$00,$01,$02,$03,$04,$05,$06
	dc.b $07,$07,$08,$08,$09,$09,$09,$09
	dc.b $09,$09,$09,$09,$09,$08,$08,$07
	dc.b $07,$06,$05,$04,$03,$02,$01,$00
	dc.b $00,$01,$02,$03,$04,$05,$06,$07
	dc.b $08,$09,$09,$0a,$0b,$0b,$0b,$0b
	dc.b $0b,$0b,$0b,$0b,$0b,$0a,$09,$09
	dc.b $08,$07,$06,$05,$04,$03,$02,$01
	dc.b $00,$01,$02,$04,$05,$06,$07,$08
	dc.b $09,$0a,$0b,$0c,$0c,$0d,$0d,$0d
	dc.b $0d,$0d,$0d,$0d,$0c,$0c,$0b,$0a
	dc.b $09,$08,$07,$06,$05,$04,$02,$01
	dc.b $00,$01,$03,$04,$06,$07,$08,$0a
	dc.b $0b,$0c,$0d,$0e,$0e,$0f,$0f,$0f
	dc.b $0f,$0f,$0f,$0f,$0e,$0e,$0d,$0c
	dc.b $0b,$0a,$08,$07,$06,$04,$03,$01
	dc.b $00,$01,$03,$05,$06,$08,$09,$0b
	dc.b $0c,$0d,$0e,$0f,$10,$11,$11,$11
	dc.b $11,$11,$11,$11,$10,$0f,$0e,$0d
	dc.b $0c,$0b,$09,$08,$06,$05,$03,$01
	dc.b $00,$01,$03,$05,$07,$09,$0b,$0c
	dc.b $0e,$0f,$10,$11,$12,$13,$13,$13
	dc.b $13,$13,$13,$13,$12,$11,$10,$0f
	dc.b $0e,$0c,$0b,$09,$07,$05,$03,$01
	dc.b $00,$02,$04,$06,$08,$0a,$0c,$0d
	dc.b $0f,$10,$12,$13,$14,$14,$15,$15
	dc.b $15,$15,$15,$14,$14,$13,$12,$10
	dc.b $0f,$0d,$0c,$0a,$08,$06,$04,$02
	dc.b $00,$02,$04,$06,$09,$0b,$0d,$0f
	dc.b $10,$12,$13,$15,$16,$16,$17,$17
	dc.b $17,$17,$17,$16,$16,$15,$13,$12
	dc.b $10,$0f,$0d,$0b,$09,$06,$04,$02
	dc.b $00,$02,$04,$07,$09,$0c,$0e,$10
	dc.b $12,$14,$15,$16,$17,$18,$19,$19
	dc.b $19,$19,$19,$18,$17,$16,$15,$14
	dc.b $12,$10,$0e,$0c,$09,$07,$04,$02
	dc.b $00,$02,$05,$08,$0a,$0d,$0f,$11
	dc.b $13,$15,$17,$18,$19,$1a,$1b,$1b
	dc.b $1b,$1b,$1b,$1a,$19,$18,$17,$15
	dc.b $13,$11,$0f,$0d,$0a,$08,$05,$02
	dc.b $00,$02,$05,$08,$0b,$0e,$10,$12
	dc.b $15,$17,$18,$1a,$1b,$1c,$1d,$1d
	dc.b $1d,$1d,$1d,$1c,$1b,$1a,$18,$17
	dc.b $15,$12,$10,$0e,$0b,$08,$05,$02
	endc
	ifne P61_il
P61_funk:
	moveq #$f,d0
	and.b P61_Info(a5),d0
	move.b d0,P61_Funkspd(a5)
	bra.w P61_fxdone
P61_funk2:
	moveq #0,d0
	move.b P61_Funkspd(a5),d0
	beq.b P61_funkend
	move.b P61_FunkTable(pc,d0),d0
	add.b d0,P61_Funkoff(a5)
	bpl.b P61_funkend
	move.b d7,P61_Funkoff(a5)
	move.l P61_Sample(a5),a1
	move.l P61_RepeatOffset(a1),d1
	move P61_RepeatLength(a1),d0
	add.l d0,d0
	add.l d1,d0
	move.l P61_Wave(a5),a0
	addq.l #1,a0
	cmp.l d0,a0
	blo.b P61_funkok
	move.l d1,a0
P61_funkok:
	move.l a0,P61_Wave(a5)
	not.b (a0)
P61_funkend:
	rts
P61_FunkTable:
	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	endc
	ifeq copdma
P61_dmason:
	ifeq p61system
	tst.b $bfdd00
	move #$2000,$dff09c
	move #$2000,$dff09c
	ifeq nowaveforms
	move.b #$19,$bfdf00
	move.l a0,-(sp)
	move.l P61_vektori(pc),a0
	move.l P61_intaddr(pc),(a0)
	move.l (sp)+,a0
	endc
	move P61_dma(pc),$dff096
	nop
	rte
	else
	move P61_dma(pc),$dff096
	lea P61_server(pc),a3
	addq #1,(a3)
	move.l P61_craddr(pc),a0
	move.b #$19,(a0)
	bra P61_ohi
	endc
	endc
	ifeq nowaveforms
P61_setrepeat:
	ifeq p61system
	tst.b $bfdd00
	movem.l a0/a1,-(sp)
	lea $dff0a0,a1
	move #$2000,-4(a1)
	move #$2000,-4(a1)
	else
	lea $dff0a0,a1
	endc
	move.l P61_Sample+P61_temp0(pc),a0
	addq.l #6,a0
	move.l (a0)+,(a1)+
	move (a0),(a1)
	ifgt channels-1
	move.l P61_Sample+P61_temp1(pc),a0
	addq.l #6,a0
	move.l (a0)+,12(a1)
	move (a0),16(a1)
	endc
	ifgt channels-2
	move.l P61_Sample+P61_temp2(pc),a0
	addq.l #6,a0
	move.l (a0)+,28(a1)
	move (a0),32(a1)
	endc
	ifgt channels-3
	move.l P61_Sample+P61_temp3(pc),a0
	addq.l #6,a0
	move.l (a0)+,44(a1)
	move (a0),48(a1)
	endc
	ifne p61system
	ifne p61cia
	lea P61_server(pc),a3
	clr (a3)
	move.l P61_craddr+4(pc),a0
	move.b P61_tlo(pc),(a0)
	move.b P61_thi(pc),$100(a0)
	endc
	bra P61_ohi
	endc
	ifeq p61system
	ifne p61cia
	move.l P61_vektori(pc),a0
	move.l P61_tintti(pc),(a0)
	endc
	movem.l (sp)+,a0/a1
	nop
	rte
	endc
	endc
P61_temp0:
	dcb.b Channel_Block_Size-2,0
	dc 1
P61_temp1:
	dcb.b Channel_Block_Size-2,0
	dc 2
P61_temp2:
	dcb.b Channel_Block_Size-2,0
	dc 4
P61_temp3:
	dcb.b Channel_Block_Size-2,0
	dc 8
	ifne split4
P61_temp0copy: dcb.b P61_Wave+4,0
P61_temp1copy: dcb.b P61_Wave+4,0
	endc
P61_cn:
	dc 0
P61_periods:
	ifne P61_ft
	dc.w $0358,$0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0352,$0352,$0322
	dc.w $02f5,$02cb,$02a2,$027d,$0259,$0237,$0217,$01f9
	dc.w $01dd,$01c2,$01a9,$0191,$017b,$0165,$0151,$013e
	dc.w $012c,$011c,$010c,$00fd,$00ef,$00e1,$00d5,$00c9
	dc.w $00bd,$00b3,$00a9,$009f,$0096,$008e,$0086,$007e
	dc.w $0077,$0071,$034c,$034c,$031c,$02f0,$02c5,$029e
	dc.w $0278,$0255,$0233,$0214,$01f6,$01da,$01bf,$01a6
	dc.w $018e,$0178,$0163,$014f,$013c,$012a,$011a,$010a
	dc.w $00fb,$00ed,$00e0,$00d3,$00c7,$00bc,$00b1,$00a7
	dc.w $009e,$0095,$008d,$0085,$007d,$0076,$0070,$0346
	dc.w $0346,$0317,$02ea,$02c0,$0299,$0274,$0250,$022f
	dc.w $0210,$01f2,$01d6,$01bc,$01a3,$018b,$0175,$0160
	dc.w $014c,$013a,$0128,$0118,$0108,$00f9,$00eb,$00de
	dc.w $00d1,$00c6,$00bb,$00b0,$00a6,$009d,$0094,$008c
	dc.w $0084,$007d,$0076,$006f,$0340,$0340,$0311,$02e5
	dc.w $02bb,$0294,$026f,$024c,$022b,$020c,$01ef,$01d3
	dc.w $01b9,$01a0,$0188,$0172,$015e,$014a,$0138,$0126
	dc.w $0116,$0106,$00f7,$00e9,$00dc,$00d0,$00c4,$00b9
	dc.w $00af,$00a5,$009c,$0093,$008b,$0083,$007c,$0075
	dc.w $006e,$033a,$033a,$030b,$02e0,$02b6,$028f,$026b
	dc.w $0248,$0227,$0208,$01eb,$01cf,$01b5,$019d,$0186
	dc.w $0170,$015b,$0148,$0135,$0124,$0114,$0104,$00f5
	dc.w $00e8,$00db,$00ce,$00c3,$00b8,$00ae,$00a4,$009b
	dc.w $0092,$008a,$0082,$007b,$0074,$006d,$0334,$0334
	dc.w $0306,$02da,$02b1,$028b,$0266,$0244,$0223,$0204
	dc.w $01e7,$01cc,$01b2,$019a,$0183,$016d,$0159,$0145
	dc.w $0133,$0122,$0112,$0102,$00f4,$00e6,$00d9,$00cd
	dc.w $00c1,$00b7,$00ac,$00a3,$009a,$0091,$0089,$0081
	dc.w $007a,$0073,$006d,$032e,$032e,$0300,$02d5,$02ac
	dc.w $0286,$0262,$023f,$021f,$0201,$01e4,$01c9,$01af
	dc.w $0197,$0180,$016b,$0156,$0143,$0131,$0120,$0110
	dc.w $0100,$00f2,$00e4,$00d8,$00cc,$00c0,$00b5,$00ab
	dc.w $00a1,$0098,$0090,$0088,$0080,$0079,$0072,$006c
	dc.w $038b,$038b,$0358,$0328,$02fa,$02d0,$02a6,$0280
	dc.w $025c,$023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194
	dc.w $017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0
	dc.w $0097,$008f,$0087,$007f,$0078,$0384,$0384,$0352
	dc.w $0322,$02f5,$02cb,$02a3,$027c,$0259,$0237,$0217
	dc.w $01f9,$01dd,$01c2,$01a9,$0191,$017b,$0165,$0151
	dc.w $013e,$012c,$011c,$010c,$00fd,$00ee,$00e1,$00d4
	dc.w $00c8,$00bd,$00b3,$00a9,$009f,$0096,$008e,$0086
	dc.w $007e,$0077,$037e,$037e,$034c,$031c,$02f0,$02c5
	dc.w $029e,$0278,$0255,$0233,$0214,$01f6,$01da,$01bf
	dc.w $01a6,$018e,$0178,$0163,$014f,$013c,$012a,$011a
	dc.w $010a,$00fb,$00ed,$00df,$00d3,$00c7,$00bc,$00b1
	dc.w $00a7,$009e,$0095,$008d,$0085,$007d,$0076,$0377
	dc.w $0377,$0346,$0317,$02ea,$02c0,$0299,$0274,$0250
	dc.w $022f,$0210,$01f2,$01d6,$01bc,$01a3,$018b,$0175
	dc.w $0160,$014c,$013a,$0128,$0118,$0108,$00f9,$00eb
	dc.w $00de,$00d1,$00c6,$00bb,$00b0,$00a6,$009d,$0094
	dc.w $008c,$0084,$007d,$0076,$0371,$0371,$0340,$0311
	dc.w $02e5,$02bb,$0294,$026f,$024c,$022b,$020c,$01ee
	dc.w $01d3,$01b9,$01a0,$0188,$0172,$015e,$014a,$0138
	dc.w $0126,$0116,$0106,$00f7,$00e9,$00dc,$00d0,$00c4
	dc.w $00b9,$00af,$00a5,$009c,$0093,$008b,$0083,$007b
	dc.w $0075,$036b,$036b,$033a,$030b,$02e0,$02b6,$028f
	dc.w $026b,$0248,$0227,$0208,$01eb,$01cf,$01b5,$019d
	dc.w $0186,$0170,$015b,$0148,$0135,$0124,$0114,$0104
	dc.w $00f5,$00e8,$00db,$00ce,$00c3,$00b8,$00ae,$00a4
	dc.w $009b,$0092,$008a,$0082,$007b,$0074,$0364,$0364
	dc.w $0334,$0306,$02da,$02b1,$028b,$0266,$0244,$0223
	dc.w $0204,$01e7,$01cc,$01b2,$019a,$0183,$016d,$0159
	dc.w $0145,$0133,$0122,$0112,$0102,$00f4,$00e6,$00d9
	dc.w $00cd,$00c1,$00b7,$00ac,$00a3,$009a,$0091,$0089
	dc.w $0081,$007a,$0073,$035e,$035e,$032e,$0300,$02d5
	dc.w $02ac,$0286,$0262,$023f,$021f,$0201,$01e4,$01c9
	dc.w $01af,$0197,$0180,$016b,$0156,$0143,$0131,$0120
	dc.w $0110,$0100,$00f2,$00e4,$00d8,$00cb,$00c0,$00b5
	dc.w $00ab,$00a1,$0098,$0090,$0088,$0080,$0079,$0072
	else
	dc.w $0358,$0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071
	endc
P61_dma:
	dc $8200
P61_rowpos:
	dc 0
P61_slen:
	dc 0
P61_speed:
	dc 0
P61_speed2:
	dc 0
P61_speedis1:
	dc 0
P61_spos:
	dc.l 0
	ifeq p61system
P61_vektori:
	dc.l 0
P61_oldlev6:
	dc.l 0
	endc
P61_ofilter:
	dc 0
P61_timers:
	dc.l 0
	ifne p61cia
P61_tintti:
	dc.l 0
P61_thi:
	dc.b 0
P61_tlo:
	dc.b 0
P61_thi2:
	dc.b 0
P61_tlo2:
	dc.b 0
P61_timer:
	dc.l 0
	endc
	ifne P61_pl
P61_plcount:
	dc 0
P61_plflag:
	dc 0
P61_plreset:
	dc 0
P61_plrowpos:
	dc 0
P61_looppos:
	dcb.b 12*channels,0
	endc
	ifne P61_pde
P61_pdelay:
	dc 0
P61_pdflag:
	dc 0
	endc
P61_samples:
	dcb.b 16*31,0
P61_emptysample:
	dcb.b 16,0
P61_positionbase:
	dc.l 0
P61_possibase:
	dc.l 0
P61_patternbase:
	dc.l 0
P61_intaddr:
	dc.l 0
	ifne p61system
P61_server:
	dc 0
P61_miscbase:
	dc.l 0
P61_audioopen:
	dc.b 0
P61_sigbit:
	dc.b -1
P61_ciares:
	dc.l 0
P61_craddr:
	dc.l 0,0,0
P61_dat:
	dc $f00
P61_timerinterrupt:
	dc 0,0,0,0,127
P61_timerdata:
	dc.l 0,0,0
P61_timeron:
	dc 0
P61_allocport:
	dc.l 0,0
	dc.b 4,0
	dc.l 0
	dc.b 0,0
	dc.l 0
P61_reqlist:
	dc.l 0,0,0
	dc.b 5,0
P61_allocreq:
	dc.l 0,0
	dc 127
	dc.l 0
P61_portti:
	dc.l 0
	dc 68
	dc.l 0,0,0
	dc 0
P61_reqdata:
	dc.l 0
	dc.l 1,0,0,0,0,0,0
	dc 0
P61_audiodev:
	dc.b 'audio.device',0
P61_cianame:
	dc.b 'ciab.resource',0
P61_timeropen:
	dc.b 0
P61_timerint: dc.b 'P61_TimerInterrupt',0,0
	endc
P61_InitPos: dc.w 0
	ifne use1Fx
P61_PTrig: dc.w 0		;Poll this Custom trigger, using 'Bxx',pos $80-$ff
P61_1F:	 dc.w 0
	endc
	ifne useinsnum
P61_CH3_INST: DC.W 0	; here sample # are stored to use outside
P61_CH2_INST: DC.W 0
P61_CH1_INST: DC.W 0
P61_CH0_INST: DC.W 0
	endc
	ifne nowaveforms
P61_NewDMA: dc.w 0
	endc
	ifne copdma
p61_DMApokeAddr: dc.l 0
	endc
P61_PattFlag: dc.w 0
P61_etu:
	ifne quietstart
P61_Quiet: dc.w 0
	endc
	ifne visuctrs
P61_visuctr0: dc.w $4000
P61_visuctr1: dc.w $4000
P61_visuctr2: dc.w $4000
P61_visuctr3: dc.w $4000
	endc
P61E:
samples: