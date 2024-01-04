
.include "common.inc"
.include "zeropage.inc"
.include "asmunit.inc" ; test api

.import asmunit_chrout

.export krn_chrout=asmunit_chrout
.export textui_chrout=asmunit_chrout
.export textui_update_crs_ptr=dummy
.export textui_blank=dummy



.import ansi_chrout	; uut

.import ansi_state
.import ansi_index
.import ansi_param1
.import ansi_param2

.code

  test_name "ansi_chrout"

	stz ansi_state
	
	lda #'A'
	sta ansi_index
	jsr ansi_chrout

	assertA 'A'
	assert8 $00, ansi_state

  test_name "ansi_chrout esc"

	lda #27
	jsr ansi_chrout

	assert8 $80, ansi_state

	lda #'['
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $00, ansi_index

	lda #'5'
  jsr ansi_chrout

	assertA 5
	assert8 5, ansi_param1
	assert8 $41, ansi_state
	assert8 $00, ansi_index

	lda #'2'
	jsr ansi_chrout

	;assertA 2
	assert8 $00, ansi_index
	assert8 $41, ansi_state
	assert8 52, ansi_param1

	lda #';'
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $01, ansi_index

	lda #'2'
	jsr ansi_chrout

	assert8 $41, ansi_state
	assert8 2, ansi_param2

	lda #'3'
	jsr ansi_chrout

	assert8 $41, ansi_state
	assert8 23, ansi_param2


  test_name "ansi_chrout cursor down"
	stz ansi_state

	stz crs_y

	lda #27
	jsr ansi_chrout

	assert8 $80, ansi_state

	lda #'['
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $00, ansi_index

	lda #'3'
  jsr ansi_chrout

	assertA 3
	assert8 3, ansi_param1
	;assert8 $41, ansi_state
	assert8 $00, ansi_index

	lda #'B'
	jsr ansi_chrout

	assert8 $03, crs_y
	


  test_name "ansi_chrout cursor left"
	stz ansi_state

	stz crs_x

	lda #27
	jsr ansi_chrout

	assert8 $80, ansi_state

	lda #'['
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $00, ansi_index

	lda #'5'
  jsr ansi_chrout

	assertA 5
	assert8 5, ansi_param1
	;assert8 $41, ansi_state
	assert8 $00, ansi_index

	lda #'D'
	jsr ansi_chrout

	assert8 $05, crs_x



  test_name "ansi_chrout cursor right"
	stz ansi_state

	lda #27
	jsr ansi_chrout

	assert8 $80, ansi_state

	lda #'['
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $00, ansi_index

	lda #'3'
  jsr ansi_chrout

	assertA 3
	assert8 3, ansi_param1
	;assert8 $41, ansi_state
	assert8 $00, ansi_index

	lda #'C'
	jsr ansi_chrout

	assert8 2, crs_x

  test_name "ansi_chrout cursor up"
	stz ansi_state

	lda #27
	jsr ansi_chrout

	assert8 $80, ansi_state

	lda #'['
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $00, ansi_index

	lda #'2'
  jsr ansi_chrout

	assertA 2
	assert8 2, ansi_param1
	;assert8 $41, ansi_state
	assert8 $00, ansi_index

	lda #'A'
	jsr ansi_chrout

	assert8 1, crs_y
     

	brk
dummy:
	rts
