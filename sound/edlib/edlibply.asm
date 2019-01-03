; =========================================================================================================================
; 	COMMODORE 64 EDLIB 2.01 D00 PLAYER (DOS OPL TRACKER) v0.20
; 	C64 code by Mr.Mouse/XeNTaX for the SFX Sound Expander (SFXSE) peripheral
; 	Kickassembler source code, using Relaunch64 as IDE. 
;
; 	Based on JCH's original Edlib Tracker x86 code 
; 	 
; 	XeNTaX, 9th of July 2017 
;	Website: http://www.xentax.com or http://c64.xentax.com
;	Email:	mr.mouse@xentax.com or info@xentax.com
;	=========================================================================================================================*/
;/*========================================================= SFX Sound Expander =================================================
;  Variables
;*/

.importzp ptr1,ptr2,ptr3
.import opl2_init, opl2_reg_write
fm_file_base_address = $0002		; word
fm_file_arrdata = $0008			; word

;/*--------------------------------------------------------------------------------------------------------------------------
;	Summary	
;	-------
;	
;	You can use this code, standard at $1000/$1003 for init/play, to play D00 files type v2.01 on your SFX Sound Expander
;	in your expansion port. It contains the YM3526 FM sound chip (OPL1). Adlib was referring to the YM3812 chip (OPL2), 
;	found on DOS soundcards. Both are 100% the same, except for the waveforms. The YM3526 has only the full sine 
;	waveform, while the YM3812 has three additional adaptations of the sine wave. This will result in a different sound, 
;	when used on a YM3526. JCH's Edlib Tracker used the DOS Adlib soundcards with the YM3812. 
;	One can remove the YM3526 from the SFXSE, and replace with the YM3812, to have the same Adlib sound on the C64. 
;	
;	To use this player, you can load up any tune to whereever you like, but make sure to set $1006/$1007 to the location, 
;	before calling the Init routine. Check out the "VIBRANTS FM" music collection I created to hear the player do its thing. 
;	
;	Now for a list of routines you can call. 

;	Main Routines 
;	-------------
;	JCH_DETECT_CHIP:
;		Will detect existence of the YM3526/YM3812 chip at the expansion port
;		Will set carry flag if failure upon return. 
;		NOTE: WinVICE 3.1 emulation is inaccurate: this routine will fail to detect the chip, 
;		even if you have selected the SFX Sound Expander in VICE. On real hardware the routine works.  
;	JCH_FM_INIT: 
;	;	Initialize tune. Standard at $1000. Will take the location of the D00 file stored at $1006/$1007	
;	;	Jumps to two calls to subroutines, at JCH_FM_MUSIC_INIT. 	
;	JCH_FM_PLAY:	;	
;		IRQ play routine. Call this each frame (50 Hz) in your program to match the correct playing speed. 		
;
;	Other Routines			
;	------------
;	JCH_FM_MUSIC_INIT:			
;		Calls jch_initialize_fm_music and jch_load_fmfile_pointers and returns		
;	jch_initialize_fm_music:			
;		Will initialize various parameters and reset the SFX Sound Expander registers/voices			
;	jch_load_fmfile_pointers:				
;		Needs to be called after jch_initialize_fm_music. Will set pointers based on the location of data in the D00 file,				
;		to enable the JCH_FM_PLAY routine to function correctly. Has some optimizations to reduce raster time.
;	JCH_CLEAR_VOICE (y as index to voice)
;		Function to clear parameters for voice found in the table and init ym3526/ym3812
;		Accepts y as index to voice (0-8)
;	JCH_QUICK_UPDATE_REGISTER
;		short function to store value in A in temporary register memory X and immediately update ym3526/ym3812 registers
;	JCH_SET_REGISTER (FUNCTION)
;		load x with register, a with data for that register, then set the register.  	 				
;;//-------------------------------------------------------------------------------------------------------------------------*/

;;// ----------------------------------------------------------------------------------------------------------
;;// JCH_FM_INIT subroutine, this routine needs to be called to initialize the FM music
;;// ----------------------------------------------------------------------------------------------------------
.include "common.inc"
.include "fcntl.inc"
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "ym3812.inc"

.include "appstart.inc"
appstart $1000

;.pc = $1000 "INIT"
jch_fm_init:
		jmp jch_fm_music_init
jch_fm_play:
;.pc = $1003 "PLAYER" 
		jmp jch_fm_play_
fm_data_st_offset: .word d00file							;// location of FM file (D00), any caller must set $1006/$1007 first with the location of the D00 (lowbyte/highbyte)
;// ----------------------------------------------------------------------------------------------------------
;// JCH_FM_PLAY subroutine, this routine is called on IRQ interrupt, each frame (50 Hz)
;// ----------------------------------------------------------------------------------------------------------
jch_fm_play_:				
		lda #$00			
		sta var_bx 									;// set the current voice counter to 0
		sta var_si									;// set the word counter of the voice (double), but in the end this will not pass 255, so a single byte is ok
loc_10180: 
		ldx var_bx									;// has first been reset to 0 when first running this routine, this is the current_voice counter
		lda fm_voice_has_data, x					;// this is the voice_has_arrangement_pointer boolean. 
		cmp #$01									;// so is this 1? then do the stuff to play the voice in the current routine
		beq loc_1018A								;// edit the voice parameters
		jmp loc_1056C								;// not 1? then get move down to skip to the next voice in the row, this channel/voice does not  have arrangement data
;//----- update the current voice parameters
loc_1018A:
		ldx var_bx		
		dec fm_current_channel_speed_counter, x		;// this is reset to 0 by the init routine, so decreasing it will leave ff and overflow/sign? this is the channel speed counter. it starts with 0 since we want the music to start right away
		bpl loc_10198								;// jnl, jump if not less? this is signed mode. than what actually? jnl checks if overflow flag = sign flag, if first operant of previous cmp instruction is greater or equal
		lda fm_channel_speed_counter, x				;// channel speed table
		sta fm_current_channel_speed_counter, x		;// setting the variable to the base case: reset the channel speed counter to restart counting
loc_10198:		
		lda fm_current_channel_speed_counter, x		;// so it is zero? then we can now update the voice/channel, only update when this counter hits zero
		bne loc_101AB								;// not yet zero, so move on
		ldx var_si		
		dec fm_cur_seq_command_tick_counter, x		;// this is the current channel pattern/sequence time/tick counter --> if it hits 0 it needs to be reset, and a new pattern/sequence started
		bpl loc_101A8								;// still plus, move on		
		dec fm_cur_seq_command_tick_counter+1, x	;// decrease also high byte		
 	   												;// now we need a 16-bit compare , need to know where to branch to (jge), if the last dec led to sign change (going neg) then we jmp, else go ato 101a8
													;// remember that we are dealing with singed word! jge/jnl only leads to signed flag = overflow = 0 in the positive area, for a byte: 00-7f
		bpl loc_101A8								;// if no sign change, then s=0 = o = 0 
		jmp loc_10330								;// the counter hit zero so we need to change to the next sequence command
loc_101A8:		
		jmp loc_10449								;// Determine frequence changes of current note and play that					
loc_101AB:				
		lda fm_current_channel_speed_counter, x		;// x still is var_b, load the current channel speed counter
		cmp #$01									;// is it one?
		bne loc_101A8								;// no? get outta here
		ldy var_si						
		lda fm_cur_seq_command_tick_counter, y		;// word pointer, has this counter hit zero : current channel sequence time/tick counter				
		bne loc_101A8		
		lda fm_cur_seq_command_tick_counter+1,y		;// 16-bit compare for equality x=low byte, a = high byte
		bne loc_101A8		
;// ======================= TRACK COMMANDS ==========================================================
loc_101B9:											
		lda #$00									;// okay, fm_cur_seq_command_tick_counter hit zero, now reset fm_local_voice_slide				
		sta fm_local_voice_slide					;// SLIDE effect E/D are also storing the slide speed here?				
		sta fm_local_voice_slide+1					;// WORD
		ldy var_si									;// getting funky with BP (base pointer) now... 				
		clc											;// opt
		lda fm_pt_voice_arrdata, y					;// this was done per voice , var_si is used as voice counter : get entry at arrangement pointer (base address)
		adc fm_position_in_voice_seqlist, y
		sta $10
		lda fm_pt_voice_arrdata+1, y		
		adc fm_position_in_voice_seqlist+1, y		
		sta $11
		ldy #$00
		lda ($10), y								;// get the next sequence - low byte
		sta var_di
		tax
		iny
		lda ($10), y								;// get the next sequence - high byte
		sta var_di+1
		cpx #$fe									;// check for FFFE = end of arrangement = STOP. 
		bne loc_101ed		
		cmp #$ff		
		bne loc_101ed								;// no FFFE? go on		
		lda #$00		
		ldx var_bx		
		sta fm_voice_has_data, x					;// set current voice "has arrangements"/active to 0. no more activity.		
		sta fm_previous_registry_value, x			;// reset values for current register for voice (jch_table_0x822 = temporary register table)
		sta fm_current_channel_speed_counter, x		;// set current channel speed counter to 0
		sta fm_voice_vibrato_depth, x				;// vibrato_depth
		ldx var_si
		sta fm_current_frequency, x					;// voice frequency (word)
		sta fm_current_frequency+1, x
		jmp loc_104fc								;// get outta here
