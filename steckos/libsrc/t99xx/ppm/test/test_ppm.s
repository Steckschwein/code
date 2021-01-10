	.include "asmunit.inc" 	; test api

	.include "common.inc"
	.include "errno.inc"
	.include "zeropage.inc"

	.importzp ptr2

	.import ppm_parse_header
	.import rgb_bytes_to_grb

	.import asmunit_chrout

; from ppmview
.import ppm_data
.import ppm_width
.import ppm_height

.macro setup label
	test_name label
	stz ppm_width
	stz ppm_height
.endmacro

.code

;-------------
	setup "ppm_parse_header valid"
	m_memcpy test_ppm_header_valid, ppm_data, 16
	jsr ppm_parse_header
	assertZero 1		;
	assertA 0
	assert8 <256, ppm_width
	assert8 212, ppm_height

;-------------
	setup "parse_header not ppm"
	m_memcpy test_ppm_header_notppm, ppm_data, 16
	jsr ppm_parse_header
	assertCarry 1		;error
	assertA $ff

;-------------
	setup "ppm_parse_header wrong height"
	m_memcpy test_ppm_header_wrong_height, ppm_data, 16
	jsr ppm_parse_header
	assertZero 0		;error
	assertA $ff

;-------------
	setup "ppm_parse_header wrong depth"
	m_memcpy test_ppm_header_wrong_depth, ppm_data, 16
	jsr ppm_parse_header
	assertZero 0		;error
	assertA $ff

;-------------
	setup "ppm_parse_header with comment"
	m_memcpy test_ppm_header_comment, ppm_data, 127
	jsr ppm_parse_header
	assertZero 1		;
	assertA 0
	assert8 <256, ppm_width
	assert8 192, ppm_height

	setup "rgb_bytes_to_grb"
 	SetVector ppm_data, read_blkptr
	m_memcpy test_ppm_data, ppm_data, 32

	ldy #0
	jsr rgb_bytes_to_grb
	assertA 0

	jsr rgb_bytes_to_grb
	assertA $ff

	jsr rgb_bytes_to_grb
	assertA $ff

	jsr rgb_bytes_to_grb
	assertA $49

	jsr rgb_bytes_to_grb
	assertA $51

	jsr rgb_bytes_to_grb
	assertA $ba

	brk

.export krn_primm=mock
.export hexout=mock
.export fopen=mock, fread=mock, fclose=mock
.export krn_textui_enable=mock
.export krn_textui_disable=mock
.export krn_textui_init=mock
.export krn_display_off=mock
.export krn_getkey=mock

mock:
	rts

test_ppm_header_valid:
	.byte "P6",$0a,"256 212",$0a,"255",$0a
test_ppm_header_notppm:
	.byte "PNG",$0a,"256 171",$0a,"255",$0a
test_ppm_p3_header_valid:
	.byte "P3",$0a,"256 171",$0a,"255",$0a
test_ppm_header_wrong_height:
	.byte "P6",$0a,"256 213",$0a,"255",$0a
test_ppm_header_wrong_depth:
	.byte "P6",$0a,"256 212",$0a,"65535",$0a
test_ppm_header_comment:
	.byte "P6",$0a,"#Compressed with JPEG Optimizer 4.00, www.xat.com",$0a,"#comment 2",$0a,"256 192",$0a,"255",$0a

test_ppm_data:	; ppm RGB => GRB 3,3,2
	.byte $0, $0, $0		;0
	.byte $ff, $ff, $ff	;$ff
	.byte $e0, $e0, $c0	;$ff
	.byte $40, $40, $40	;$49
	.byte $80, $40, $40	;$51
	.byte $d6, $b5, $81	;$ba


.segment "ASMUNIT"
