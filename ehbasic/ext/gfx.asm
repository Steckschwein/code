.include "vdp.inc"

.import	vdp_display_off
.import	vdp_mc_on
.import	vdp_mc_blank
.import	vdp_mc_init_screen
.import	vdp_mc_set_pixel

.import vdp_gfx2_blank
.import vdp_gfx2_on
.import vdp_gfx2_set_pixel

.export GFX_2_On
.export GFX_MC_On
.export GFX_MC_Plot
.export GFX_2_Plot
.export GFX_Off
.export GFX_BgColor

;
;	within basic define extensions as follows
;
;	PLOT = $xxxx 			- assign the adress of GFX_Plot from label file
;	CALL PLOT,X,Y,COLOR		- invoke GFX_Plot with CALL api
;
GFX_BgColor:
		JSR LAB_SCGB ; scan for "," and get byte 
		stx a_vreg
		lda #$87
		sta a_vreg
		RTS ; return to BASIC

GFX_Off:
		sei
		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		cli
		jmp	krn_textui_enable

GFX_MC_On:
		sei
		jsr	krn_textui_disable			;disable textui
		jsr krn_display_off
		lda #0 ; black/black
		jsr vdp_mc_blank
		jsr	vdp_mc_on
		cli
		rts

GFX_2_On:
		sei
		jsr	krn_textui_disable			;disable textui
		jsr krn_display_off
		lda #Gray<<4|Black
		jsr vdp_gfx2_blank
		jsr	vdp_gfx2_on
		cli
		rts

GFX_2_Plot:
		jsr GFX_Plot_Prepare
		jmp vdp_gfx2_set_pixel
GFX_MC_Plot:
		jsr GFX_Plot_Prepare
		jmp vdp_mc_set_pixel

GFX_Plot_Prepare:
		JSR LAB_SCGB 	; scan for "," and get byte 
		stx PLOT_XBYT	; save plot x 
		JSR LAB_SCGB 	; scan for "," and get byte 
		stx PLOT_YBYT	; save plot y
		JSR LAB_SCGB 	; scan for "," and get byte 
		txa				; color to A
		ldx PLOT_XBYT
		ldy PLOT_YBYT
		SyncBlank		; sync
		rts
		
PLOT_XBYT:
               .byte $00 ; set default
PLOT_YBYT:
               .byte $00 ; set default