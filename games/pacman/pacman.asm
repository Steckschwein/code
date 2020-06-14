		.include "pacman.inc"

		.export game_state

		.import gfx_mode_on
		.import gfx_mode_off
		.import gfx_init
		.import gfx_display_maze
		.import frame_isr

		.import io_init
		.import io_exit
		.import io_irq_on
		.import sound_init
		.import sound_play
		.import boot
		.import intro
		.import game

		.exportzp p_maze, p_video, p_sound, p_text, p_game

.zeropage
p_video:  .res 2
p_sound:  .res 2
p_text:   .res 2
p_game:   .res 2
p_maze:   .res 2

.code
.proc	_main: near
main:
		sei
		jsr io_init
		jsr sound_init
		jsr gfx_init
		jsr gfx_mode_on

		jsr io_irq_on
		setIRQ frame_isr, _save_irq
		cli

		jsr init

		jsr boot
@intro:
		jsr intro
		bit game_state+GameState::state
		bmi @exit
		jsr game
		bit game_state+GameState::state
		bmi @exit
		jmp @intro
@exit:
		jsr gfx_mode_off

		restoreIRQ _save_irq

		jmp io_exit

init:
		ldx #.sizeof(GameState)-1
		lda #0
:		sta game_state,x
		dex
		bpl :-
		rts
.endproc

.bss
_save_irq:  .res 2, 0
game_state:
  .tag GameState
video_tmp:  .res 1
.export sound_tmp
sound_tmp:  .res 1
.export game_tmp
game_tmp:   .res 1
.export game_tmp2
game_tmp2:  .res 1
.export gfx_tmp
gfx_tmp:    .res 1
.export text_color
text_color:  .res 1