loc_101ed:  
		cpx #$ff									;// check for FFFF = loop arrangement . 
		bne loc_101FE								;// no FFFF? go on
		cmp #$ff		
		bne loc_101FE								;// no FFFF? go on																		
		ldy #$02									;// increase pointer by two, since we had a loop counter, which will be followed by the position (word) to loop to
		ldx var_si
		lda ($10), y	
		clc
		asl	
		sta fm_position_in_voice_seqlist, x	
		iny	
		lda ($10), y	
		rol 	
		sta fm_position_in_voice_seqlist+1, x	
		jmp loc_101B9	
loc_101FE: ;// **** No FFFE and no FFFF so we continue
		lda var_di			
		and #$00					
		tax
		lda var_di+1
		and #$f0					
		cpx #$00		
		bne loc_10224		
		cmp #$80		
		bne loc_10224								;// no zero? ok, get outta here							
		clc
		ldy var_si
		lda var_di									;// get di in dx and AND with 00FF
		and #$ff
		asl	
		sta fm_transpose_value, y	
		lda #$00	
		rol	
		sta fm_transpose_value+1, y	
		lda var_di+1
		and #$0f
		bne neg
		jmp loc_1024f						
neg:												;// y should still be var_si+1
		sec											;// set carry for borrow purpose, do the NEG instruction (is same as dest = 0- destination )
		lda #$00
		sbc fm_transpose_value,y		 			;// perform subtraction on the LSBs
		sta fm_transpose_value,y
		lda #$00									;// do the same for the MSBs, with carry
		sbc fm_transpose_value+1,y					;// set according to the previous result
		sta fm_transpose_value+1,y			
		jmp loc_1024f		
loc_10224: ;// **** set memory locations of current sequence data needing to be checked		
													;// SET VAR_DI TO BASE OF SEQUENCE DATA --> TO OPTIMIZE : DO THIS IN INITIALIZATION, create a table of offsets to sequences (DONE!)
		asl var_di									;// di = sequence number, we are treating this as BYTE now (max 64 sequences)
		ldx var_di
		ldy var_si
		lda fm_opt_seq_pointers, x
		clc
		adc fm_position_in_current_seq, y
		sta $06
		lda fm_opt_seq_pointers+1, x
		adc fm_position_in_current_seq+1, y		
		sta $07		
loc_1023b: ;// **** DO NEXT VAR_BP (next step in sequence)		
		clc
		ldx var_si									;// this is a word!!!
		lda fm_position_in_current_seq, x			;// add two to the word variable
		adc #$02
		sta fm_position_in_current_seq, x			;// fixed
		bcc loc_1023b_a
		inc fm_position_in_current_seq+1, x
loc_1023b_a:		
		ldy #$00		
		lda ($06), y								;// load the sequence variable in var_ax		
		sta var_ax		
		tax
		iny		
		lda ($06), y		
		sta var_ax+1		
		cpx #$ff									;// check for FFFF = END OF SEQUENCE DATA . 
		bne loc_10257								;// no FFFF? go on
		cmp #$ff		
		bne loc_10257								;// no FFFF? go on									
		ldy var_si									;// FFFF? End of sequence reached, reset the sequence pointer for this voice to 0
		lda #$00						
		sta fm_position_in_current_seq, y						
		sta fm_position_in_current_seq+1, y						
loc_1024f: ;// **** set current voice sequence pointer to next sequence and move up 		
		ldx var_si
		clc											
		lda fm_position_in_voice_seqlist, x			;// add two to the word variable for the position of the sequence in the sequence data. (set pointer to the next sequence)
		adc #$02
		sta fm_position_in_voice_seqlist, x 		
		bcc loc_1024f_a								
		inc fm_position_in_voice_seqlist+1, x
loc_1024f_a:
		jmp	loc_101B9								;// and get out of here, back to top (TRACK COMMANDS)
loc_10257: ;// **** SEQUENCE COMMANDS - CHECK FOR C000 (set instrument)
		lda var_ax									;// backup ax in di and AND ax with 0F00 to check 
		sta var_di
		lda var_ax+1
		sta var_di+1								
		and #$f0
		sta var_ax+1
		cmp #$c0									;// compare with #$c0
		bne loc_1026b
		ldy var_si		
		lda var_di									;// AND di with 0x0fff and also store at 6d5 for this voice - so remove the C, from CXXX and leave only the value 0XXX (instrument number)
		and #$ff		
		sta fm_voice_instrument, y					;// store instrument number for this voice and move on to loc_102af
		lda var_di+1		
		and #$0f		
		sta fm_voice_instrument+1, y		
		jmp loc_102af		
loc_1026b: ;// **** SEQUENCE COMMANDS - CHECK FOR EFFECT 90XX (SET VOLUME)
		lda var_ax+1
		cmp #$90
		bne loc_1027a
		lda var_di		
		and #$3f									;// by anding with 3f
		ldy var_bx									;// bx = current voice
		sta fm_voice_volume, y 						;// store volume at var_807  :volume table per voice
		jmp loc_102af			
loc_1027a: ;// **** SEQUENCE COMMANDS: CHECK FOR EFFECT 7XXXX = SET VIBRATO = 0x = speed, xx = depth
		lda var_ax+1
		cmp #$70
		bne loc_10289
		ldy var_si									;// var_si = current voice counter (word)
		lda var_di									;// AND di with 0x0fff and also store at 7d1 for this voice - so remove the 7, from CXXX and leave only the value 0XXX (X = speed, XX = depth)
		and #$ff		
		sta fm_voice_vibrato, y						;// store vibrato parameters for this voice and move on to loc_102af
		lda var_di+1		
		and #$0f		
		sta fm_voice_vibrato+1, y		
		jmp loc_102af				
loc_10289: ;// **** SEQUENCE COMMANDS: CHECK FOR EFFECT DXXXX = SLIDE UP = 0xxx = speed
		lda var_ax+1
		cmp #$d0
		bne loc_1029c
		ldy var_si									;// var_si = current voice counter (word) SO FIX THIS YOU IDIOT!!!!!!!!!!!!!!!!!!!!!! <<< NO NEED, SINCE VAR_SI will NOT be greater than FF, BITCH
		lda var_di									;// AND di with 0x0fff and also store at 7d1 for this voice - so remove the D, from DCXXX and leave only the value 0XXX (X = speed, XX = depth)
		and #$ff		
		sta fm_voice_slide, y						;// store SLIDE UP parameters for this voice and move on to loc_102af
		sta fm_local_voice_slide					;// store also here		
		lda var_di+1		
		and #$0f		
		sta fm_voice_slide+1, y		
		sta fm_local_voice_slide+1		
		jmp loc_102af			
loc_1029c: ;// **** SEQUENCE COMMANDS: CHECK FOR EFFECT EXXXX = SLIDE DOWN = 0xxx = speed
		lda var_ax+1
		cmp #$e0
		bne loc_102b3
		lda var_di									;// AND di with 0x0fff and also store at 7d1 for this voice - so remove the D, from DCXXX and leave only the value 0XXX (X = speed, XX = depth)
		and #$ff		
		sta var_di		
		lda var_di+1		
		and #$0f		
		sta var_di+1		
		ldy var_si									;// var_si = current voice counter (word)
		sec											;// set carry for borrow purpose, do the NEG instruction (is same as dest = 0- destination )
		lda #$00
		sbc var_di		 							;// perform subtraction on the LSBs
		sta fm_voice_slide, y						;// store SLIDE DOWN parameters for this voice and move on to loc_102af
		sta fm_local_voice_slide					;// store also at here
		lda #$00									;// do the same for the MSBs, with carry
		sbc var_di+1								;// set according to the previous result
		sta fm_voice_slide+1, y		
		sta fm_local_voice_slide+1		
loc_102af: ;// **** NEXT var_bp (next step in sequence)
		clc
		lda $06
		adc #$02									;// word pointer
		sta $06									
		bcc loc_102af_a	
		inc $07
loc_102af_a:			
		jmp loc_1023b			
loc_102b3: ;// **** SEQUENCE COMMANDS: CHECK FOR EFFECT 6000 = CUT VOICE					
		lda var_ax+1
		cmp #$60
		bne loc_102c4
		ldy var_si
		lda var_di					
		sta fm_voice_value, y						;// store at 6f9 for cut current voice table   			
		lda var_di+1					
		sta fm_voice_value+1, y					
		ldy var_bx
		lda #$00				
		sta fm_previous_registry_value, y				
		jmp loc_10449				
