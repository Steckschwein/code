
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/common.inc"
.include "../steckos/asminc/appstart.inc"

.include "lcd.inc"



.import hexout
.import lcd_init_4bit, lcd_send_byte, lcd_command


	appstart $1000

	jsr lcd_init_4bit


@l:
	keyin
	cmp #$03
	bne @l1
 	jmp @end
@l1:
	cmp #$1b
	bne @l2
	jmp @end
@l2:
	cmp #'<'
	bne @next

	lda #LCD_INST_SHIFT|LCD_BIT_SHIFT_SC
	jsr lcd_command
	bra @l

@next:
	cmp #'>'
	bne @next2

	lda #LCD_INST_SHIFT|LCD_BIT_SHIFT_RL|LCD_BIT_SHIFT_SC
	jsr lcd_command
	bra @l


@next2:
	cmp #$12
	bne @next3

	lda #LCD_INST_CURSOR_HOME
	jsr lcd_command
	bra @l

@next3:
	cmp #$1F
	bne @next4

	lda #LCD_INST_SET_DDRAM_ADDR|$40
	jsr lcd_command
	jmp @l

@next4:
	cmp #$1E
	bne @next5

	lda #LCD_INST_SET_DDRAM_ADDR
	jsr lcd_command
	jmp @l

@next5:
	cmp #$11
	bne @next6

	lda #LCD_INST_SHIFT
	jsr lcd_command
	bra @l

@next6:
	cmp #$10
	bne @next7

	lda #LCD_INST_SHIFT|LCD_BIT_SHIFT_RL
	jsr lcd_command
	bra @l

@next7:
	cmp #$08
	bne @out

	lda #LCD_INST_SHIFT
	jsr lcd_command
	lda #' '



@out:
	jsr hexout
	jsr lcd_send_byte
	;jsr delay_40us
	jmp @l



@end:
	;jmp (retvec)
	jmp krn_upload
