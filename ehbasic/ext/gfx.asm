.include "vdp.inc"

.import	vdp_display_off
.import	vdp_mc_on
.import	vdp_mc_blank
.import	vdp_mc_init_screen
.import	vdp_mc_set_pixel

.import vdp_gfx2_blank
.import vdp_gfx2_on
.import vdp_gfx2_set_pixel

.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_gfx7_set_pixel
.import vdp_gfx7_set_pixel_cmd

.import	vdp_bgcolor

.export GFX_7_Plot
.export GFX_MC_Plot
.export GFX_2_Plot
.export GFX_BgColor

;
;	within basic define extensions as follows
;
;	PLOT = $xxxx 				- assign the adress of GFX_Plot from label file
;	CALL PLOT,X,Y,COLOR		- invoke GFX_Plot with CALL api
;

;	in .A - mode 0-7
gfx_mode:
		php
		sei
		asl ; offset
		pha
		jsr krn_textui_disable			;disable textui
		jsr krn_display_off
		plx
		jsr _gfx_set_mode
		plp
		rts

;	in .A - mode 0-7
gfx_plot:
      asl ; offset
		tax
      jmp (gfx_plot_table,x)

_gfx_set_mode:
		jmp (_gfx_mode_table,x)

		
_gfx_mode_table:
      .word GFX_Off  ; 0
      .word GFX_Off  ; 1
      .word vdp_gfx2_on ; 2
      .word vdp_mc_on ; 3
      .word gfx_dummy; 4
      .word gfx_dummy; 5
      .word gfx_dummy; 6
      .word vdp_gfx7_on ; 7
gfx_dummy:
      rts

gfx_plot_table:
      .word gfx_dummy  ; 0
      .word gfx_dummy  ; 1
      .word GFX_2_Plot ; 2
      .word GFX_MC_Plot; 3
      .word gfx_dummy; 4
      .word gfx_dummy; 5
      .word gfx_dummy; 6
      .word GFX_7_Plot ; 7

GFX_BgColor:
		JSR LAB_GTBY	; Get byte parameter and ensure numeric type, else do type mismatch error. Return the byte in X.
		txa
		jmp vdp_bgcolor

GFX_Off = krn_textui_init     ;restore textui

GFX_2_Plot:
		jsr GFX_Plot_Begin
		jsr vdp_gfx2_set_pixel
		bra GFX_Plot_End
    
GFX_MC_Plot:
		jsr GFX_Plot_Begin
		jsr vdp_mc_set_pixel
		bra GFX_Plot_End

GFX_7_Plot:
		jsr GFX_Plot_Begin
		jsr vdp_gfx7_set_pixel
		bra GFX_Plot_End      

GFX_Plot_Begin:
		JSR LAB_GTBY	; Get byte parameter and ensure numeric type, else do type mismatch error. Return the byte in X.
		stx PLOT_XBYT	; save plot x
		JSR LAB_SCGB 	; scan for "," and get byte
		stx PLOT_YBYT	; save plot y
		JSR LAB_SCGB 	; scan for "," and get byte
		txa				    ; color to A
 		ldx PLOT_XBYT
		ldy PLOT_YBYT
		rts
    
GFX_Plot_End:
		vdp_wait_l 6
		vdp_sreg <.HIWORD(ADDRESS_TEXT_SCREEN<<2), v_reg14
		rts

GFX_MODE:  .res 1, 0
PLOT_XBYT: .res 1
PLOT_YBYT: .res 1