loc_102c4:					
		lda var_di									;// backup var_di in dx
		sta var_dx			
		lda var_di+1			
		sta var_dx+1			
		ldy var_si									;// IT IS NOT GOING TO PASS FF...........
		lda var_di+1					
		and #$1f									;// get state of lowest 5 bits of and store at di and fm_voice_value
		sta fm_voice_value, y						;// store at 6f9 for cut current voice table   			
		eor var_di+1								;// clear var_di+1				
		sta fm_voice_value+1, y												
		ldx #$00									;// this is a 16-bit AND in the original code, but will isolate the bits 1-6 of the low byte, with 0 of the high byte		
		lda var_dx								
		and #$7f									
		sta var_di			
		stx var_di+1								;// ***OPT*** this may be optimized
		cmp #$7e									;// check if it was 7e					
		beq loc_102e5								;// yes, then go to loc_102e5					
		cmp #$00									;// was it 0? (REST)
		bne loc_102ed								;// no, then go to loc_102ed					
		ldy var_bx									;// yes, so let's set fm_previous_registry_value to 0 for this voice (bx)
		lda #$00				
		sta fm_previous_registry_value, y				
loc_102e5:
		ldy var_bx								
		lda #$01				
		sta fm_sequence_var_type, y					;// set fm_sequence_var_type to 1 for this voice (bx), 7e detected (hold) or 0 (rest)					
		jmp loc_10449						
loc_102ed: ;// **** is it a standard note?
		asl var_di									;// times two (16 bit) of var_di
		rol var_di+1 
		lda var_dx+1								;// is bit 4 of high byte of dx set? 
		and #$20
		beq loc_102fb								;// no,  so it's a standard note, so move on to loc_102fb and reset the parameters
		ldy var_bx									;// yes, bit 4 is set, so it's 20h - Tie note on or other parameters
		lda #$02									
		sta fm_sequence_var_type, y					;// set fm_sequence_var_type to 2 for this voice (bx)					
		jmp loc_10305								;// then jump over the rest
loc_102fb: ;// **** reset parameters to 0 for this voice		
		ldy var_bx
		lda #$00
		sta fm_sequence_var_type, y					;// reset these values for this voice
		sta fm_previous_registry_value, y			;// 822 = current reg status update
loc_10305:		
		lda #$20
		sta fm_previous_registry_value_preset, y	;// set this to value 20h for this voice		
		lda var_dx									;// check low byte of sequence data
		and #$80									;// has it bit 7 set?
		bne loc_10313								;// yes, so move to 10313
		ldy var_si									;// no 
		clc
		lda fm_transpose_value, y					;// add value in fm_transpose_value for this voice to var_di (753)
		adc var_di
		sta var_di
		lda fm_transpose_value+1,y
		adc var_di+1
		sta var_di+1
loc_10313: 	;// **** GET NOTE FREQUENCY	
		lda var_di									;// get just the low byte of sequence byte
		ldy var_bx
		sta var_777, y								;// store low byte of sequence data at 777 for this voice
		clc
		lda #<fm_frequency_table
		adc var_di
		sta $10
		lda #>fm_frequency_table
		adc var_di+1
		sta $11
		ldx var_si									
		ldy #$00
		lda ($10), y			
		sta fm_voice_freq, x						;// store the frequency at 7f5
		iny
		lda ($10), y			
		sta fm_voice_freq+1, x
		lda fm_local_voice_slide					;// get global effect E/D (slide) value 
		sta fm_voice_slide, x						;// and store that at effect E/D value for this voice
		lda fm_local_voice_slide+1
		sta fm_voice_slide+1, x
		ldy var_bx
		lda #$00
		sta fm_voice_vibrato_depth, y 				;// reset fm_voice_vibrato_depth
loc_1032d:				
		jmp	loc_10449								;// jump to 10449
loc_10330: ;// **** do next sequence command													
		ldy var_si									;// load current word pointer for voice
		lda fm_voice_value, y						;// get low byte voice_value for this vocie (6f9) 
		and #$ff									;// AND this with FF
		sta fm_cur_seq_command_tick_counter, y		;// current sequence time/tick? store there
		lda fm_voice_value+1, y						;// get high byte voice_value for this vocie (6f9) 
		and #$0f									;// AND this with FF
		sta fm_cur_seq_command_tick_counter+1, y	;// current sequence time/tick? store there
		lda #$00									;// set var_bp to 0
		sta var_bp		
		sta var_bp+1		
		lda fm_voice_value+1, y						;// the original instruction is cmp	word ptr [si+6F9h], 6000h, followed by jnb	short loc_10398. So checking for a higher value in 6f9 than 6000
		sec											;// so we need only check if the 60 is lower or equal to the high byte of the fm_voice_value
    	sbc #$60 									;// if carry is set then A > #$60 so let's move, it means we are dealing with further effects
		bcc loc_10330_1								
		jmp loc_10398
loc_10330_1:
		ldx fm_voice_vibrato+1, y
		lda fm_voice_vibrato, y						;// check if voice_vibrato value if $1000
		bne loc_10330_a
		cpx #$10 
		beq loc_10362
loc_10330_a:										;// no, fm_voice_vibrato is not 1000h, so store the current values of al and ah at locations
		ldy var_bx		
		sta fm_voice_vibrato_depth, y				;// vibrato depth
		txa
		sta fm_voice_vibrato_speed, y				;// vibrato speed 
		lsr 										;// divide ah by two 
		sta fm_cur_vibrato_speed_counter, y			;// this is half of ah
		ldy var_si
		lda #$00									;// store 1000h at the vibrato parameter
		sta fm_voice_vibrato, y		
		lda #$10		
		sta fm_voice_vibrato+1, y		
loc_10362: ;// **** volume and slide				
		ldy var_bx				
		lda fm_voice_volume, y 						;// load current voice volume value	(807)			
		sta fm_cur_voice_volume, y 					;// store voice volume at fm_cur_voice_volume		
		ldy var_si									;// store ax (ah + al, and al = voice value, while 
		lda fm_voice_slide, y						;// fixed (var_7e3)
		sta fm_voice_temp_slide, y 							
		lda fm_voice_slide+1, y
		sta fm_voice_temp_slide+1, y							
		ldy var_bx							
		lda fm_sequence_var_type, y					;// check what value 8f4 is for voice						
		cmp #$01									;// is it 1?
		bne loc_10362_a
		jmp loc_1032d								;// move to next
loc_10362_a:		
		ldy var_si
		lda fm_voice_freq, y						;// get current voice frequency
		sta fm_current_frequency, y 				;// store at current voice frequency (word). Note: ax not done, since it is not used
		lda fm_voice_freq+1, y 
		sta fm_current_frequency+1, y 
		ldy var_bx									
		lda fm_sequence_var_type, y 				;// now check if this is 2							
		cmp #$02									
		bne loc_10362_b
		jmp loc_1032d											
loc_10362_b: ;// **** set instrument location and voice level													
		lda fm_previous_registry_value_preset, y 	;// voice level 2. This is always set at $20 for each voice.  						
		sta fm_previous_registry_value, y  			;// store at cur regupdate/voice level?						
		ldy var_si				
		lda fm_voice_instrument, y 					;// get the voice instrument in var_bp	OPTIMIZATION STEP: WE ALLOW 32 INSTRUMENT, but MAX 255. No need for a 16-bit variable.
		sta var_bp				
loc_10398:	;// **** PLAY INSTRUMENT										
		;// $02$03 should be location of fm file	, if jumping from 60xx then varbp will be 0 (instrument 0)											
		lda var_bp									;// get instrument number
		asl											;// times two to get to the right fm_ins position
		tax
		lda fm_opt_ins_pointers, x
		sta $06
		sta var_bp
		lda fm_opt_ins_pointers+1, x
		sta $07
		sta var_bp+1
 		ldy #$07									;// get byte 7 from the base address of this instrument data block : modulator level 												
		lda ($06), y													
		ldx var_bx
		sta fm_ins_modulator_level, x				;// 898, modulator level													
		ldy #$0b									;// get byte 0b: note fine tune 											
		lda ($06), y																	
		sta fm_ins_fine_tune, x						;// 7b6													
		beq loc_103d1								;// if 0 get out															
		ldy #$0c									;// get byte 0c: hard restart value 							
		lda ($06), y															
		sta fm_ins_hardrestart, x					;// 7c8															
		lda #$00
		sta var_7ad, x
		sta fm_temp_ins_hardrestart, x
		ldx var_si
		clc											
		lda var_bp									;// add 8 to get to the multipurpose value									
		adc #$08											
		sta fm_ins_multipurpose, x					;// 798
		lda var_bp+1											
		adc #$00											
		sta fm_ins_multipurpose+1, x											
loc_103d1: ;// **** output register values for voice - NOT THE FREQUENCY, THAT IS LATER													
		ldx var_bx													
		lda jch_voice_reg_table, x													
		clc													
		adc #$60													
		tax											;// x is attack /decay register for voice			
		ldy #$00
		lda ($06), y								;// get value for Attack/Decay										
		jsr jch_set_register											
		ldx var_bx													
		lda jch_voice_reg_table, x													
		clc													
		adc #$80													
		tax											;// x is attack /decay register for voice			
		iny
		lda ($06), y								;// get value for Sustain/Release										
		jsr jch_set_register																								
		iny 																		
		lda ($06), y								;// get main volume level /KSL						
		ldx var_bx												
		sta fm_ins_mainvolume_ksl,x					;// set var_878 : fm_ins_mainvolume_ksl
		lda jch_voice_reg_table, x													
		clc												
		adc #$20 												
		tax												
		iny											;// get AMP/VIB/MOD freq (multipurpose value for carrier)									
		lda ($06), y												
		jsr jch_set_register			
	    ldx var_bx													
		lda jch_voice_reg_table, x													
		clc													
		adc #$e0													
		tax											;// x is waveform select			
		iny
		lda ($06), y								;// get value for voice waveform										
		jsr jch_set_register							
	    ldx var_bx													
		lda jch_voice_reg_table+9, x				;// set to modulator										
		clc													
		adc #$60													
		tax											;// attack decay for modulator	
		iny											;// should be 5 now
		lda ($06), y								;// get value 										
		jsr jch_set_register							
	    ldx var_bx													
		lda jch_voice_reg_table+9, x				;// set to modulator										
		clc													
		adc #$80													
		tax											;// sustain release for modulator	
		iny											;// should be 6 now
		lda ($06), y								;// get value 										
		jsr jch_set_register			
	    ldx var_bx													
		lda jch_voice_reg_table+9, x				;// set to modulator										
		clc													
		adc #$20													
		tax											;// AMP/VIB/MOD freq (multipurpose value for carrier)	
		iny
		iny											;// should be 8 now
		lda ($06), y								;// get value 										
		jsr jch_set_register					
	    ldx var_bx													
		lda jch_voice_reg_table+9, x				;// set to modulator										
		clc													
		adc #$e0													
		tax											;// wave form for modulator	
		iny											;// should be 9 now
		lda ($06), y								;// get value 										
		jsr jch_set_register					
		iny											;// should be a(10) now
		ldx var_bx									
		lda ($06), y
		sta fm_ins_feedback_level,x					;// hardware register Bytes C0-C8 - Feedback / Algorithm value
loc_10449: ;// **** PROCESS VOICE FREQUENCY													
		ldx var_si									;// get current voice word value for var_765 (fm_voice_slide)
		clc											;// 2 cycles
		lda fm_voice_temp_slide, x					;// 4 cycles
		beq loc_10449_x								;// 2 cycles		;// optimization to have 9 cycles less in most cases without slides, versus an extra 2, max 4 in case of slide
		adc fm_current_frequency, x					;// 4 cycles
		sta fm_current_frequency, x					;// 5 cycles 
loc_10449_x:
		lda fm_voice_temp_slide+1, x				;// 4 cycles
		beq loc_10449_y								;// 2 cycles
		adc fm_current_frequency+1, x				;// 4 cycles
		sta fm_current_frequency+1, x				;// 5 cycles
loc_10449_y:
		ldx var_bx
		lda fm_cur_vibrato_speed_counter, x			;// check vibrato speed counter
		bmi loc_10474								;// jl , jum if less (in this case if negative, so bmi) , no vibrato up update needed
		ldx var_si
		ldy var_bx
		clc
		lda fm_voice_vibrato_depth, y				;// add 792 value (byte in al) to var_741, add vibrato depth to frequency
		beq loc_10449_0								;// OPT no need to do it if no depth
		adc fm_current_frequency, x
		sta fm_current_frequency, x
		bcc loc_10449_0
		inc fm_current_frequency+1, x
loc_10449_0:		
		ldx var_bx
		dec fm_cur_vibrato_speed_counter, x			;// decrease 780 counter for voice (current vibrato speed counter)
		beq loc_10449_a								;// two branch instruction to get jg instruction - CHECK FOR FUNCTION
		bpl loc_10486
loc_10449_a:		
		sec											;// set carry for borrow purpose, do the NEG instruction (is same as dest = 0- destination )
		lda #$00
		sbc fm_voice_vibrato_speed, x		 		;// perform subtraction on a
		sta fm_cur_vibrato_speed_counter, x			;// ***OPT***
		jmp loc_10486
loc_10474: ;// **** vibrato down
		ldx var_si									
		ldy var_bx
		sec
		lda fm_current_frequency, x					;// x is byte voice, get current frequency
		sbc fm_voice_vibrato_depth, y				;// subtract vibrato depth low
		sta fm_current_frequency, x
		bcs loc_10474_a								;// no carry, no high byte change
		dec fm_current_frequency+1, x
loc_10474_a:
		ldx var_bx									
		inc fm_cur_vibrato_speed_counter, x			;// increase speed counter
		bne loc_10486
		lda fm_voice_vibrato_speed, x				;// no a register needed (var_ax)
		sta fm_cur_vibrato_speed_counter, x
loc_10486:	;// **** adjust voice level/volume	
		lda fm_channel_volume, x					;// load the second byte per voice loaded from the arrangement pointer table. 
		clc 
		adc fm_cur_voice_volume, x					;// add the voice volume to this variable
		adc fm_master_volume						;// add master volume
		cmp #$3f									;// is it 3F? (all 6 bits set) == silence (volume)
		bmi loc_10498								;// is it less or equal ?
		beq loc_10498
		lda #$3f									;// set var-ax to silence
loc_10498: ;// **** FINE TUNE		
		sta fm_minimum_voice_volume, x				;// store the level / volume 		
		lda fm_ins_fine_tune, x						;// ***OPT***
		bne loc_10498_1
		jmp loc_104fc								;// 0 ? so no fine tune
loc_10498_1:
		dec fm_temp_ins_hardrestart, x				;// decrease var_7bf	= fm_temp_ins_hardrestart				
		bmi loc_10498_2
		jmp loc_104fc								;// still plus , hard restart count-down not done yet (CHECK IF WE ARE DEALING WITH A SIGNED NUMBER, ELSE: BCS loc_104fc)			
loc_10498_2:
	    lda fm_ins_hardrestart, x					;// get ins hard restart setting 7c8
		sta fm_temp_ins_hardrestart, x				;// reset fm_temp_ins_hardrestart
		ldy var_si 
		lda fm_ins_multipurpose, y					;// get multipurpose value: NOTE THIS MAY NOT BE THE RIGHT NAME FOR THE VARIABLE
		sta var_bp
		sta $06
		lda fm_ins_multipurpose+1, y 				
		sta $07
		sta var_bp+1
		lda var_7ad, x								;// get 7ad, this will set zero flag if 0
		bne loc_104ea
		ldy #$03
		lda ($06), y 								;// load the offset of bp.. 
		sta var_bp
		lda #$00
		sta var_bp+1
		dec var_bp
		bpl loc_10498_a
		dec var_bp+1
loc_10498_a:		
		ldy var_si
		clc		
		asl var_bp									;// shift left two times, so do times 4
		rol var_bp+1		
		clc		
		asl var_bp		
		rol var_bp+1		
		clc		
		lda fm_start_of_arrangement_data			;// now add the base offset of the arrangment data	
		adc var_bp		
		sta var_bp
		sta $06
		sta fm_ins_multipurpose, y 
		lda fm_start_of_arrangement_data+1		
		adc var_bp+1
		sta var_bp+1							
		sta $07										;// ***OPT*** do we really need var_bp?
		sta fm_ins_multipurpose+1, y 				;// fixed
		ldy #$02
		lda ($06), y								;// get the second byte starting from this value
		clc
		adc #$01									;// these two are 4 cycles
		sta var_7ad									;// store at 7ad
		ldy #$00
		lda ($06), y								;// was the base address FF? 
		cmp #$ff
		beq loc_104ea
		sta fm_ins_modulator_level, x				;// x is still voice counter (single)
loc_104ea:		
		dec var_7ad, x		
		ldy #$01 
		lda ($06), y								;// $06/$07 = var_bp at this point, so get the by pointed at by bp+1
		clc
		adc fm_ins_modulator_level, x		
		and #$3f									;// select only the values of the first 6 bits	(volume)
		sta fm_ins_modulator_level, x				;// set the value to this		
loc_104fc: ;// placeholder												
		lda jch_voice_reg_table, x					;// get the voice register select value
		clc		
		adc #$40									;// KSL scaling/ level / volume of the operator
		sta var_ax		
		lda fm_ins_mainvolume_ksl, x				;// 878
		sta var_ax+1
		and #$c0									;// and with C0 , select only the upper 2 bits (bit 6 and 7)	
		sta var_dx 
		lda var_ax+1
		and #$3f									;// select only first 6 bits
		sta var_ax+1
		cmp fm_minimum_voice_volume, x 				;// compare with temp voice volume
		beq loc_104fc_a								;// is it greater ?  (jg instruction)
		bpl loc_10518								;// fixed	
loc_104fc_a:		
		lda fm_minimum_voice_volume, x				;// reset to stored value
		sta var_ax+1		
loc_10518:				
		lda var_ax
		tax
		lda var_ax+1			
		ora var_dx									;// or with 									
		jsr jch_set_register						;// okay set volume level for operator
		ldx var_bx
		lda jch_voice_reg_table+9, x				;// get the voice register select value operator 2
		clc		
		adc #$40									;// KSL scaling/ level / volume of the operator 2
		sta var_ax		
		lda fm_ins_modulator_level, x				;// 898
		sta var_ax+1
		lda fm_ins_feedback_level, x				;// 8b8 is bit 1 of high byte of dx set? (;// hardware register Bytes C0-C8 - Feedback / Algorithm value)
		and #$1	
		beq loc_10542								;// no so move out
		ldx var_bx
		lda var_ax+1
		and #$c0									;// and with C0 , select only the upper 2 bits (bit 6 and 7)	
		sta var_dx 
		lda var_ax+1
		and #$3f									;// select only first 6 bits
		sta var_ax+1
		cmp fm_minimum_voice_volume, x 				;// compare with temp voice volume
		beq loc_10518_a								;// is it greater ?  (jg instruction)
		bpl loc_10540								;// fixed
loc_10518_a:		
		lda fm_minimum_voice_volume, x				;// reset to stored value
		sta var_ax+1		
loc_10540: 		;// place holder
		lda var_ax
		tax
		lda var_ax+1			
		ora var_dx									;// or with 			
loc_10542:				
		ldx var_ax									;// ***OPT***
		lda var_ax+1
		jsr jch_set_register						;// set the register (a value, x reg)
		lda var_bx									;// voicecounter
		tay
		clc
		adc #$c0									;//Feedback/Algorithm register
		tax
		lda fm_ins_feedback_level, y				;// get value for this register at table, indexed by BX (not bl !( in original
		jsr jch_set_register						;// set the register (a value, x reg)
		ldy var_si									;// si in the original code
		lda fm_current_frequency, y					;// fixed : the code is loading a word, and then moving al to ah
		sta var_ax+1								;// fixed : hence storing it in var_ax+1
		lda var_bx
		clc
		adc #$a0									;// F-Num LSB
		tax											;// x needs to be the register
		lda var_ax+1								;// a is the value
		jsr jch_set_register
		ldx var_bx									;// set to byte voice counter
		txa
		clc
		adc #$b0									;// Oct/F-Num/Key-On
		sta var_ax									;// x is again register, needs to be stored at var_ax first
		lda fm_current_frequency+1, y				;// load the high byte of frequency
		clc
		adc fm_previous_registry_value, x			;// add the value at 822	
		ldx var_ax									;// read the register value
		jsr jch_set_register	
loc_1056C: ;//	**** NEXT VOICE
		inc var_si									;// this is 16 bit increase, but byte range of var_si is used. ***OPT*** word voice counter
loc_1056c_a:		
		inc var_si									;// this is 16 bit increase, but byte range of var_si is used. ***OPT***
loc_1056c_b:		
		inc var_bx									;// voice counter 
		lda var_bx		
		cmp #$9										;// all nine voices done?
		beq loc_10577		
		jmp loc_10180		
loc_10577:	;// **** all voices done, so return to IRQ
		rts
		

jch_clear_voice:
;// ----------------------------------------------------------------------------------------------------------
;// JCH_CLEAR_VOICE (counter1)
;// function to clear parameters for voice found in the table and init ym3526
;// accepts y as index to voice (0-8) 
;// ----------------------------------------------------------------------------------------------------------
		ldy var_di							;// get counter1 (voice index value) 	/ 4 cycles
		ldx jch_voice_reg_table, y			;// get voice reg value for operator 1 	/ 4 cycles
		lda jch_voice_reg_table+9, y		;// get voice reg value for operator 2 	/ 4 cycles
		tay 								;// store operator 2 reg value in y 		/ 2 cycles
		txa									;// store operator 1 reg valye in a		/ 2 cycles 		
		clc									;// clear carry							/ 2 cycles
		adc #$20							;// add #$20 to get to amp/vib/egtyp/ks../ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$00							;// set a to 0 to clear the register		/ 2 cycles
		jsr jch_quick_update_register		;// update the register
		tya									;// store operator 2 reg value in a		/ 2 cycles
		clc									;// clear carry							/ 2 cycles		
		adc #$20							;// add #$20 to get to amp/vib/egtyp/ks../ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$00							;// set a to 0 to clear the register		/ 2 cycles
		jsr jch_quick_update_register		;// update the register
		ldy var_di							;// get counter1 (voice index value) 	/ 4 cycles
		ldx jch_voice_reg_table, y			;// get voice reg value for operator 1 	/ 4 cycles
		lda jch_voice_reg_table+9, y		;// get voice reg value for operator 2 	/ 4 cycles
		tay 								;// store operator 2 reg value in y 		/ 2 cycles
		txa									;// store operator 1 reg valye in a		/ 2 cycles 		
		clc									;// clear carry							/ 2 cycles
		adc #$e0							;// add #$e0 to get to waveform select	/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$00							;// set a to 0 to clear the register		/ 2 cycles
		jsr jch_quick_update_register		;// update the register
		tya									;// store operator 2 reg value in a		/ 2 cycles
		clc									;// clear carry							/ 2 cycles		
		adc #$e0							;// add #$e0 to get to waveform select	/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$00							;// set a to 0 to clear the register		/ 2 cycles
		jsr jch_quick_update_register		;// update the register
		lda var_di  						;// get voice index in a					/ 4 cycles
		clc									;// clear carry							/ 2 cycles
		adc #$a0							;// adc #$a0 to get to F-Num LSB			/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$00							;// set a to 0 to clear the register		/ 2 cycles
		jsr jch_quick_update_register		;// update the register	
		lda var_di  						;// get voice index in a					/ 4 cycles
		clc									;// clear carry							/ 2 cycles
		adc #$b0							;// adc #$b0 to get to Oct/F-Num/Key-On	/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$00							;// set a to 0 to clear the register		/ 2 cycles
		jsr jch_quick_update_register		;// update the register	
		lda var_di  						;// get voice index in a					/ 4 cycles
		clc									;// clear carry							/ 2 cycles
		adc #$c0							;// adc #$c0 to get to Feedback/Algrtm	/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$00							;// set a to 0 to clear the register		/ 2 cycles
		jsr jch_quick_update_register		;// update the register	
		ldy var_di							;// get counter1 (voice index value) 	/ 4 cycles
		ldx jch_voice_reg_table, y			;// get voice reg value for operator 1 	/ 4 cycles
		lda jch_voice_reg_table+9, y		;// get voice reg value for operator 2 	/ 4 cycles
		tay 								;// store operator 2 reg value in y 		/ 2 cycles
		txa									;// store operator 1 reg valye in a		/ 2 cycles 	
		clc									;// clear carry							/ 2 cycles
		adc #$40							;// adc #$40 to get to Operator outputlvl/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$3f							;// set overall op. output level softest	/ 2 cycles	
		jsr jch_quick_update_register		;// update the register		
		tya									;// store operator 2 reg value in a		/ 2 cycles
		clc									;// clear carry							/ 2 cycles
		adc #$40							;// adc #$40 to get to Operator outputlvl/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$3f							;// set overall op. output level softest	/ 2 cycles
		jsr jch_quick_update_register		;// update the register						
		ldy var_di							;// get counter1 (voice index value) 	/ 4 cycles
		ldx jch_voice_reg_table, y			;// get voice reg value for operator 1 	/ 4 cycles
		lda jch_voice_reg_table+9, y		;// get voice reg value for operator 2 	/ 4 cycles
		tay 								;// store operator 2 reg value in y 		/ 2 cycles
		txa									;// store operator 1 reg valye in a		/ 2 cycles 	
		clc									;// clear carry							/ 2 cycles
		adc #$60							;// adc #$60 to get to attack/decay		/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$ff							;// set op. attack/decay to fastest		/ 2 cycles	
		jsr jch_quick_update_register		;// update the register		
		tya									;// store operator 2 reg value in a		/ 2 cycles
		clc									;// clear carry							/ 2 cycles
		adc #$60							;// adc #$60 to get to attack/decay		/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$ff							;// set op. attack/decay to fastest		/ 2 cycles
		jsr jch_quick_update_register		;// update the register						
		ldy var_di							;// get counter1 (voice index value) 	/ 4 cycles
		ldx jch_voice_reg_table, y			;// get voice reg value for operator 1 	/ 4 cycles
		lda jch_voice_reg_table+9, y		;// get voice reg value for operator 2 	/ 4 cycles
		tay 								;// store operator 2 reg value in y 		/ 2 cycles
		txa									;// store operator 1 reg valye in a		/ 2 cycles 	
		clc									;// clear carry							/ 2 cycles
		adc #$80							;// adc #$80 to get to sustain/release	/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$ff							;// set op. sustain/release to fastest	/ 2 cycles	
		jsr jch_quick_update_register		;// update the register		
		tya									;// store operator 2 reg value in a		/ 2 cycles
		clc									;// clear carry							/ 2 cycles
		adc #$80							;// adc #$80 to get to sustain/release	/ 2 cycles
		tax									;// set x to this reg value for voice	/ 2 cycles
		lda #$ff							;// set op. sustain/release to fastest	/ 2 cycles
		jsr jch_quick_update_register		;// update the register	
		rts														

sub_105E8:
jch_quick_update_register:
;// ----------------------------------------------------------------------------------------------------------
;// JCH_QUICK_UPDATE_REGISTER
;// short function to store value in A in temporary register memory (jch_table_0x822) X and immediately update ym3526
;// ----------------------------------------------------------------------------------------------------------
		ldy fm_cl_voice_bool
		beq no_update_reg
		sta fm_previous_registry_value, x 	;// store register value a in register x in temporary register table 
		jmp loc_10600						;// update the register in ym3526
no_update_reg: 
		rts
;// ----------------------------------------------------------------------------------------------------------
;// JCH_SET_REGISTER (FUNCTION)
;// load x with register, a with data for that register
;// ----------------------------------------------------------------------------------------------------------
sub_105F0:	
jch_set_register:
		cmp fm_previous_registry_value, x	;// compare with current value for register
		bne loc_105FB						;// not equal? ok go on then, change the register
		rts									;// equal, so not update needed, return please, x does not change
loc_105FB: ;//				
		sta fm_previous_registry_value, x	;// allright, store this new value in the table at pos x
loc_10600:;//				
;        stx $df40               			;// select ym3526 register
 ;       nop
  ;      nop
   ;     nop
    ;    nop                     			;// wait 12 cycles for register select
     ;   sta $df50               			;// write to it
        jsr opl2_reg_write
;        ldx #5
;lop:    dex
 ;       nop
  ;      bne lop                 			;// wait 36 cycles to do the next write
		rts									;// return from subroutine	

;// ----------------------------------------------------------------------------------------------------------
;// JCH_FM_MUSIC_INIT ;// INITIALIZE PARAMETERS
;// ----------------------------------------------------------------------------------------------------------
jch_fm_music_init:
 		;jsr jch_detect_chip
        ;bcc :+
        
        ;jsr krn_primm
        ;.byte "YM3526/YM3812 not available!",$0a,0
        ;jmp exit
        
        jsr loadfile
        beq :+
        jsr krn_primm
        .byte "i/o error",$0a,0
        jmp  exit
        
:       jsr jch_initialize_fm_music
		jsr jch_load_fmfile_pointers
        
        sei
        copypointer user_isr, safe_isr
        SetVector jch_fm_play, user_isr
        cli
        
        jsr krn_primm
        .byte "edlib player v0.2 (somewhat optimized) by mr.mouse/xentax july 2017@",$0a,0
        
:       keyin
        cmp #KEY_ESCAPE
        bne :-
        
        sei
        copypointer safe_isr, user_isr
        jsr opl2_init
        cli
exit:
        jmp (retvec)
        
loadfile:
		lda paramptr
		ldx paramptr +1
		ldy #O_RDONLY
 		jsr krn_open
 		bne @l_exit
        stx fd
		SetVector d00file, read_blkptr
		jsr krn_read
        pha
        ldx fd
        jsr krn_close
        pla
        cmp #0
@l_exit:
        rts
fd:     .res 1

;// ----------------------------------------------------------------------------------------------------------
;// JCH_DETECT_CHIP ;// CHECK CHIP EXISTENCE ;// NEED REAL HARDWARE TO WORK (NOT EMULATION)
;// returns carry set if fail
;// ----------------------------------------------------------------------------------------------------------
jch_detect_chip:
loc_1062B:			
		sei									;// sure? disable interrupts
		ldx #$04							;// set timer control byte to #$60 = clear timers T1 T2 and ignore them
		lda #$60
		jsr loc_10600
		ldx #$04							;// set timer control byte to #$80 = clear timers T1 T2 and ignore them
		lda #$80							;// reset flags for timer 1 & 2, IRQset : all other flags are ignored
		jsr loc_10600
		ldy opl_stat ;$df60							;// get soundcard/chip status byte
		sty tread							;// store it
		ldx #$02							;// Set timer1 to max value
		lda #$ff
		jsr loc_10600
		ldx #$04							;// set timer control byte to #$21 = mask timer2 (ignore bit1) and enable bit0 (load timer1 value and begin increment)
		lda #$21							;// this should lead to overflow (255) and setting of bits 7 and 6 in status byte (either timer expired, timer1 expired). 
		jsr loc_10600		
		ldy #$02*8
		ldx #$ff							;// wait about 0x200 cycles of loading the status byte
loc_1064C:		
		lda opl_stat ;$df60							;// status byte is df60 according to discussions
		dex
		bne loc_1064C
		dey
		bne loc_1064C
		and #$e0							;// and the value there with e0 (11100000, bits 7, 6 and 5) to make sure all others are 0. 
		eor #$c0							;// check if bits 7 and 6 are set (should result in 0)
		bne loc_10663						;// not zero ? jmp to set carry and leave subroutine
		tay									;// is was zero, no moce a out of the way for a moment
		lda tread							;// read the previous status byte
		and #$e0							;// "and" that with e0, ends in zero if no bits are set
		bne loc_10663						;// was it not zero ? ok, jmp to set carry and leave
		ldx #$04							;// ok previous status was no timers set. set timer control byte to #$60 = clear timers T1 T2 and ignore them
		lda #$60							
		jsr loc_10600		
		clc									;// clear the carry flag
		jmp loc_10664						;// leave the subroutine
loc_10663:				
		sec									;// set the carry flag
loc_10664:						
		cli						 			;// enalble interrupts
		rts
loc_10668:				
		txa									;// in the orignal bl is expected, assuming x for now
		and #$3f							;// AND this value with 3F
		sta fm_master_volume							;// unknown var, store this there
		rts

;// ---------------------------------------------------------------------------
;// JCH LOAD FMFILE POINTERS 
;// ---------------------------------------------------------------------------
jch_load_fmfile_pointers: 				
		;// basically, whatever is in bx at this point in the function will be multiplied by 32, 		
		;// im guessing this will be 0 for each time when one tune is played, so muisc offset 1800 is used		
		clc
		ldy #$6b							;// Get pointer to Arrangment data (word at pos 6b from the start of the music file)
		lda fm_file_base_address
		adc (fm_file_base_address), y		;// so in effect 186b, get low byte
		sta fm_file_arrdata		
		sta var_bx							;//***opt
		lda fm_file_base_address+1		
		iny		
		adc (fm_file_base_address), y			
		sta fm_file_arrdata+1
		sta var_bx+1						;//***opt

		ldy #$08							;// point to Hz byte (update speed) 
		lda (fm_file_base_address), y		;// get this
		sta fm_cycle_speed					;// store it
		ldx #$00							;// set si to 0
		stx var_si
		stx var_si+1
loc_10686:	;// **** load all 9 (voices/channels) pointers to arrangement data for each voice/channel
		ldy var_si							;// since this subroutine will only check for 12h max, the low-byte of si will suffice. 12h = 18, two bytes per voice. 	
		lda (fm_file_arrdata), y			;// get the low byte of the pointer in the fm music file
		sta tpoint1
		iny
		lda ($08), y						;// get the high byte of the pointer in the fm music file
		sta tpoint1+1
		lda tpoint1							;// check if zero
		clc
		adc tpoint1+1
		cmp #$00
		bne loc_moveon
skip:
		jmp loc_106df						;// if zero then out of here, the voice/channel does not have any arrangement data
loc_moveon:		
		lda fm_file_base_address
		sta $08
		ldx fm_file_base_address+1
		stx $09
		clc
		adc tpoint1 						;// add low byte of rel pointer in fm music file
		sta $08								;// store low byte
		bcc noadd2
		inc $09								;// carry was set to inc high byte
noadd2:		 
		lda $09
		clc
		adc tpoint1+1						;// add to high byte
		sta $09								;// okay, should have the adrr there		
		ldy #$00		
		lda ($08), y						;// get the low byte there --> read the channel speed (first word of the arrangement data per voice)
		sta tword1
		iny
		lda ($08), y						;// get the high byte there
		sta tword1+1
		inc $08								;// increase the pointer twice (inc di, inc di)
		bne inc_mov
		inc $09
inc_mov:		
		inc $08		
		bne inc_mov2		
		inc $09		
inc_mov2:		
		ldy var_si							;// just the low byte needed
		lda $08								;// store the new pointer elsewhere (pointing to next entry in the table in the music file)
		sta fm_pt_voice_arrdata, y			;// so table from 72f will list 9 words that are pointers to the start of the arrangement data (minus channel speed)  for each channel/voice
		lda $09
		sta fm_pt_voice_arrdata+1, y
		lda var_si							;// move di, si
		ldx var_si+1
		sta var_di
		stx var_di+1
		lsr var_di							;// divide by two (shr di, 1)

;//---------------------						;// divide the cycle speed by the channel speed
		lda fm_cycle_speed
		sta tread
		lda #$0
		ldx #$08
		asl tread
FML1:	rol
		cmp tword1	
		bcc FML2
		sbc tword1
FML2:	rol tread		
		dex		
		bne FML1		
;//--------------------------
		lda #$32
		sta tword1
		lda #$0
		ldx #$08
		asl tword1
FML3:	rol
		cmp tread	
		bcc FML4
		sbc tread
FML4:	rol tword1		
		dex		
		bne FML3	
;//------------------------		
		clc
		lsr tread							;// divide by two 
		cmp tread							;// compare this with the remainder in A
		bmi FML5 							;// tread higher ? then no round up
		inc tword1							;// add one speed unit to slow it down 
FML5:		 
		lda tword1							;// load the lowbyte of the tword
		ldy var_di
;//		lda #$04							;// DEBUG = SPEED of song, 1 or 0 =  50 hz, 2 = 25hz , 3 = 12,5 hz etc
		sta fm_channel_speed_counter, y						;// store at the position in the channel speed table
		lda var_bx							;// add 12 to var_bx
		clc
		adc #$12
		sta $08
		lda var_bx+1
		adc #$00							;// this will add the carry if needed
		sta $09
		clc
		lda $08								;// add var_di low to bx+12 (in 08/09)
		adc var_di
		sta $08
		lda $09
		adc #$00
		sta $09
		ldy #$00
		lda ($08), y						;// get value (byte), which is in the arrangement pointer table, after the pointers, 9 more words (unknown what they do yet)
		and #$3f							;// this is at least ANDed with 3F and
		ldy var_di
		sta fm_channel_volume, y			;// stored in this table. So the second word in the arrangement pointers table per voice/channel is channel volume (00 = max, 3f = silence)
		lda #$01							;// this is read by the irq play routine, for each of the nine voices
		sta fm_voice_has_data ,y			;// basically setting a value to 1 for each active/used voice/channel
		ldy var_si
		lda #$00
		sta fm_position_in_current_seq, y						;// word, reset a number of variable in this table
		sta fm_position_in_current_seq+1, y
		sta fm_position_in_voice_seqlist, y
		sta fm_position_in_voice_seqlist+1, y
		ldy #$00
		lda ($08), y						;// now check this second word (per channel/voice) in the arrangement pointer data again 
		cmp #$80							;// compare with 128 (0x80) (=-1)  >> UNSURE WHAT THIS CHECKS, BUT IF -1 it will not lead to clearing of vars and the voice/channel
		bcs loc_106df						;// jump if not below, so greater or equal than
		ldy var_di
		lda #$00
		sta fm_current_channel_speed_counter, y						;// reset a number of variables, set this current counter speed to 0 
		sta fm_cur_voice_volume, y						;// reset voice volume
		ldy var_si
		sta fm_cur_seq_command_tick_counter, y
		sta fm_cur_seq_command_tick_counter+1, y
		sta fm_voice_temp_slide, y
		sta fm_voice_temp_slide+1, y
		inc fm_cl_voice_bool
		jsr jch_clear_voice						;// clear voice/channel --> seems redundant if music is already initialized in previous subroutine
loc_106df:		
		lda var_bx
		ldx var_bx+1
		sta $08
		stx $09
		inc var_si
		inc var_si
		lda var_si
		cmp #$12		
		beq loc_end1
		jmp loc_10686		
loc_end1:
		rts		
;// ----------------------------------------------------------------------------------------------------------
;// JCH INITIALIZE FM MUSIC: make sure location of the D00 file is in 1006, 1007. 
;// ----------------------------------------------------------------------------------------------------------
loc_10726:
jch_initialize_fm_music:
		ldy #$00									
		sty fm_cl_voice_bool									
											;// fm_data_st_offset = is variable after 1003 jmp location, so 1006, 1007. set location of fm music file to variable - low byte, high byte
		ldx fm_data_st_offset
		stx fm_file_base_address			;//fm_data_st_offset
		ldy fm_data_st_offset+1
		sty fm_file_base_address+1			;//fm_data_st_offset+1

		ldy #$73							;// point to byte 73h from the start offset ;// get the pointer to the Arrangment data start (= that of voice 1 (D00 version 2.01))
		lda (fm_file_base_address),y							;// get the low-byte of this relative address
		clc
		adc fm_data_st_offset				;// add low byte of start offset to this one
		sta fm_start_of_arrangement_data	;// store this in the pointer variable
		sta $04								;// set zero page addr
		iny									;// increase y to get to the hi byte
		lda (fm_file_base_address),y		;// get the hi-byte of this relative address
		adc fm_data_st_offset+1				;// add hi-byte to hi-byte of start offset to this one (c will also be added if needed)
		sta fm_start_of_arrangement_data+1	;// store this in the pointer address for the hi-byte
		sta $05								;// set zero page addr
loc_1073C:	
		lda #$00
		sta fm_master_volume				;// set master volume to 0 (max) 3F = silence
		ldx #$00							;// set voice counter to 0
		stx var_di							;// for use with jch_clear_voice

loc_10743:		
		jsr jch_clear_voice					;// loc_1057a, function to reset a voice 		
		ldx var_di
		lda #$00
		sta fm_voice_has_data, x			;// clear table entry for voice (0068)
		inx	 								;// increase index
		stx var_di							;// store the value
		cpx #$9								;// is it 9 ? 
		bne loc_10743						;// no ? then loop
		lda #<fm_voice_instrument			;// reset the table pointers
		sta $06								;// set zero page
		lda #>fm_voice_instrument
		sta $07								;// set zero page
		lda #$00							;// reset the counter
		sta jch_243_tb_cnt
		lda #$00							;// okay,prepare to wipe the 243 table
		ldy #$00
		ldx #$02
lop2:
		sta (06), y
		inc $06
		bne goon1							;// no zero? (due to inc leading to 0)
		inc $07
goon1:		
	 	inc jch_243_tb_cnt					;// increase the counter
		bne lop2	
		dex									;// dey
		bne lop2							;// no? continue
		ldx #$43
lop3:
		sta ($06), y
		inc $06
		bne goon2							;// no zero? (due to inc leading to 0)
		inc $07
goon2:		
	 	dex									;// decrease the counter
		bne lop3			
;//OPTIMIZATION  ---------------> VERSION 4 : INSTRUMENTS ARE AT THE BACK OF THE FILE WITH END in FFFF
		lda fm_file_base_address
		clc
		adc #$07								;// point to version number of player
		sta $06
		lda fm_file_base_address+1												
		adc #$00								;// will add the extra carry if need be											
		sta $07			
		ldy #$00
		lda ($06), y				
		sta fm_version
		cmp #$04								;// is the version 4?
		bne set_73								;// no, then set versionn 2 calculation
		lda #$71
		sta end_add+1
		jmp end_check
set_73:
		lda #$73
		sta end_add+1
end_check:
		lda fm_file_base_address												
		clc												
		adc #$6f								;// point to fm file base address + 6f (= pointer to instrument tables)					
		sta $06												
		lda fm_file_base_address+1												
		adc #$00								;// will add the extra carry if need be											
		sta $07		
		ldy #$00
		lda ($06), y
		sta var_bp
		iny
		lda ($06), y
		sta $07
		lda var_bp
		sta $06
		lda fm_file_base_address												
		clc												
end_add:
		adc #$73								;// point to fm file base address + 73 (= pointer to special fx data, version 2)	or +71 (song descr, version 4)				
		sta $08												
		lda fm_file_base_address+1												
		adc #$00								;// will add the extra carry if need be											
		sta $09				
	    ldy #$00
		lda ($08), y
		sta var_bp
		iny
		lda ($08), y
		sta $09
		lda var_bp
		sta $08
		sec										;// calculate size of instrument data
		lda $08
		sbc $06
		sta $08
		lda $09
		sbc $07
		sta $09
		clc										;// shift right 4 times (divide by 16) to get the number of instruments
		lsr $09
		ror $08
		lsr $09
		ror $08
		lsr $09
		ror $08
		lsr $09
		ror $08
skip_calculation:
		lda fm_file_base_address												
		clc												
		adc $06								;// point to fm file base address + 6f (= pointer to instrument tables)					
		sta $06												
		lda fm_file_base_address+1												
		adc $07								;// will add the extra carry if need be											
		sta $07		
		
		ldy #$00
		lda #$00				
		ldx #$00				
		sta var_bp				
		sty var_bp+1				
loc_pointon:		
		clc						
		asl var_bp								;// shift the 16-bit value of the instrument left 4 times (do the value times 16, since each instrument data block is 16 bytes. So, if instrument 6 (0006) * 16 = 96 (60h).  
		rol	var_bp+1							;// NOTE: this can be optimized. These pointers can be precalculated and then looked up from a table to save cycles (at the cost of some memory)
		asl var_bp						
		rol	var_bp+1							
		asl var_bp						
		rol	var_bp+1								
		asl var_bp						
		rol	var_bp+1								
		lda $06														
		clc													
		adc var_bp													
		sta fm_opt_ins_pointers, x													
		lda $07												
		adc var_bp+1													
		sta fm_opt_ins_pointers+1, x				
		clc													
		inx				
		inx				
		iny 
		cpy $08 				
		beq loc_pointdone
;//		lda $08
		sty var_bp
		lda #$00
		sta var_bp+1
		jmp loc_pointon
;//===============		
loc_pointdone:		 
		ldx #$00 							;// sequence number
		clc
		ldy #$6d							;// get value at address 6d of the fm file = pointer to (first) sequence pointer (list of pointers to sequences)
		lda (fm_file_base_address), y						;// $02 should have the low byte of the address of the fm file	
		adc fm_file_base_address
		sta $06
		iny 
		lda (fm_file_base_address), y 		;// get high byte of this address
		adc fm_file_base_address+1
		sta $07								;// $06/$07 is now pointing to the sequence pointer list list
		lda #$00							;// min out previous sequence check
		sta var_di					
		sta var_di+1
loc_get_next_seq:		
		ldy #$00							;// get the pointer
		lda ($06), y		
		sta var_bp			
		iny 		
		lda ($06), y		
		sta var_bp+1		
		sec		
		lda var_bp		
		sbc var_di							;// subtract previous pointer		
		bmi loc_end_get_next_seq			;// negative? then we're done getting all the pointers
		lda var_bp+1		
		sbc var_di+1
		bmi loc_end_get_next_seq2
loc_save_seq_pointer:
		clc
		lda var_bp
		sta var_di
		adc fm_file_base_address	
		sta fm_opt_seq_pointers, x
		lda var_bp+1		
		sta var_di+1
		adc fm_file_base_address+1	
		sta fm_opt_seq_pointers+1, x
		inx 		
		inx		
		clc		
		lda $06		
		adc #$02		
		sta $06		
		bcc loc_save_seq_noinc		
		inc $07		
loc_save_seq_noinc:				
		jmp loc_get_next_seq
loc_end_get_next_seq:				
		lda var_bp+1		
		sbc var_di+1
		bpl loc_save_seq_pointer
loc_end_get_next_seq2:						
;//OPTIMIZATION END
		ldx #$01							;// select register 1
		lda #$20							;// ORIGINAL: set bit 5 (32,or 20h), allow multiple waveforms. We say NO in case of ym3526. This will make OPL2 tunes sound off though 
		jsr loc_10600						;// set the soundchip register
		ldx #$08							;// select register 1
		lda #$00							;// select 0 for bit 7 of register 8: set FM music mode!
		jsr loc_10600						;// set the soundchip register		
		ldx #$bd							;// select register BD
		lda #$c0							;// disable rhythm (clear bit 5),  AM depth is 4.8dB (set bit 7), Vibrato = 14 cent (set bit 6)
		jsr loc_10600						;// set the soundchip register			 	
		clc
		rts
		
;//----------------------------------------------------------------------------------------------------------------
;// FM D00 PLAYER VARIABLE MEMORY BLOCK
;//----------------------------------------------------------------------------------------------------------------
fm_voice_has_data: .res 9,0				;// 0 = no data, no playing; 1 = data, process playing. per voice
fm_local_voice_slide: .word	0				;// note slide counter (word)
fm_master_volume: .byte 0					;// master volume (3f = silence)
fm_start_of_arrangement_data: .word 0		;// pointer to start of the sequence arrangement (tracks, so you will) 
fm_voice_instrument: .res 18,0				;// 6D5 = current channel/voice instrument (effect cxxxx)
fm_cur_seq_command_tick_counter: .res 18,0	;// current sequence command time/tick counter (per channel/voice)	
fm_voice_value: .res 18, 0					;// 6f9 = effect 6 (cut voice), 9 voices, 9 words, but also others store value here
fm_position_in_current_seq: .res 18, 0		;// the position in the current sequence	
fm_position_in_voice_seqlist: .res 18, 0	;// position counter for the sequence in the sequence list
fm_pt_voice_arrdata: .res 18, 0			;// pointers to start of arrangement data per channel/voice (words, 9)
fm_current_frequency: .res 18, 0			;// fm_current_frequency
fm_transpose_value: .res 18, 0				;// fm_transpose_value for sequence by voice
fm_voice_temp_slide: .res 18, 0			;// temporary slide valure storage by voice
var_777: .res 9,0							;// what is this doing?
fm_cur_vibrato_speed_counter: .res 9,0		;// counter to keep track of the speed of the vibrato
fm_voice_vibrato_speed: .res 9,0			;// the vibrato speed of the voice
fm_voice_vibrato_depth: .res 9,0			;// the vibrato depth of the voice
fm_ins_multipurpose: .res 18, 0			;// value for the multipurpose register of the OPL by voice
var_7ad: .res 9,0							;// what is this doing?
fm_ins_fine_tune: .res 9,0					;// fine tune value per voice
fm_temp_ins_hardrestart: .res 9,0			;// temp hard restart value by voice
fm_ins_hardrestart: .res 9,0				;// instrument hard restart value (number of ticks/time units/calls to player) before start
fm_voice_vibrato: .res 18, 0				;// 7D1 = current channel/voice vibrato (effect 7xxx)
fm_voice_slide: .res 18, 0					;// 7E3 = current channel/voice slide (effect Dxxx)
fm_voice_freq: .res 18, 0					;// 7F5 = current freq for voice?
fm_voice_volume: .res 9, 0					;// 807 = current channel/voice volume (effect 9xxx)
fm_current_channel_speed_counter: .res 9, 0	;// current channel speed counter
fm_channel_speed_counter: .res 9, 0		;// channel speed table (bytes), one for each voice/channel (9)
fm_previous_registry_value: .res 9, 0			;// 822 : previous register value
fm_previous_registry_value_preset: .res 9, 0	;// 82b : previous register value preset
fm_channel_volume: .res 36, 0				;// channel volume (3f = silence)
fm_cur_voice_volume: .res 32, 0				;// current colume of the voice
fm_ins_mainvolume_ksl: .res 32, 0				;// instrument register value for volume/ksl
fm_ins_modulator_level: .res 32, 0				;// instrument register modulator level 
fm_ins_feedback_level: .res 52, 0				;// instrument register feedback level
fm_minimum_voice_volume: .res 9, 0			;// temporary voice level/volume
fm_sequence_var_type: .res 35, 0				;// 01 = 7e(hold)/0(rest), 02 = Effect, 00 = standard note
;// JCH_VOICE_REG_TABLE (9 voices, for operator 1 and operator 2 (match 3, 0; 4, 1; 5, 2 etc.)
jch_voice_reg_table: .byte 	$3, $4, $5, $0b, $0c, $0d, $13, $14, $15, $0, $1, $2, $8, $9, $0a, $10, $11, $12
fm_frequency_table: .byte 87, 1, 107, 1, 129, 1, 152, 1, 176, 1, 202, 1, 229, 1, 2, 2, 32, 2, 65
   .byte 2, 99, 2, 135, 2, 87, 5, 107, 5, 129, 5, 152, 5, 176, 5, 202, 5, 229, 5
   .byte 2, 6, 32, 6, 65, 6, 99, 6, 135, 6, 87, 9, 107, 9, 129, 9, 152, 9, 176
   .byte 9, 202, 9, 229, 9, 2, 10, 32, 10, 65, 10, 99, 10, 135, 10, 87, 13, 107, 13
   .byte 129, 13, 152, 13, 176, 13, 202, 13, 229, 13, 2, 14, 32, 14, 65, 14, 99, 14, 135
   .byte 14, 87, 17, 107, 17, 129, 17, 152, 17, 176, 17, 202, 17, 229, 17, 2, 18, 32, 18
   .byte 65, 18, 99, 18, 135, 18, 87, 21, 107, 21, 129, 21, 152, 21, 176, 21, 202, 21, 229
   .byte 21, 2, 22, 32, 22, 65, 22, 99, 22, 135, 22, 87, 25, 107, 25, 129, 25, 152, 25
   .byte 176, 25, 202, 25, 229, 25, 2, 26, 32, 26, 65, 26, 99, 26, 135, 26, 87, 29, 107
   .byte 29, 129, 29, 152, 29, 176, 29, 202, 29, 229, 29, 2, 30, 32, 30, 65, 30, 99, 30
   .byte 135, 30, 0
fm_opt_ins_pointers: .res 64, 0 			;// optimization: 32 16-bit pointers to instrument data
fm_opt_seq_pointers: .res 128, 0 			;// optimization: 64 16-bit pointers to sequence data
fm_cycle_speed: .byte 0
fm_cl_voice_bool: .byte 0
fm_version: .byte 0
;// x86 cross registers
var_dx: .word 0
var_cx: .word 0
var_bx: .word 0
var_ax: .word 0
var_di: .word 0
var_si: .word 0
var_bp: .word 0
jch_243_tb_cnt: .byte 0
tread: .byte 0
tpoint1: .word 0 
tpoint2: .word 0 
tword1: .word 0

safe_isr:   .res 2
.data
d00file:
;.incbin "hard guitar.d00"
;.incbin "like galway.d00"
;.incbin "plasma world.d00"
;.incbin "the model (kraftwerk cover).d00"
;.incbin "space13.d00"
;.incbin "bordella 64 conversion.d00"
;.incbin "summertime.d00"
;incbin "hybrid.d00"
;.incbin "blastersound groove.d00"

.segment "STARTUP"