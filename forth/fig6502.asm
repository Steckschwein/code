.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/common.inc"

;
;                        Through the courtesy of
;
;                         FORTH INTEREST GROUP
;                            P.O. BOX  2154
;                         OAKLAND, CALIFORNIA
;                                94621
;
;
;                             Release 1.k0010
;
;                        with compiler security
;                                  and
;                        variable length names
;
;    Further distribution need not include this notice.
;    The FIG installation Manual is required as it contains
;    the model of FORTH and glossary of the system.
;    Might be available from FIG at the above address for $95.00 postpaid.
;
;    Translated from the FIG model by W.F. Ragsdale with input-
;    output given for the Rockwell System-65. Transportation to
;    other systems requires only the alteration of :
;                 XEMIT, XKEY, XQTER, XCR, AND RSLW
;
;    Equates giving memory assignments, machine
;    registers, and disk parameters.
;
SSIZE           =     128               ;sector size in bytes
NBUF            =     8                 ;number of buffers desired in RAM
;                             (SSIZE*NBUF >= 1024 bytes)
SECTR           =     800               ;sector per drive
;                              forcing high drive to zero
SECTL           =     1600              ;sector limit for two drives
;                              of 800 per drive.
BMAG            =     1056              ;total buffer magnitude, in bytes
;                              expressed by SSIZE+4*NBUF
;
BOS             =     $20               ;bottom of data stack, in zero-page.
TOS             =     $9F               ;top of data stack, in zero-page.
N               =     TOS+8             ;scratch workspace.
IP              =     N+8               ;interpretive pointer.
W               =     IP+3              ;code field pointer.
UP              =     W+2               ;user area pointer.
XSAVE           =     UP+2              ;temporary for X register.
;
TIBX            =     $0600             ;terminal input buffer of 84 bytes.
ORIG            =     $1000             ;origin of FORTH's Dictionary.
MEM             =     $8000             ;top of assigned memory+1 byte.
UAREA           =     MEM-128           ;128 bytes of user area
DAREA           =     UAREA-BMAG        ;disk buffer space.
;
cout     = krn_chrout
cin      = krn_keyin         ; input one ASCII char. to term.
crout       = lf         ; terminal return and line feed.


;         Monitor calls for terminal support
;
;
;    From DAREA downward to the top of the dictionary is free
;    space where the user's applications are compiled.
;
;    Boot up parameters. This area provides jump vectors
;    to Boot up  code, and parameters describing the system.
;
;
;        .ORG   ORIG
;
                         ; User cold entry point
;        org   $0400-4
        .word $1000
        .word TOP-ENTER


ENTER    
       nop                     ;Vector to COLD entry
                jmp   COLD+2            ;
REENTR          nop                     ;User Warm entry point
                jmp   WARM              ;Vector to WARM entry
                .word    $0004             ;6502 in radix-36
                .word    $5ED2             ;
                .word    NTOP              ;Name address of MON
;                .word    $7F               ;Backspace Character
                .word    $08               ;Backspace Character
                .word    UAREA             ;Initial User Area
                .word    TOS               ;Initial Top of Stack
                .word    $1FF              ;Initial Top of Return Stack
                .word    TIBX              ;Initial terminal input buffer
;
;
                .word    31                ;Initial name field width
                .word    1                 ;0=nod disk, 1=disk
                .word    TOP               ;Initial fence address
                .word    TOP               ;Initial top of dictionary
                .word    VL0               ;Initial Vocabulary link ptr.
 ;include "io.inc"
;
;    The following offset adjusts all code fields to avoid an
;    address ending $XXFF. This must be checked and altered on
;    any alteration , for the indirect jump at W-1 to operate !
;
;          .ORG *+2         ;.ORIGIN *+2
                nop                     
;
;
;                                       LIT
;                                       SCREEN 13 LINE 1
;
L22             .byte    $83,"LI",$D4      ;<--- name field
;                          <----- link field
                .word    00                ;last link marked by zero
LIT             .word    *+2               ;<----- code address field
                lda   (IP),y            ;<----- start of parameter field
                pha                     
                inc   IP                
                bne   L30               
                inc   IP+1              
L30             lda   (IP),y            
L31             inc   IP                
                bne   PUSH              
                inc   IP+1              
;
PUSH            dex                     
                dex                     
;
PUT             sta   1,x               
                pla                     
                sta   0,x               
;
;    NEXT is the address interpreter that moves from machine
;    level word to word.
;
NEXT            ldy   #1                
                lda   (IP),y            ;Fetch code field address pointed
                sta   W+1               ;to by IP.
                dey                     
                lda   (IP),y            
                sta   W                 
                clc                     ;Increment IP by two.
                lda   IP                
                adc   #2                
                sta   IP                
                bcc   L54               
                inc   IP+1              
L54             jmp   W-1               ;Jump to an indirect jump (W) which
;                        vectors to code pointed to by a code
;                        field.
;
;    CLIT pushes the next inline byte to data stack
;
L35             .byte    $84,"CLI",$D4     
                .word    L22               ;Link to LIT
CLIT            .word    *+2               
                lda   (IP),y            
                pha                     
                tya                     
                beq   L31               ;a forced branch into LIT

;
;
SETUP           asl   a                 
                sta   N-1               
L63             lda   0,x               
                sta   N,y               
                inx                     
                iny                     
                cpy   N-1               
                bne   L63               
                ldy   #0                
                rts                     
;
;                                       EXCECUTE
;                                       SCREEN 14 LINE 11
;
L75             .byte    $87,"EXECUT",$C5  
                .word    L35               ;link to CLIT
EXEC            .word    *+2               
                lda   0,x               
                sta   W                 
                lda   1,x               
                sta   W+1               
                inx                     
                inx                     
                jmp   W-1               ;to JMP (W) in z-page
;
;                                       BRANCH
;                                       SCREEN 15 LINE 11
;
L89             .byte    $86,"BRANC",$C8   
                .word    L75               ;link to EXCECUTE
BRAN            .word    *+2               
                clc                     
                lda   (IP),y            
                adc   IP                
                pha                     
                iny                     
                lda   (IP),y            
                adc   IP+1              
                sta   IP+1              
                pla                     
                sta   IP                
                jmp   NEXT +2           
;
;                                       0BRANCH
;                                       SCREEN 15 LINE 6
;
L107            .byte    $87,"0BRANC",$C8  
                .word    L89               ;link to BRANCH
ZBRAN           .word    *+2               
                inx                     
                inx                     
                lda   $FE,x             
                ora   $FF,x             
                beq   BRAN+2            
;
BUMP            clc                     
                lda   IP                
                adc   #2                
                sta   IP                
                bcc   L122              
                inc   IP+1              
L122            jmp   NEXT              
;
;                                       (LOOP)
;                                       SCREEN 16 LINE 1
;
L127            .byte    $86,"(LOOP",$A9   
                .word    L107              ;link to 0BRANCH
PLOOP           .word    L130              
L130            stx   XSAVE             
                tsx                     
                inc   $101,x            
                bne   PL1               
                inc   $102,x            
;
PL1             clc                     
                lda   $103,x            
                sbc   $101,x            
                lda   $104,x            
                sbc   $102,x            
;
PL2             ldx   XSAVE             
                asl   a                 
                bcc   BRAN+2            
                pla                     
                pla                     
                pla                     
                pla                     
                jmp   BUMP              
;
;                                       (+LOOP)
;                                       SCREEN 16 LINE 8
;
L154            .byte    $87,"(+LOOP",$A9  
                .word    L127              ;link to (loop)
PPLOO           .word    *+2               
                inx                     
                inx                     
                stx   XSAVE             
                lda   $FF,x             
                pha                     
                pha                     
                lda   $FE,x             
                tsx                     
                inx                     
                inx                     
                clc                     
                adc   $101,x            
                sta   $101,x            
                pla                     
                adc   $102,x            
                sta   $102,x            
                pla                     
                bpl   PL1               
                clc                     
                lda   $101,x            
                sbc   $103,x            
                lda   $102,x            
                sbc   $104,x            
                jmp   PL2               
;
;                                       (DO)
;                                       SCREEN 17 LINE 2
;
L185            .byte    $84,"(DO",$A9     
                .word    L154              ;link to (+LOOP)
PDO             .word    *+2               
                lda   3,x               
                pha                     
                lda   2,x               
                pha                     
                lda   1,x               
                pha                     
                lda   0,x               
                pha                     
;
POPTWO          inx                     
                inx                     
;
;
;
POP             inx                     
                inx                     
                jmp   NEXT              
;
;                                       I
;                                       SCREEN 17 LINE 9
;
L207            .byte    $81,$C9           
                .word    L185              ;link to (DO)
I               .word    R+2               ;share the code for R
;
;                                       DIGIT
;                                       SCREEN 18 LINE 1
;
L214            .byte    $85,"DIGI",$D4    
                .word    L207              ;link to I
DIGIT           .word    *+2               
                sec                     
                lda   2,x               
                sbc   #$30              
                bmi   L234              
                cmp   #$A               
                bmi   L227              
                sec                     
                sbc   #7                
                cmp   #$A               
                bmi   L234              
L227            cmp   0,x               
                bpl   L234              
                sta   2,x               
                lda   #1                
                pha                     
                tya                     
                jmp   PUT               ;exit true with converted value
L234            tya                     
                pha                     
                inx                     
                inx                     
                jmp   PUT               ;exit false with bad conversion
;
;                                       (FIND)
;                                       SCREEN 19 LINE 1
;
L243            .byte    $86,"(FIND",$A9   
                .word    L214              ;Link to DIGIT
PFIND           .word    *+2               
                lda   #2                
                jsr   SETUP             
                stx   XSAVE             
L249            ldy   #0                
                lda   (N),y             
                eor   (N+2),y           
;
;
                and   #$3F              
                bne   L281              
L254            iny                     
                lda   (N),y             
                eor   (N+2),y           
                asl   a                 
                bne   L280              
                bcc   L254              
                ldx   XSAVE             
                dex                     
                dex                     
                dex                     
                dex                     
                clc                     
                tya                     
                adc   #5                
                adc   N                 
                sta   2,x               
                ldy   #0                
                tya                     
                adc   N+1               
                sta   3,x               
                sty   1,x               
                lda   (N),y             
                sta   0,x               
                lda   #1                
                pha                     
                jmp   PUSH              
L280            bcs   L284              
L281            iny                     
                lda   (N),y             
                bpl   L281              
L284            iny                     
                lda   (N),y             
                tax                     
                iny                     
                lda   (N),y             
                sta   N+1               
                stx   N                 
                ora   N                 
                bne   L249              
                ldx   XSAVE             
                lda   #0                
                pha                     
                jmp   PUSH              ;exit false upon reading null link
;
;                                       ENCLOSE
;                                       SCREEN 20 LINE 1
;
L301            .byte    $87,"ENCLOS",$C5  
                .word    L243              ;link to (FIND)
ENCL            .word    *+2               
                lda   #2                
                jsr   SETUP             
                txa                     
                sec                     
                sbc   #8                
                tax                     
                sty   3,x               
                sty   1,x               
                dey                     
L313            iny                     
                lda   (N+2),y           
                cmp   N                 
                beq   L313              
                sty   4,x               
L318            lda   (N+2),y           
                bne   L327              
                sty   2,x               
                sty   0,x               
                tya                     
                cmp   4,x               
                bne   L326              
                inc   2,x               
L326            jmp   NEXT              
L327            sty   2,x               
                iny                     
                cmp   N                 
                bne   L318              
                sty   0,x               
                jmp   NEXT              
;
;                                       EMIT
;                                       SCREEN 21 LINE 5
;
L337            .byte    $84,"EMI",$D4     
                .word    L301              ;link to ENCLOSE
EMIT            .word    XEMIT             ;Vector to code for KEY
;
;                                       KEY
;                                       SCREEN 21 LINE 7
;
L344            .byte    $83,"KE",$D9      
                .word    L337              ;link to EMIT
KEY             .word    XKEY              ;Vector to code for KEY
;
;                                       ?TERMINAL
;                                       SCREEN 21 LINE 9
;
L351            .byte    $89,"?TERMINA",$CC
                .word    L344              ;link to KEY
QTERM           .word    XQTER             ;Vector to code for ?TERMINAL
;
;
;
;
;
;                                       CR
;                                       SCREEN 21 LINE 11
;
L358            .byte    $82,"C",$D2       
                .word    L351              ;link to ?TERMINAL
CR              .word    XCR               ;Vector to code for CR
;
;                                       CMOVE
;                                       SCREEN 22 LINE 1
;
L365            .byte    $85,"CMOV",$C5    
                .word    L358              ;link to CR
CMOVE           .word    *+2               
                lda   #3                
                jsr   SETUP             
L370            cpy   N                 
                bne   L375              
                dec   N+1               
                bpl   L375              
                jmp   NEXT              
L375            lda   (N+4),y           
                sta   (N+2),y           
                iny                     
                bne   L370              
                inc   N+5               
                inc   N+3               
                jmp   L370              
;
;                                       U*
;                                       SCREEN 23 LINE 1
;
L386            .byte    $82,"U",$AA       
                .word    L365              ;link to CMOVE
USTAR           .word    *+2               
;          LDA 2,X
;          STA N
;          STY 2,X
;          LDA 3,X
;          STA N+1
;          STY 3,X
;          LDY #16        ; for 16 bits
;L396      ASL 2,X
;          ROL 3,X
;          ROL 0,X
;          ROL 1,X
;          BCC L411
;          CLC
;          LDA N
;          ADC 2,X
;          STA 2,X
;          LDA N+1
;          ADC 3,X
;          STA 3,X
;          LDA #0        ; bug here as high byte of this high word does not
;          ADC 0,X       ; get incremented when 0,x rolls over to $00
;          STA 0,X
;
;L411      DEY
;          BNE L396
;          JMP NEXT

;
; replacement code from 6502.org - http://forum.6502.org/viewtopic.php?t=689
;
                lda   #0                ;in some implementations TYA can be used since NEXT leaves Y=$00
                sta   N                 
                ldy   #16               
                lsr   3,x               
                ror   2,x               
L1              bcc   L2                
                clc                     
                sta   N+1               ;PHA
                lda   N                 
                adc   0,x               
                sta   N                 
                lda   N+1               ;PLA
                adc   1,x               
L2              ror   a                 
                ror   N                 
                ror   3,x               
                ror   2,x               
                dey                     
                bne   L1                
                sta   1,x               
                lda   N                 
                sta   0,x               
                jmp   NEXT              

;
;                                       U/
;                                       SCREEN 24 LINE 1
;
L418            .byte    $82,"U",$AF       
                .word    L386              ;link to U*
USLAS           .word    *+2               
;          LDA 4,X   ; bugged code replaced - dr
;          LDY 2,X
;          STY 4,X
;          ASL 
;          STA 2,X
;          LDA 5,X
;          LDY 3,X
;          STY 5,X
;          ROL
;          STA 3,X
;          LDA #16
;          STA N
;L433      ROL 4,X
;          ROL 5,X
;          SEC
;          LDA 4,X
;          SBC 0,X
;          TAY
;          LDA 5,X
;          SBC 1,X
;          BCC L444
;          STY 4,X
;          STA 5,X
;L444      ROL 2,X
;          ROL 3,X
;          DEC N
;          BNE L433
;          JMP POP

;
; updated code from 6502.org  - source code repository 32bit division
;
                sec                     ;Modified code - dr
                lda   2,x               ;Subtract hi cell of dividend by
                sbc   0,x               ;divisor to see if there's an overflow condition.
                lda   3,x               
                sbc   1,x               
                bcs   oflow             ;Branch if /0 or overflow.
                lda   #$11              ;Loop 17x.
                sta   N                 ;Use N for loop counter.
loopp           rol   4,x               ;Rotate dividend lo cell left one bit.
                rol   5,x               
                dec   N                 ;Decrement loop counter.
                beq   endd              ;If we're done, then branch to end.
                rol   2,x               ;Otherwise rotate dividend hi cell left one bit.
                rol   3,x               
;                stz   N+1 
 pha 
 lda #0
 sta N+1
 pla
                rol   N+1               ;Rotate the bit carried out of above into N+1.
                sec                     
                lda   2,x               ;Subtract dividend hi cell minus divisor.
                sbc   0,x               
                sta   N+2               ;Put result temporarily in N+2 (lo byte)
                lda   3,x               
                sbc   1,x               
                tay                     ;and Y (hi byte).
                lda   N+1               ;Remember now to bring in the bit carried out above.
                sbc   #$00              
                bcc   loopp             
                lda   N+2               ;If that didn't cause a borrow,
                sta   2,x               ;make the result from above to
                sty   3,x               ;be the new dividend hi cell
                bra   loopp             ;and then brach up.  (NMOS 6502 can use BCS here.)
oflow           lda   #$FF              ;If overflow or /0 condition found,
                sta   2,x               ;just put FFFF in both the remainder
                sta   3,x               
                sta   4,x               ;and the quotient.
                sta   5,x               
endd            inx                     ;When you're done, show one less cell on data stack,
                inx                     ;(INX INX is exactly what the Forth word DROP does)
                jmp   SWAP+2            ;and swap the two top cells to put quotient on top.

;
;                                       AND
;                                       SCREEN 25 LINE 2
;
L453            .byte    $83,"AN",$C4      
                .word    L418              ;link to U/
ANDD            .word    *+2               
                lda   0,x               
                and   2,x               
                pha                     
                lda   1,x               
                and   3,x               
;
BINARY          inx                     
                inx                     
                jmp   PUT               
;
;                                       OR
;                                       SCREEN 25 LINE 7
;
L469            .byte    $82,"O",$D2       
                .word    L453              ;link to AND
OR              .word    *+2               
                lda   0,x               
                ora   2,x               
                pha                     
                lda   1,x               
                ora   3,x               
                inx                     
                inx                     
                jmp   PUT               
;
;                                       XOR
;                                       SCREEN 25 LINE 11
;
L484            .byte    $83,"XO",$D2      
                .word    L469              ;link to OR
XOR             .word    *+2               
                lda   0,x               
                eor   2,x               
                pha                     
                lda   1,x               
                eor   3,x               
                inx                     
                inx                     
                jmp   PUT               
;
;                                       SP@
;                                       SCREEN 26 LINE 1
;
L499            .byte    $83,"SP",$C0      
                .word    L484              ;link  to XOR
SPAT            .word    *+2               
                txa                     
;
PUSHOA          pha                     
                lda   #0                
                jmp   PUSH              
;
;                                       SP!
;                                       SCREEN 26 LINE 5
;
;
L511            .byte    $83,"SP",$A1      
                .word    L499              ;link to SP@
SPSTO           .word    *+2               
                ldy   #6                
                lda   (UP),y            ;load data stack pointer (X reg) from
                tax                     ;silent user variable S0.
                jmp   NEXT              
;
;                                       RP!
;                                       SCREEN 26 LINE 8
;
L522            .byte    $83,"RP",$A1      
                .word    L511              ;link to SP!
RPSTO           .word    *+2               
                stx   XSAVE             ;load return stack pointer (machine
                ldy   #8                ;stack pointer) from silent user
                lda   (UP),y            ;VARIABLE R0
                tax                     
                txs                     
                ldx   XSAVE             
                jmp   NEXT              
;
;                                       ;S
;                                       SCREEN 26 LINE 12
;
L536            .byte    $82,"             ;",$D3
                .word    L522              ;link to RP!
SEMIS           .word    *+2               
                pla                     
                sta   IP                
                pla                     
                sta   IP+1              
                jmp   NEXT              
;
;                                       LEAVE
;                                       SCREEN 27 LINE  1
;
L548            .byte    $85,"LEAV",$C5    
                .word    L536              ;link to ;S
LEAVE           .word    *+2               
                stx   XSAVE             
                tsx                     
                lda   $101,x            
                sta   $103,x            
                lda   $102,x            
                sta   $104,x            
                ldx   XSAVE             
                jmp   NEXT              
;
;                                       >R
;                                       SCREEN 27 LINE 5
;
L563            .byte    $82,">",$D2       
                .word    L548              ;link to LEAVE
TOR             .word    *+2               
                lda   1,x               ;move high byte
                pha                     
                lda   0,x               ;then low byte
                pha                     ;to return stack
                inx                     
                inx                     ;popping off data stack
                jmp   NEXT              
;
;                                       R>
;                                       SCREEN 27 LINE 8
;
L577            .byte    $82,"R",$BE       
                .word    L563              ;link to >R
RFROM           .word    *+2               
                dex                     ;make room on data stack
                dex                     
                pla                     ;high byte
                sta   0,x               
                pla                     ;then low byte
                sta   1,x               ;restored to data stack
                jmp   NEXT              
;
;                                       R
;                                       SCREEN 27 LINE 11
;
L591            .byte    $81,$D2           
                .word    L577              ;link to R>
R               .word    *+2               
                stx   XSAVE             
                tsx                     ;address return stack
                lda   $101,x            ;copy bottom value
                pha                     ;to data stack
                lda   $102,x            
                ldx   XSAVE             
                jmp   PUSH              
;
;                                       0=
;                                       SCREEN 28 LINE 2
;
L605            .byte    $82,"0",$BD       
                .word    L591              ;link to R
ZEQU            .word    *+2               
                lda   1,x               ;Corrected from FD3/2 p69
                sty   1,x               
                ora   0,x               
                bne   L613              
                iny                     
L613            sty   0,x               
                jmp   NEXT              
;
;                                       0<
;                                       SCREEN 28 LINE 6
;
L619            .byte    $82,"0",$BC       
                .word    L605              ;link to 0=
ZLESS           .word    *+2               
                asl   1,x               
                tya                     
                rol   a                 
                sty   1,x               
                sta   0,x               
                jmp   NEXT              
;
;                                       +
;                                       SCREEN 29 LINE 1
;
L632            .byte    $81,$AB           
                .word    L619              ;link to V-ADJ
PLUS            .word    *+2               
                clc                     
                lda   0,x               
                adc   2,x               
                sta   2,x               
                lda   1,x               
                adc   3,x               
                sta   3,x               
                inx                     
                inx                     
                jmp   NEXT              
;
;                                       D+
;                                       SCREEN 29 LINE 4
;
L649            .byte    $82,"D",$AB       
                .word    L632              ;LINK TO +
DPLUS           .word    *+2               
                clc                     
                lda   2,x               
                adc   6,x               
                sta   6,x               
                lda   3,x               
                adc   7,x               
                sta   7,x               
                lda   0,x               
                adc   4,x               
                sta   4,x               
                lda   1,x               
                adc   5,x               
                sta   5,x               
                jmp   POPTWO            
;
;                                       MINUS
;                                       SCREEN 29 LINE 9
;
L670            .byte    $85,"MINU",$D3    
                .word    L649              ;link to D+
MINUS           .word    *+2               
                sec                     
                tya                     
                sbc   0,x               
                sta   0,x               
                tya                     
                sbc   1,x               
                sta   1,x               
                jmp   NEXT              
;
;                                       DMINUS
;                                       SCREEN 29 LINE 12
;
L685            .byte    $86,"DMINU",$D3   
                .word    L670              ;link to  MINUS
DMINU           .word    *+2               
                sec                     
                tya                     
                sbc   2,x               
                sta   2,x               
                tya                     
                sbc   3,x               
                sta   3,x               
                jmp   MINUS+3           
;
;                                       OVER
;                                       SCREEN 30 LINE 1
;
L700            .byte    $84,"OVE",$D2     
                .word    L685              ;link to DMINUS
OVER            .word    *+2               
                lda   2,x               
                pha                     
                lda   3,x               
                jmp   PUSH              
;
;                                       DROP
;                                       SCREEN 30 LINE 4
;
L711            .byte    $84,"DRO",$D0     
                .word    L700              ;link to OVER
DROP            .word    POP               
;
;                                       SWAP
;                                       SCREEN 30 LINE 8
;
L718            .byte    $84,"SWA",$D0     
                .word    L711              ;link to DROP
SWAP            .word    *+2               
                lda   2,x               
                pha                     
                lda   0,x               
                sta   2,x               
                lda   3,x               
                ldy   1,x               
                sty   3,x               
                jmp   PUT               
;
;                                       DUP
;                                       SCREEN 30 LINE 21
;
L733            .byte    $83,"DU",$D0      
                .word    L718              ;link to SWAP
DUP             .word    *+2               
                lda   0,x               
                pha                     
                lda   1,x               
                jmp   PUSH              
;
;                                       +!
;                                       SCREEN 31 LINE 2
;
L744            .byte    $82,"+",$A1       
                .word    L733              ;link to DUP
PSTOR           .word    *+2               
                clc                     
                lda   (0,x)             ;fetch 16 bit value addressed by
                adc   2,x               ;bottom of  stack, adding to
                sta   (0,x)             ;second item on stack, and return
                inc   0,x               ;to memory
                bne   L754              
                inc   1,x               
L754            lda   (0,x)             
                adc   3,x               
                sta   (0,x)             
                jmp   POPTWO            
;
;                                       TOGGLE
;                                       SCREEN 31 LINE 7
;
L762            .byte    $81,"TOGGL",$C5   
                .word    L744              ;link to +!
TOGGL           .word    *+2               
                lda   (2,x)             ;complement bits in memory address
                eor   0,x               ;second on stack, by pattern on
                sta   (2,x)             ;bottom of stack.
                jmp   POPTWO            
;
;                                       @
;                                       SCREEN 32 LINE 1
;
L773            .byte    $81,$C0           
                .word    L762              ;link to TOGGLE
AT              .word    *+2               
                lda   (0,x)             
                pha                     
                inc   0,x               
                bne   L781              
                inc   1,x               
L781            lda   (0,x)             
                jmp   PUT               
;
;                                       C@
;                                       SCREEN 32 LINE 5
;
L787            .byte    $82,"C",$C0       
                .word    L773              ;link to @
CAT             .word    *+2               
                lda   (0,x)             ;fetch byte addressed by bottom of
                sta   0,x               ;stack to stack, zeroing the high
                sty   1,x               ;byte
                jmp   NEXT              
;
;                                       !
;                                       SCREEN 32 LINE 8
;
L798            .byte    $81,$A1           
                .word    L787              ;link to C@
STORE           .word    *+2               
                lda   2,x               
                sta   (0,x)             ;store second 16bit value on stack
                inc   0,x               ;to memory as addressed by bottom
                bne   L806              ;of stack.
                inc   1,x               
L806            lda   3,x               
                sta   (0,x)             
                jmp   POPTWO            
;
;                                       C!
;                                       SCREEN 32 LINE 12
;
L813            .byte    $82,"C",$A1       
                .word    L798              ;link to !
CSTOR           .word    *+2               
                lda   2,x               
                sta   (0,x)             
                jmp   POPTWO            
;
;                                       :
;                                       SCREEN 33 LINE 2
;
L823            .byte    $C1,$BA           
                .word    L813              ;link to C!
COLON           .word    DOCOL             
                .word    QEXEC             
                .word    SCSP              
                .word    CURR              
                .word    AT                
                .word    CON               
                .word    STORE             
                .word    CREAT             
                .word    RBRAC             
                .word    PSCOD             
;
DOCOL           lda   IP+1              
                pha                     
                lda   IP                
                pha                     
                clc                     
                lda   W                 
                adc   #2                
                sta   IP                
                tya                     
                adc   W+1               
                sta   IP+1              
                jmp   NEXT              
;
;                                       ;
;                                       SCREEN 33 LINE 9
;
L853            .byte    $C1,$BB           
                .word    L823              ;link to :
                .word    DOCOL             
                .word    QCSP              
                .word    COMP              
                .word    SEMIS             
                .word    SMUDG             
                .word    LBRAC             
                .word    SEMIS             
;
;                                       CONSTANT
;                                       SCREEN 34 LINE 1
;
L867            .byte    $88,"CONSTAN",$D4 
                .word    L853              ;link to ;
CONST           .word    DOCOL             
                .word    CREAT             
                .word    SMUDG             
                .word    COMMA             
                .word    PSCOD             
;
DOCON           ldy   #2                
                lda   (W),y             
                pha                     
                iny                     
                lda   (W),y             
                jmp   PUSH              
;
;                                       VARIABLE
;                                       SCREEN 34 LINE 5
;
L885            .byte    $88,"VARIABL",$C5 
                .word    L867              ;link to CONSTANT
VAR             .word    DOCOL             
                .word    CONST             
                .word    PSCOD             
;
DOVAR           clc                     
                lda   W                 
                adc   #2                
                pha                     
                tya                     
                adc   W+1               
                jmp   PUSH              
;
;                                       USER
;                                       SCREEN 34 LINE 10
;
L902            .byte    $84,"USE",$D2     
                .word    L885              ;link to VARIABLE
USER            .word    DOCOL             
                .word    CONST             
                .word    PSCOD             
;
DOUSE           ldy   #2                
                clc                     
                lda   (W),y             
                adc   UP                
                pha                     
                lda   #0                
                adc   UP+1              
                jmp   PUSH              
;
;                                       0
;                                       SCREEN 35 LINE 2
;
L920            .byte    $81,$B0           
                .word    L902              ;link to USER
ZERO            .word    DOCON             
                .word    0                 
;
;                                       1
;                                       SCREEN 35 LINE 2
;
L928            .byte    $81,$B1           
                .word    L920              ;link to 0
ONE             .word    DOCON             
                .word    1                 
;
;                                       2
;                                       SCREEN 35 LINE 3
;
L936            .byte    $81,$B2           
                .word    L928              ;link to 1
TWO             .word    DOCON             
                .word    2                 
;
;                                       3
;                                       SCREEN 35 LINE 3
;
L944            .byte    $81,$B3           
                .word    L936              ;link to 2
THREE           .word    DOCON             
                .word    3                 
;
;                                       BL
;                                       SCREEN 35 LINE 4
;
L952            .byte    $82,"B",$CC       
                .word    L944              ;link to 3
BL              .word    DOCON             
                .word    $20               
;
;                                       C/L
;                                       SCREEN 35 LINE 5
;                                       Characters per line
L960            .byte    $83,"C/",$CC      
                .word    L952              ;link to BL
CSLL            .word    DOCON             
                .word    64                
;
;                                       FIRST
;                                       SCREEN 35 LINE 7
;
L968            .byte    $85,"FIRS",$D4    
                .word    L960              ;link to C/L
FIRST           .word    DOCON             
                .word    DAREA             ;bottom of disk buffer area
;
;                                       LIMIT
;                                       SCREEN 35 LINE 8
;
L976            .byte    $85,"LIMI",$D4    
                .word    L968              ;link to FIRST
LIMIT           .word    DOCON             
                .word    UAREA             ;buffers end at user area
;
;                                       B/BUF
;                                       SCREEN 35 LINE 9
;                                       Bytes per Buffer
;
L984            .byte    $85,"B/BU",$C6    
                .word    L976              ;link to LIMIT
BBUF            .word    DOCON             
                .word    SSIZE             ;sector size
;
;                                       B/SCR
;                                       SCREEN 35 LINE 10
;                                       Blocks per screen
;
L992            .byte    $85,"B/SC",$D2    
                .word    L984              ;link to B/BUF
BSCR            .word    DOCON             
                .word    8                 ;blocks to make one screen





;
;                                       +ORIGIN
;                                       SCREEN 35 LINE 12
;
L1000           .byte    $87,"+ORIGI",$CE  
                .word    L992              ;link to B/SCR
PORIG           .word    DOCOL             
                .word    LIT,ORIG          
                .word    PLUS              
                .word    SEMIS             
;
;                                       TIB
;                                       SCREEN 36 LINE 4
;
L1010           .byte    $83,"TI",$C2      
                .word    L1000             ;link to +ORIGIN
TIB             .word    DOUSE             
                .byte    $A                
;
;                                       WIDTH
;                                       SCREEN 36 LINE 5
;
L1018           .byte    $85,"WIDT",$C8    
                .word    L1010             ;link to TIB
WIDTH           .word    DOUSE             
                .byte    $C                
;
;                                       WARNING
;                                       SCREEN 36 LINE 6
;
L1026           .byte    $87,"WARNIN",$C7  
                .word    L1018             ;link to WIDTH
WARN            .word    DOUSE             
                .byte    $E                
;
;                                       FENCE
;                                       SCREEN 36 LINE 7
;
L1034           .byte    $85,"FENC",$C5    
                .word    L1026             ;link to WARNING
FENCE           .word    DOUSE             
                .byte    $10               
;
;
;                                       DP
;                                       SCREEN 36 LINE 8
;
L1042           .byte    $82,"D",$D0       
                .word    L1034             ;link to FENCE
DP              .word    DOUSE             
                .byte    $12               
;
;                                       VOC-LINK
;                                       SCREEN 36 LINE 9
;
L1050           .byte    $88,"VOC-LIN",$CB 
                .word    L1042             ;link to DP
VOCL            .word    DOUSE             
                .byte    $14               
;
;                                       BLK
;                                       SCREEN 36 LINE 10
;
L1058           .byte    $83,"BL",$CB      
                .word    L1050             ;link to VOC-LINK
BLK             .word    DOUSE             
                .byte    $16               
;
;                                       IN
;                                       SCREEN 36 LINE 11
;
L1066           .byte    $82,"I",$CE       
                .word    L1058             ;link to BLK
IN              .word    DOUSE             
                .byte    $18               
;
;                                       OUT
;                                       SCREEN 36 LINE 12
;
L1074           .byte    $83,"OU",$D4      
                .word    L1066             ;link to IN
OUT             .word    DOUSE             
                .byte    $1A               
;
;                                       SCR
;                                       SCREEN 36 LINE 13
;
L1082           .byte    $83,"SC",$D2      
                .word    L1074             ;link to OUT
SCR             .word    DOUSE             
                .byte    $1C               
;
;                                       OFFSET
;                                       SCREEN 37 LINE 1
;
L1090           .byte    $86,"OFFSE",$D4   
                .word    L1082             ;link to SCR
OFSET           .word    DOUSE             
                .byte    $1E               
;
;                                       CONTEXT
;                                       SCREEN 37 LINE 2
;
L1098           .byte    $87,"CONTEX",$D4  
                .word    L1090             ;link to OFFSET
CON             .word    DOUSE             
                .byte    $20               
;
;                                       CURRENT
;                                       SCREEN 37 LINE 3
;
L1106           .byte    $87,"CURREN",$D4  
                .word    L1098             ;link to CONTEXT
CURR            .word    DOUSE             
                .byte    $22               
;
;                                       STATE
;                                       SCREEN 37 LINE 4
;
L1114           .byte    $85,"STAT",$C5    
                .word    L1106             ;link to CURRENT
STATE           .word    DOUSE             
                .byte    $24               
;
;                                       BASE
;                                       SCREEN 37 LINE 5
;
L1122           .byte    $84,"BAS",$C5     
                .word    L1114             ;link to STATE
BASE            .word    DOUSE             
                .byte    $26               
;
;                                       DPL
;                                       SCREEN 37 LINE 6
;
L1130           .byte    $83,"DP",$CC      
                .word    L1122             ;link to BASE
DPL             .word    DOUSE             
                .byte    $28               
;
;                                       FLD
;                                       SCREEN 37 LINE 7
;
L1138           .byte    $83,"FL",$C4      
                .word    L1130             ;link to DPL
FLD             .word    DOUSE             
                .byte    $2A               
;
;
;
;                                       CSP
;                                       SCREEN 37 LINE 8
;
L1146           .byte    $83,"CS",$D0      
                .word    L1138             ;link to FLD
CSP             .word    DOUSE             
                .byte    $2C               
;
;                                       R#
;                                       SCREEN 37  LINE 9
;
L1154           .byte    $82,"R",$A3       
                .word    L1146             ;link to CSP
RNUM            .word    DOUSE             
                .byte    $2E               
;
;                                       HLD
;                                       SCREEN 37 LINE 10
;
L1162           .byte    $83,"HL",$C4      
                .word    L1154             ;link to R#
HLD             .word    DOUSE             
                .byte    $30               
;
;                                       1+
;                                       SCREEN 38 LINE  1
;
L1170           .byte    $82,"1",$AB       
                .word    L1162             ;link to HLD
ONEP            .word    DOCOL             
                .word    ONE               
                .word    PLUS              
                .word    SEMIS             
;
;                                       2+
;                                       SCREEN 38 LINE 2
;
L1180           .byte    $82,"2",$AB       
                .word    L1170             ;link to 1+
TWOP            .word    DOCOL             
                .word    TWO               
                .word    PLUS              
                .word    SEMIS             
;
;                                       HERE
;                                       SCREEN 38 LINE 3
;
L1190           .byte    $84,"HER",$C5     
                .word    L1180             ;link to 2+
HERE            .word    DOCOL             
                .word    DP                
                .word    AT                
                .word    SEMIS             
;
;                                       ALLOT
;                                       SCREEN 38 LINE 4
;
L1200           .byte    $85,"ALLO",$D4    
                .word    L1190             ;link to HERE
ALLOT           .word    DOCOL             
                .word    DP                
                .word    PSTOR             
                .word    SEMIS             
;
;                                       ,
;                                       SCREEN 38 LINE 5
;
L1210           .byte    $81,$AC           
                .word    L1200             ;link to ALLOT
COMMA           .word    DOCOL             
                .word    HERE              
                .word    STORE             
                .word    TWO               
                .word    ALLOT             
                .word    SEMIS             
;
;                                       C,
;                                       SCREEN 38 LINE 6
;
L1222           .byte    $82,"C",$AC       
                .word    L1210             ;link to ,
CCOMM           .word    DOCOL             
                .word    HERE              
                .word    CSTOR             
                .word    ONE               
                .word    ALLOT             
                .word    SEMIS             
;
;                                       -
;                                       SCREEN 38 LINE 7
;
L1234           .byte    $81,$AD           
                .word    L1222             ;link to C,
SUB             .word    DOCOL             
                .word    MINUS             
                .word    PLUS              
                .word    SEMIS             
;
;                                       =
;                                       SCREEN 38 LINE 8
;
L1244           .byte    $81,$BD           
                .word    L1234             ;link to -
EQUAL           .word    DOCOL             
                .word    SUB               
                .word    ZEQU              
                .word    SEMIS             
;
;                                       U<
;                                       Unsigned less than
;
L1246           .byte    $82,"U",$BC       
                .word    L1244             ;link to =
ULESS           .word    DOCOL             
                .word    SUB               ;subtract two values
                .word    ZLESS             ;test sign
                .word    SEMIS             
;
;                                       <
;                                       Altered from model
;                                       SCREEN 38 LINE 9
;
L1254           .byte    $81,$BC           
                .word    L1246             ;link to U<
LESS            .word    *+2               
                sec                     
                lda   2,x               
                sbc   0,x               ;subtract
                lda   3,x               
                sbc   1,x               
                sty   3,x               ;zero high byte
                bvc   L1258             
                eor   #$80              ;correct overflow
L1258           bpl   L1260             
                iny                     ;invert boolean
L1260           sty   2,x               ;leave boolean
                jmp   POP               
;
;                                       >
;                                       SCREEN 38 LINE 10
L1264           .byte    $81,$BE           
                .word    L1254             ;link to <
GREAT           .word    DOCOL             
                .word    SWAP              
                .word    LESS              
                .word    SEMIS             
;
;                                       ROT
;                                       SCREEN 38 LINE 11
;
L1274           .byte    $83,"RO",$D4      
                .word    L1264             ;link to >
ROT             .word    DOCOL             
                .word    TOR               
                .word    SWAP              
                .word    RFROM             
                .word    SWAP              
                .word    SEMIS             
;
;                                       SPACE
;                                       SCREEN 38 LINE 12
;
L1286           .byte    $85,"SPAC",$C5    
                .word    L1274             ;link to ROT
SPACE           .word    DOCOL             
                .word    BL                
                .word    EMIT              
                .word    SEMIS             
;
;                                       -DUP
;                                       SCREEN 38 LINE 13
;
L1296           .byte    $84,"-DU",$D0     
                .word    L1286             ;link to SPACE
DDUP            .word    DOCOL             
                .word    DUP               
                .word    ZBRAN             
L1301           .word    $4                ;L1303-L1301
                .word    DUP               
L1303           .word    SEMIS             
;
;                                       TRAVERSE
;                                       SCREEN 39 LINE 14
;
L1308           .byte    $88,"TRAVERS",$C5 
                .word    L1296             ;link to -DUP
TRAV            .word    DOCOL             
                .word    SWAP              
L1312           .word    OVER              
                .word    PLUS              
                .word    CLIT              
                .byte    $7F               
                .word    OVER              
                .word    CAT               
                .word    LESS              
                .word    ZBRAN             
L1320           .word    $FFF1             ;L1312-L1320
                .word    SWAP              
                .word    DROP              
                .word    SEMIS             
;
;                                       LATEST
;                                       SCREEN 39 LINE 6
;
L1328           .byte    $86,"LATES",$D4   
                .word    L1308             ;link to TRAVERSE
LATES           .word    DOCOL             
                .word    CURR              
                .word    AT                
                .word    AT                
                .word    SEMIS             
;
;
;                                       LFA
;                                       SCREEN 39 LINE 11
;
L1339           .byte    $83,"LF",$C1      
                .word    L1328             ;link to LATEST
LFA             .word    DOCOL             
                .word    CLIT              
                .byte    4                 
                .word    SUB               
                .word    SEMIS             
;
;                                       CFA
;                                       SCREEN 39 LINE 12
;
L1350           .byte    $83,"CF",$C1      
                .word    L1339             ;link to LFA
CFA             .word    DOCOL             
                .word    TWO               
                .word    SUB               
                .word    SEMIS             
;
;                                       NFA
;                                       SCREEN 39 LIINE 13
;
L1360           .byte    $83,"NF",$C1      
                .word    L1350             ;link to CFA
NFA             .word    DOCOL             
                .word    CLIT              
                .byte    $5                
                .word    SUB               
                .word    LIT,$FFFF         
                .word    TRAV              
                .word    SEMIS             
;
;                                       PFA
;                                       SCREEN 39 LINE 14
;
L1373           .byte    $83,"PF",$C1      
                .word    L1360             ;link to NFA
PFA             .word    DOCOL             
                .word    ONE               
                .word    TRAV              
                .word    CLIT              
                .byte    5                 
                .word    PLUS              
                .word    SEMIS             
;
;                                       !CSP
;                                       SCREEN 40 LINE 1
;
L1386           .byte    $84,"!CS",$D0     
                .word    L1373             ;link to PFA
SCSP            .word    DOCOL             
                .word    SPAT              
                .word    CSP               
                .word    STORE             
                .word    SEMIS             
;
;                                       ?ERROR
;                                       SCREEN 40 LINE 3
;
L1397           .byte    $86,"?ERRO",$D2   
                .word    L1386             ;link to !CSP
QERR            .word    DOCOL             
                .word    SWAP              
                .word    ZBRAN             
L1402           .word    8                 ;L1406-L1402
                .word    ERROR             
                .word    BRAN              
L1405           .word    4                 ;L1407-L1405
L1406           .word    DROP              
L1407           .word    SEMIS             
;
;                                       ?COMP
;                                       SCREEN 40 LINE 6
;
L1412           .byte    $85,"?COM",$D0    
                .word    L1397             ;link to ?ERROR
QCOMP           .word    DOCOL             
                .word    STATE             
                .word    AT                
                .word    ZEQU              
                .word    CLIT              
                .byte    $11               
                .word    QERR              
                .word    SEMIS             
;
;                                       ?EXEC
;                                       SCREEN 40 LINE 8
;
L1426           .byte    $85,"?EXE",$C3    
                .word    L1412             ;link to ?COMP
QEXEC           .word    DOCOL             
                .word    STATE             
                .word    AT                
                .word    CLIT              
                .byte    $12               
                .word    QERR              
                .word    SEMIS             
;
;                                       ?PAIRS
;                                       SCREEN 40 LINE 10
;
L1439           .byte    $86,"?PAIR",$D3   
                .word    L1426             ;link to ?EXEC
QPAIR           .word    DOCOL             
                .word    SUB               
                .word    CLIT              
                .byte    $13               
                .word    QERR              
                .word    SEMIS             
;
;                                       ?CSP
;                                       SCREEN 40 LINE 12
;
L1451           .byte    $84,"?CS",$D0     
                .word    L1439             ;link to ?PAIRS
QCSP            .word    DOCOL             
                .word    SPAT              
                .word    CSP               
                .word    AT                
                .word    SUB               
                .word    CLIT              
                .byte    $14               
                .word    QERR              
                .word    SEMIS             
;
;                                       ?LOADING
;                                       SCREEN 40 LINE 14
;
L1466           .byte    $88,"?LOADIN",$C7 
                .word    L1451             ;link to ?CSP
QLOAD           .word    DOCOL             
                .word    BLK               
                .word    AT                
                .word    ZEQU              
                .word    CLIT              
                .byte    $16               
                .word    QERR              
                .word    SEMIS             
;
;                                       COMPILE
;                                       SCREEN 41 LINE 2
;
L1480           .byte    $87,"COMPIL",$C5  
                .word    L1466             ;link to ?LOADING
COMP            .word    DOCOL             
                .word    QCOMP             
                .word    RFROM             
                .word    DUP               
                .word    TWOP              
                .word    TOR               
                .word    AT                
                .word    COMMA             
                .word    SEMIS             
;
;                                       [
;                                       SCREEN 41 LINE 5
;
L1495           .byte    $C1,$DB           
                .word    L1480             ;link to COMPILE
LBRAC           .word    DOCOL             
                .word    ZERO              
                .word    STATE             
                .word    STORE             
                .word    SEMIS             
;
;                                       ]
;                                       SCREEN 41 LINE 7
;
L1507           .byte    $81,$DD           
                .word    L1495             ;link to [
RBRAC           .word    DOCOL             
                .word    CLIT              
                .byte    $C0               
                .word    STATE             
                .word    STORE             
                .word    SEMIS             
;
;                                       SMUDGE
;                                       SCREEN 41 LINE 9
;
L1519           .byte    $86,"SMUDG",$C5   
                .word    L1507             ;link to ]
SMUDG           .word    DOCOL             
                .word    LATES             
                .word    CLIT              
                .byte    $20               
                .word    TOGGL             
                .word    SEMIS             
;
;                                       HEX
;                                       SCREEN 41 LINE 11
;
L1531           .byte    $83,"HE",$D8      
                .word    L1519             ;link to SMUDGE
HEX             .word    DOCOL             
                .word    CLIT              
                .byte    16                
                .word    BASE              
                .word    STORE             
                .word    SEMIS             
;
;                                       DECIMAL
;                                       SCREEN 41 LINE 13
;
L1543           .byte    $87,"DECIMA",$CC  
                .word    L1531             ;link to HEX
DECIM 
                .word    DOCOL             
                .word    CLIT              
                .byte    10                
                .word    BASE              
                .word    STORE             
                .word    SEMIS    
;
;
;
;                                       (;CODE)
;                                       SCREEN 42 LINE 2
;
L1555           .byte    $87,"(            ;CODE",$A9
                .word    L1543             ;link to DECIMAL
PSCOD           .word    DOCOL             
                .word    RFROM             
                .word    LATES             
                .word    PFA               
                .word    CFA               
                .word    STORE             
                .word    SEMIS             
;
;                                       ;CODE
;                                       SCREEN 42 LINE 6
;
L1568           .byte    $C5,"             ;COD",$C5
                .word    L1555             ;link to (;CODE)
                .word    DOCOL             
                .word    QCSP              
                .word    COMP              
                .word    PSCOD             
                .word    LBRAC             
                .word    SMUDG             
                .word    SEMIS             
;
;                                       <BUILDS
;                                       SCREEN 43 LINE 2
;
L1582           .byte    $87,"<BUILD",$D3  
                .word    L1568             ;link to ;CODE
BUILD           .word    DOCOL             
                .word    ZERO              
                .word    CONST             
                .word    SEMIS             
;
;                                       DOES>
;                                       SCREEN 43 LINE 4
;
L1592           .byte    $85,"DOES",$BE    
                .word    L1582             ;link to <BUILDS
DOES            .word    DOCOL             
                .word    RFROM             
                .word    LATES             
                .word    PFA               
                .word    STORE             
                .word    PSCOD             
;
DODOE           lda   IP+1              
                pha                     
                lda   IP                
                pha                     
                ldy   #2                
                lda   (W),y             
                sta   IP                
                iny                     
                lda   (W),y             
                sta   IP+1              
                clc                     
                lda   W                 
                adc   #4                
                pha                     
                lda   W+1               
                adc   #0                
                jmp   PUSH              
;
;                                       COUNT
;                                       SCREEN 44 LINE 1
;
L1622           .byte    $85,"COUN",$D4    
                .word    L1592             ;link to DOES>
COUNT           .word    DOCOL             
                .word    DUP               
                .word    ONEP              
                .word    SWAP              
                .word    CAT               
                .word    SEMIS             
;
;                                       TYPE
;                                       SCREEN 44 LINE 2
;
L1634           .byte    $84,"TYP",$C5     
                .word    L1622             ;link to COUNT
TYPE            .word    DOCOL             
                .word    DDUP              
                .word    ZBRAN             
L1639           .word    $18               ;L1651-L1639
                .word    OVER              
                .word    PLUS              
                .word    SWAP              
                .word    PDO               
L1644           .word    I                 
                .word    CAT               
                .word    EMIT              
                .word    PLOOP             
L1648           .word    $FFF8             ;L1644-L1648
                .word    BRAN              
L1650           .word    $4                ;L1652-L1650
L1651           .word    DROP              
L1652           .word    SEMIS             
;
;                                       -TRAILING
;                                       SCREEN 44 LINE 5
;
L1657           .byte    $89,"-TRAILIN",$C7
                .word    L1634             ;link to TYPE
DTRAI           .word    DOCOL             
                .word    DUP               
                .word    ZERO              
                .word    PDO               
L1663           .word    OVER              
                .word    OVER              
                .word    PLUS              
                .word    ONE               
                .word    SUB               
                .word    CAT               
                .word    BL                
                .word    SUB               
                .word    ZBRAN             
L1672           .word    8                 ;L1676-L1672
                .word    LEAVE             
                .word    BRAN              
L1675           .word    6                 ;L1678-L1675
L1676           .word    ONE               
                .word    SUB               
L1678           .word    PLOOP             
L1679           .word    $FFE0             ;L1663-L1679
                .word    SEMIS             
;
;                                       (.")
;                                       SCREEN 44 LINE 8
L1685           .byte    $84,"(.",$22,$A9  ;$84 (." $A9
                .word    L1657             ;link to -TRAILING
PDOTQ           .word    DOCOL             
                .word    R                 
                .word    COUNT             
                .word    DUP               
                .word    ONEP              
                .word    RFROM             
                .word    PLUS              
                .word    TOR               
                .word    TYPE              
                .word    SEMIS             
;
;                                       ."
;                                       SCREEN 44 LINE12
;
L1701           .byte    $C2,".",$A2       
                .word    L1685             ;link to PDOTQ
                .word    DOCOL             
                .word    CLIT              
                .byte    $22               
                .word    STATE             
                .word    AT                
                .word    ZBRAN             
L1709           .word    $14               ;L1719-L1709
                .word    COMP              
                .word    PDOTQ             
                .word    WORD              
                .word    HERE              
                .word    CAT               
                .word    ONEP              
                .word    ALLOT             
                .word    BRAN              
L1718           .word    $A                ;L1723-L1718
L1719           .word    WORD              
                .word    HERE              
                .word    COUNT             
                .word    TYPE              
L1723           .word    SEMIS             
;
;                                       EXPECT
;                                       SCREEN 45 LINE 2
;
L1729           .byte    $86,"EXPEC",$D4   
                .word    L1701             ;link to ."
EXPEC           .word    DOCOL             
                .word    OVER              
                .word    PLUS              
                .word    OVER              
                .word    PDO               
L1736           .word    KEY               
                .word    DUP               
                .word    CLIT              
                .byte    $E                
                .word    PORIG             
                .word    AT                
                .word    EQUAL             
                .word    ZBRAN             
L1744           .word    $1F               ;L1760-L1744
                .word    DROP              
                .word    CLIT              
                .byte    08                ;Backspace!
                .word    OVER              
                .word    I                 
                .word    EQUAL             
                .word    DUP               
                .word    RFROM             
                .word    TWO               
                .word    SUB               
                .word    PLUS              
                .word    TOR               
                .word    SUB               
                .word    BRAN              
L1759           .word    $27               ;L1779-L1759
L1760           .word    DUP               
                .word    CLIT              
                .byte    $0D               
                .word    EQUAL             
                .word    ZBRAN             
L1765           .word    $0E               ;L1772-L1765
                .word    LEAVE             
                .word    DROP              
                .word    BL                
                .word    ZERO              
                .word    BRAN              
L1771           .word    04                ;L1773-L1771
L1772           .word    DUP               
L1773           .word    I                 
                .word    CSTOR             
                .word    ZERO              
                .word    I                 
                .word    ONEP              
                .word    STORE             
L1779           .word    EMIT              
                .word    PLOOP             
L1781           .word    $FFA9             
                .word    DROP              ;L1736-L1781
                .word    SEMIS             
;
;                                       QUERY
;                                       SCREEN 45 LINE 9
;
L1788           .byte    $85,"QUER",$D9    
                .word    L1729             ;link to EXPECT
QUERY           .word    DOCOL             
                .word    TIB               
                .word    AT                
                .word    CLIT              
                .byte    80                ;80 characters from terminal
                .word    EXPEC             
                .word    ZERO              
                .word    IN                
                .word    STORE             
                .word    SEMIS             
;
;                                       X
;                                       SCREEN 45 LINE 11
;                                       Actually Ascii Null
;
L1804           .byte    $C1,$80           
                .word    L1788             ;link to QUERY
                .word    DOCOL             
                .word    BLK               
                .word    AT                
                .word    ZBRAN             
L1810           .word    $2A               ;L1830-l1810
                .word    ONE               
                .word    BLK               
                .word    PSTOR             
                .word    ZERO              
                .word    IN                
                .word    STORE             
                .word    BLK               
                .word    AT                
                .word    ZERO,BSCR         
                .word    USLAS             
                .word    DROP              ;fixed from model
                .word    ZEQU              
                .word    ZBRAN             
L1824           .word    8                 ;L1828-L1824
                .word    QEXEC             
                .word    RFROM             
                .word    DROP              
L1828           .word    BRAN              
L1829           .word    6                 ;L1832-L1829
L1830           .word    RFROM             
                .word    DROP              
L1832           .word    SEMIS             
;
;                                       FILL
;                                       SCREEN 46 LINE 1
;
;
L1838           .byte    $84,"FIL",$CC     
                .word    L1804             ;link to X
FILL            .word    DOCOL             
                .word    SWAP              
                .word    TOR               
                .word    OVER              
                .word    CSTOR             
                .word    DUP               
                .word    ONEP              
                .word    RFROM             
                .word    ONE               
                .word    SUB               
                .word    CMOVE             
                .word    SEMIS             
;
;                                       ERASE
;                                       SCREEN 46 LINE 4
;
L1856           .byte    $85,"ERAS",$C5    
                .word    L1838             ;link to FILL
ERASE           .word    DOCOL             
                .word    ZERO              
                .word    FILL              
                .word    SEMIS             
;
;                                       BLANKS
;                                       SCREEN 46 LINE 7
;
L1866           .byte    $86,"BLANK",$D3   
                .word    L1856             ;link to ERASE
BLANK           .word    DOCOL             
                .word    BL                
                .word    FILL              
                .word    SEMIS             
;
;                                       HOLD
;                                       SCREEN 46 LINE 10
;
L1876           .byte    $84,"HOL",$C4     
                .word    L1866             ;link to BLANKS
HOLD            .word    DOCOL             
                .word    LIT,$FFFF         
                .word    HLD               
                .word    PSTOR             
                .word    HLD               
                .word    AT                
                .word    CSTOR             
                .word    SEMIS             
;
;                                       PAD
;                                       SCREEN 46 LINE 13
;
L1890           .byte    $83,"PA",$C4      
                .word    L1876             ;link to HOLD
PAD             .word    DOCOL             
                .word    HERE              
                .word    CLIT              
                .byte    68                ;PAD is 68 bytes above here.
                .word    PLUS              
                .word    SEMIS             
;
;                                       WORD
;                                       SCREEN 47 LINE 1
;
L1902           .byte    $84,"WOR",$C4     
                .word    L1890             ;link to PAD
WORD            .word    DOCOL             
                .word    BLK               
                .word    AT                
                .word    ZBRAN             
L1908           .word    $C                ;L1914-L1908
                .word    BLK               
                .word    AT                
                .word    BLOCK             
                .word    BRAN              
L1913           .word    $6                ;L1916-L1913
L1914           .word    TIB               
                .word    AT                
L1916           .word    IN                
                .word    AT                
                .word    PLUS              
                .word    SWAP              
                .word    ENCL              
                .word    HERE              
                .word    CLIT              
                .byte    $22               
                .word    BLANK             
                .word    IN                
                .word    PSTOR             
                .word    OVER              
                .word    SUB               
                .word    TOR               
                .word    R                 
                .word    HERE              
                .word    CSTOR             
                .word    PLUS              
                .word    HERE              
                .word    ONEP              
                .word    RFROM             
                .word    CMOVE             
                .word    SEMIS             
;
;                                       UPPER
;                                       SCREEN 47 LINE 12
;
L1943           .byte    $85,"UPPE",$D2    
                .word    L1902             ;link to WORD
UPPER           .word    DOCOL             
                .word    OVER              ;This routine converts text to U case
                .word    PLUS              ;It allows interpretation from a term.
                .word    SWAP              ;without a shift-lock.
                .word    PDO               
L1950           .word    I                 
                .word    CAT               
                .word    CLIT              
                .byte    $5F               
                .word    GREAT             
                .word    ZBRAN             
L1956           .word    09                ;L1961-L1956
                .word    I                 
                .word    CLIT              
                .byte    $20               
                .word    TOGGL             
L1961           .word    PLOOP             
L1962           .word    $FFEA             ;L1950-L1962
                .word    SEMIS             
;
;                                       (NUMBER)
;                                       SCREEN 48 LINE 1
;
L1968           .byte    $88,"(NUMBER",$A9 
                .word    L1943             ;link to UPPER
PNUMB           .word    DOCOL             
L1971           .word    ONEP              
                .word    DUP               
                .word    TOR               
                .word    CAT               
                .word    BASE              
                .word    AT                
                .word    DIGIT             
                .word    ZBRAN             
L1979           .word    $2C               ;L2001-L1979
                .word    SWAP              
                .word    BASE              
                .word    AT                
                .word    USTAR             
                .word    DROP              
                .word    ROT               
                .word    BASE              
                .word    AT                
                .word    USTAR             
                .word    DPLUS             
                .word    DPL               
                .word    AT                
                .word    ONEP              
                .word    ZBRAN             
L1994           .word    8                 ;L1998-L1994
                .word    ONE               
                .word    DPL               
                .word    PSTOR             
L1998           .word    RFROM             
                .word    BRAN              
L2000           .word    $FFC6             ;L1971-L2000
L2001           .word    RFROM             
                .word    SEMIS             
;
;                                       NUMBER
;                                       SCREEN 48 LINE 6
;
L2007           .byte    $86,"NUMBE",$D2   
                .word    L1968             ;link to (NUMBER)
NUMBER          .word    DOCOL             
                .word    ZERO              
                .word    ZERO              
                .word    ROT               
                .word    DUP               
                .word    ONEP              
                .word    CAT               
                .word    CLIT              
                .byte    $2D               
                .word    EQUAL             
                .word    DUP               
                .word    TOR               
                .word    PLUS              
                .word    LIT,$FFFF         
L2023           .word    DPL               
                .word    STORE             
                .word    PNUMB             
                .word    DUP               
                .word    CAT               
                .word    BL                
                .word    SUB               
                .word    ZBRAN             
L2031           .word    $15               ;L2042-L2031
                .word    DUP               
                .word    CAT               
                .word    CLIT              
                .byte    $2E               
                .word    SUB               
                .word    ZERO              
                .word    QERR              
                .word    ZERO              
                .word    BRAN              
L2041           .word    $FFDD             ;L2023-L2041
L2042           .word    DROP              
                .word    RFROM             
                .word    ZBRAN             
L2045           .word    4                 ;L2047-L2045
                .word    DMINU             
L2047           .word    SEMIS             
;
;                                       -FIND
;                                       SCREEN 48 LINE 12
;
L2052           .byte    $85,"-FIN",$C4    
                .word    L2007             ;link to NUMBER
DFIND           .word    DOCOL             
                .word    BL                
                .word    WORD              
                .word    HERE              ;)
                .word    COUNT             ;|- Optional allowing free use of low
                .word    UPPER             ;)  case from terminal
                .word    HERE              
                .word    CON               
                .word    AT                
                .word    AT                
                .word    PFIND             
                .word    DUP               
                .word    ZEQU              
                .word    ZBRAN             
L2068           .word    $A                ;L2073-L2068
                .word    DROP              
                .word    HERE              
                .word    LATES             
                .word    PFIND             
L2073           .word    SEMIS             
;
;                                       (ABORT)
;                                       SCREEN 49 LINE 2
;
L2078           .byte    $87,"(ABORT",$A9  
                .word    L2052             ;link to -FIND
PABOR           .word    DOCOL             
                .word    ABORT             
                .word    SEMIS             
;
;                                       ERROR
;                                       SCREEN 49 LINE 4
;
L2087           .byte    $85,"ERRO",$D2    
                .word    L2078             ;link to (ABORT)
ERROR           .word    DOCOL             
                .word    WARN              
                .word    AT                
                .word    ZLESS             
                .word    ZBRAN             
L2094           .word    $4                ;L2096-L2094
                .word    PABOR             
L2096           .word    HERE              
                .word    COUNT             
                .word    TYPE              
                .word    PDOTQ             
                .byte    4,"  ? "          
                .word    MESS              
                .word    SPSTO             
                .word    DROP,DROP         ;make room for 2 error values
                .word    IN                
                .word    AT                
                .word    BLK               
                .word    AT                
                .word    QUIT              
                .word    SEMIS             
;
;                                       ID.
;                                       SCREEN 49 LINE 9
;
L2113           .byte    $83,"ID",$AE      
                .word    L2087             ;link to ERROR
IDDOT           .word    DOCOL             
                .word    PAD               
                .word    CLIT              
                .byte    $20               
                .word    CLIT              
                .byte    $5F               
                .word    FILL              
                .word    DUP               
                .word    PFA               
                .word    LFA               
                .word    OVER              
                .word    SUB               
                .word    PAD               
                .word    SWAP              
                .word    CMOVE             
                .word    PAD               
                .word    COUNT             
                .word    CLIT              
                .byte    $1F               
                .word    ANDD              
                .word    TYPE              
                .word    SPACE             
                .word    SEMIS             
;
;                                       CREATE
;                                       SCREEN 50 LINE 2
;
L2142           .byte    $86,"CREAT",$C5   
                .word    L2113             ;link to ID
CREAT           .word    DOCOL             
                .word    TIB               ;)
                .word    HERE              ;|
                .word    CLIT              ;|  6502 only, assures
                .byte    $A0               ;|  room exists in dict.
                .word    PLUS              ;|
                .word    ULESS             ;|
                .word    TWO               ;|
                .word    QERR              ;)
                .word    DFIND             
                .word    ZBRAN             
L2155           .word    $0F               
                .word    DROP              
                .word    NFA               
                .word    IDDOT             
                .word    CLIT              
                .byte    4                 
                .word    MESS              
                .word    SPACE             
L2163           .word    HERE              
                .word    DUP               
                .word    CAT               
                .word    WIDTH             
                .word    AT                
                .word    MIN               
                .word    ONEP              
                .word    ALLOT             
                .word    DP                ;)
                .word    CAT               ;| 6502 only. The code field
                .word    CLIT              ;| must not straddle page
                .byte    $FD               ;| boundaries
                .word    EQUAL             ;|
                .word    ALLOT             ;)
                .word    DUP               
                .word    CLIT              
                .byte    $A0               
                .word    TOGGL             
                .word    HERE              
                .word    ONE               
                .word    SUB               
                .word    CLIT              
                .byte    $80               
                .word    TOGGL             
                .word    LATES             
                .word    COMMA             
                .word    CURR              
                .word    AT                
                .word    STORE             
                .word    HERE              
                .word    TWOP              
                .word    COMMA             
                .word    SEMIS             
;
;                                       [COMPILE]
;                                       SCREEN 51 LINE 2
;
L2200           .byte    $C9,"[COMPILE",$DD
                .word    L2142             ;link to CREATE
                .word    DOCOL             
                .word    DFIND             
                .word    ZEQU              
                .word    ZERO              
                .word    QERR              
                .word    DROP              
                .word    CFA               
                .word    COMMA             
                .word    SEMIS             
;
;                                       LITERAL
;                                       SCREEN 51 LINE 2
;
L2216           .byte    $C7,"LITERA",$CC  
                .word    L2200             ;link to [COMPILE]
LITER           .word    DOCOL        
                .word    STATE             
                .word    AT                
                .word    ZBRAN             
L2222           .word    8                 ;L2226-L2222
                .word    COMP              
                .word    LIT               
                .word    COMMA             
L2226           .word    SEMIS             
;
;                                       DLITERAL
;                                       SCREEN 51 LINE 8
;
L2232           .byte    $C8,"DLITERA",$CC 
                .word    L2216             ;link to LITERAL
DLIT            .word    DOCOL             
                .word    STATE             
                .word    AT                
                .word    ZBRAN             
L2238           .word    8                 ;L2242-L2238
                .word    SWAP              
                .word    LITER             
                .word    LITER             
L2242           .word    SEMIS             
;
;                                       ?STACK
;                                       SCREEN 51 LINE 13
;
L2248           .byte    $86,"?STAC",$CB   
                .word    L2232             ;link to DLITERAL
QSTAC           .word    DOCOL             
                .word    CLIT              
                .byte    TOS               
                .word    SPAT              
                .word    ULESS             
                .word    ONE               
                .word    QERR              
                .word    SPAT              
                .word    CLIT              
                .byte    BOS               
                .word    ULESS             
                .word    CLIT              
                .byte    7                 
                .word    QERR              
                .word    SEMIS             
;
;                                       INTERPRET
;                                       SCREEN 52 LINE 2
;
L2269           .byte    $89,"INTERPRE",$D4
                .word    L2248             ;link to ?STACK
INTER           .word    DOCOL             
L2272           .word    DFIND             
                .word    ZBRAN             
L2274           .word    $1E               ;L2289-L2274
                .word    STATE             
                .word    AT                
                .word    LESS              
                .word    ZBRAN             
L2279           .word    $A                ;L2284-L2279
                .word    CFA               
                .word    COMMA             
                .word    BRAN              
L2283           .word    $6                ;L2286-L2283
L2284           .word    CFA               
                .word    EXEC              
L2286           .word    QSTAC             
                .word    BRAN              
L2288           .word    $1C               ;L2302-L2288
L2289           .word    HERE              
                .word    NUMBER            
                .word    DPL               
                .word    AT                
                .word    ONEP              
                .word    ZBRAN             
L2295           .word    8                 ;L2299-L2295
                .word    DLIT              
                .word    BRAN              
L2298           .word    $6                ;L2301-L2298
L2299           .word    DROP              
                .word    LITER             
L2301           .word    QSTAC             
L2302           .word    BRAN              
L2303           .word    $FFC2             ;L2272-L2303
;
;                                       IMMEDIATE
;                                       SCREEN 53 LINE 1
;
L2309           .byte    $89,"IMMEDIAT",$C5
                .word    L2269             ;; link to INTERPRET
                .word    DOCOL             
                .word    LATES             
                .word    CLIT              
                .byte    $40               
                .word    TOGGL             
                .word    SEMIS             
;
;                                       VOCABULARY
;                                       SCREEN 53 LINE 4
;
L2321           .byte    $8A,"VOCABULAR",$D9
                .word    L2309             ;link to IMMEDIATE
                .word    DOCOL             
                .word    BUILD             
                .word    LIT,$A081         
                .word    COMMA             
                .word    CURR              
                .word    AT                
                .word    CFA               
                .word    COMMA             
                .word    HERE              
                .word    VOCL              
                .word    AT                
                .word    COMMA             
                .word    VOCL              
                .word    STORE             
                .word    DOES              
DOVOC           .word    TWOP              
                .word    CON               
                .word    STORE             
                .word    SEMIS             
;
;                                       FORTH
;                                       SCREEN 53 LINE 9
;
L2346           .byte    $C5,"FORT",$C8    
                .word    L2321             ;link to VOCABULARY
FORTH           .word    DODOE             
                .word    DOVOC             
                .word    $A081             
XFOR            .word    NTOP              ;points to top name in FORTH
VL0             .word    0                 ;last vocab link ends at zero
;
;                                       DEFINITIONS
;                                       SCREEN 53 LINE 11
;
;
L2357           .byte    $8B,"DEFINITION",$D3
                .word    L2346             ;link to FORTH
DEFIN           .word    DOCOL             
                .word    CON               
                .word    AT                
                .word    CURR              
                .word    STORE             
                .word    SEMIS             
;
;                                       (
;                                       SCREEN 53 LINE 14
;
L2369           .byte    $C1,$A8           
                .word    L2357             ;link to DEFINITIONS
                .word    DOCOL             
                .word    CLIT              
                .byte    $29               
                .word    WORD              
                .word    SEMIS             
;
;                                       QUIT
;                                       SCREEN 54 LINE 2
;
L2381           .byte    $84,"QUI",$D4     
                .word    L2369             ;link to (
QUIT            .word    DOCOL             
                .word    ZERO              
                .word    BLK               
                .word    STORE             
                .word    LBRAC             
L2388           .word    RPSTO             
                .word    CR                
                .word    QUERY             
                .word    INTER             
                .word    STATE             
                .word    AT                
                .word    ZEQU              
                .word    ZBRAN             
L2396           .word    7                 ;L2399-L2396
                .word    PDOTQ             
                .byte    2,"OK"            
L2399           .word    BRAN              
L2400           .word    $FFE7             ;L2388-L2400
                .word    SEMIS             
;
;                                       ABORT
;                                       SCREEN 54 LINE 7
;
L2406           .byte    $85,"ABOR",$D4    
                .word    L2381             ;link to QUIT
ABORT           .word    DOCOL  
                .word    SPSTO             
                .word    DECIM             
                .word    DR0               
                .word    CR                
                .word    PDOTQ             
                .byte    14,"fig-FORTH  1.0"
                .word    FORTH             
                .word    DEFIN             
                .word    QUIT         
;
;                                       COLD
;                                       SCREEN 55 LINE 1
;
L2423           .byte    $84,"COL",$C4     
                .word    L2406             ;link to ABORT
COLD            .word    *+2               
                lda   ORIG+$0C          ;from cold start area
                sta   FORTH+6           
                lda   ORIG+$0D          
                sta   FORTH+7           
                ldy   #$15              
                bne   L2433             
WARM            ldy   #$0F              
L2433           lda   ORIG+$10          
                sta   UP                
                lda   ORIG+$11          
                sta   UP+1              
L2437           lda   ORIG+$0C,y        
                sta   (UP),y            
                dey                     
                bpl   L2437             
                lda   #>ABORT          ;actually #>(ABORT+2)
                sta   IP+1              
                lda   #<ABORT+2        
                sta   IP             
                cld                     
                lda   #$6C              ;ind jump opcode
                sta   W-1               
                jmp   RPSTO+2           ;And off we go !
;
;                                       S->D
;                                       SCREEN 56 LINE 1
;
L2453           .byte    $84,"S->",$C4     
                .word    L2423             ;link to COLD
STOD            .word    DOCOL             
                .word    DUP               
                .word    ZLESS             
                .word    MINUS             
                .word    SEMIS             
;
;                                       +-
;                                       SCREEN 56 LINE 4
;
L2464           .byte    $82,"+",$AD       
                .word    L2453             ;link to S->D
PM              .word    DOCOL             
                .word    ZLESS             
                .word    ZBRAN             
L2469           .word    4                 
                .word    MINUS             
L2471           .word    SEMIS             
;
;                                       D+-
;                                       SCREEN 56 LINE 6
;
L2476           .byte    $83,"D+",$AD      
                .word    L2464             ;link to +-
DPM             .word    DOCOL             
                .word    ZLESS             
                .word    ZBRAN             
L2481           .word    4                 ;L2483-L2481
                .word    DMINU             
L2483           .word    SEMIS             
;
;                                       ABS
;                                       SCREEN 56 LINE 9
;
L2488           .byte    $83,"AB",$D3      
                .word    L2476             ;link to D+-
ABS             .word    DOCOL             
                .word    DUP               
                .word    PM                
                .word    SEMIS             
;
;                                       DABS
;                                       SCREEN 56 LINE 10
;
L2498           .byte    $84,"DAB",$D3     
                .word    L2488             ;link to ABS
DABS            .word    DOCOL             
                .word    DUP               
                .word    DPM               
                .word    SEMIS             
;
;                                       MIN
;                                       SCREEN 56 LINE 12
;
L2508           .byte    $83,"MI",$CE      
                .word    L2498             ;link to DABS
MIN             .word    DOCOL             
                .word    OVER              
                .word    OVER              
                .word    GREAT             
                .word    ZBRAN             
L2515           .word    4                 ;L2517-L2515
                .word    SWAP              
L2517           .word    DROP              
                .word    SEMIS             
;
;                                       MAX
;                                       SCREEN 56 LINE 14
;
L2523           .byte    $83,"MA",$D8      
                .word    L2508             ;link to MIN
MAX             .word    DOCOL             
                .word    OVER              
                .word    OVER              
                .word    LESS              
                .word    ZBRAN             
L2530           .word    4                 ;L2532-L2530
                .word    SWAP              
L2532           .word    DROP              
                .word    SEMIS             
;
;                                       M*
;                                       SCREEN 57 LINE 1
;
L2538           .byte    $82,"M",$AA       
                .word    L2523             ;link to MAX
MSTAR           .word    DOCOL             
                .word    OVER              
                .word    OVER              
                .word    XOR               
                .word    TOR               
                .word    ABS               
                .word    SWAP              
                .word    ABS               
                .word    USTAR             
                .word    RFROM             
                .word    DPM               
                .word    SEMIS             
;
;                                       M/
;                                       SCREEN 57 LINE 3
;
L2556           .byte    $82,"M",$AF       
                .word    L2538             ;link to M*
MSLAS           .word    DOCOL             
                .word    OVER              
                .word    TOR               
                .word    TOR               
                .word    DABS              
                .word    R                 
                .word    ABS               
                .word    USLAS             
                .word    RFROM             
                .word    R                 
                .word    XOR               
                .word    PM                
                .word    SWAP              
                .word    RFROM             
                .word    PM                
                .word    SWAP              
                .word    SEMIS             
;
;                                       *
;                                       SCREEN 57 LINE 7
;
L2579           .byte    $81,$AA           
                .word    L2556             ;link to M/
STAR            .word    DOCOL             
                .word    USTAR             
                .word    DROP              
                .word    SEMIS             
;
;                                       /MOD
;                                       SCREEN 57 LINE 8
;
L2589           .byte    $84,"/MO",$C4     
                .word    L2579             ;link to *
SLMOD           .word    DOCOL             
                .word    TOR               
                .word    STOD              
                .word    RFROM             
                .word    MSLAS             
                .word    SEMIS             
;
;                                       /
;                                       SCREEN 57 LINE 9
;
L2601           .byte    $81,$AF           
                .word    L2589             ;link to /MOD
SLASH           .word    DOCOL             
                .word    SLMOD             
                .word    SWAP              
                .word    DROP              
                .word    SEMIS             
;
;                                       MOD
;                                       SCREEN 57 LINE 10
;
L2612           .byte    $83,"MO",$C4      
                .word    L2601             ;link to /
MOD             .word    DOCOL             
                .word    SLMOD             
                .word    DROP              
                .word    SEMIS             
;
;                                       */MOD
;                                       SCREEN 57 LINE 11
;
L2622           .byte    $85,"*/MO",$C4    
                .word    L2612             ;link to MOD
SSMOD           .word    DOCOL             
                .word    TOR               
                .word    MSTAR             
                .word    RFROM             
                .word    MSLAS             
                .word    SEMIS             
;
;                                       */
;                                       SCREEN 57 LINE 13
;
L2634           .byte    $82,"*",$AF       
                .word    L2622             ;link to */MOD
SSLAS           .word    DOCOL             
                .word    SSMOD             
                .word    SWAP              
                .word    DROP              
                .word    SEMIS             
;
;                                       M/MOD
;                                       SCREEN 57 LINE 14
;
L2645           .byte    $85,"M/MO",$C4    
                .word    L2634             ;link to */
MSMOD           .word    DOCOL             
                .word    TOR               
                .word    ZERO              
                .word    R                 
                .word    USLAS             
                .word    RFROM             
                .word    SWAP              
                .word    TOR               
                .word    USLAS             
                .word    RFROM             
                .word    SEMIS             
;
;                                       USE
;                                       SCREEN 58 LINE 1
;
L2662           .byte    $83,"US",$C5      
                .word    L2645             ;link to M/MOD
USE             .word    DOVAR             
                .word    DAREA             
;
;                                       PREV
;                                       SCREEN 58 LINE 2
;
L2670           .byte    $84,"PRE",$D6     
                .word    L2662             ;link to USE
PREV            .word    DOVAR             
                .word    DAREA             
;
;                                       +BUF
;                                       SCREEN 58 LINE 4
;
;
L2678           .byte    $84,"+BU",$C6     
                .word    L2670             ;link to PREV
PBUF            .word    DOCOL             
                .word    LIT               
                .word    SSIZE+4           ;hold block #, one sector two num
                .word    PLUS              
                .word    DUP               
                .word    LIMIT             
                .word    EQUAL             
                .word    ZBRAN             
L2688           .word    6                 ;L2691-L2688
                .word    DROP              
                .word    FIRST             
L2691           .word    DUP               
                .word    PREV              
                .word    AT                
                .word    SUB               
                .word    SEMIS             
;
;                                       UPDATE
;                                       SCREEN 58 LINE 8
;
L2700           .byte    $86,"UPDAT",$C5   
                .word    L2678             ;link to +BUF
UPDAT           .word    DOCOL             
                .word    PREV              
                .word    AT                
                .word    AT                
                .word    LIT,$8000         
                .word    OR                
                .word    PREV              
                .word    AT                
                .word    STORE             
                .word    SEMIS             
;
;                                       FLUSH
;
L2705           .byte    $85,"FLUS",$C8    
                .word    L2700             ;link to UPDATE
                .word    DOCOL             
                .word    LIMIT,FIRST,SUB   
                .word    BBUF,CLIT         
                .byte    4                 
                .word    PLUS,SLASH,ONEP   
                .word    ZERO,PDO          
L2835           .word    LIT,$7FFF,BUFFR   
                .word    DROP,PLOOP        
L2839           .word    $FFF6             ;L2835-L2839
                .word    SEMIS             
;
;                                       EMPTY-BUFFERS
;                                       SCREEN 58 LINE 11
;
L2716           .byte    $8D,"EMPTY-BUFFER",$D3
                .word    L2705             ;link to FLUSH
                .word    DOCOL             
                .word    FIRST             
                .word    LIMIT             
                .word    OVER              
                .word    SUB               
                .word    ERASE             
                .word    SEMIS             
;
;                                       DR0
;                                       SCREEN 58 LINE 14
;
L2729           .byte    $83,"DR",$B0      
                .word    L2716             ;link to EMPTY-BUFFERS
DR0             .word    DOCOL             
                .word    ZERO              
                .word    OFSET             
                .word    STORE             
                .word    SEMIS             
;
;                                       DR1
;                                       SCREEN 58 LINE 15
;
L2740           .byte    $83,"DR",$B1      
                .word    L2729             ;link to DR0
                .word    DOCOL             
                .word    LIT,SECTR         ;sectors per drive
                .word    OFSET             
                .word    STORE             
                .word    SEMIS             
;
;                                       BUFFER
;                                       SCREEN 59 LINE 1
;
L2751           .byte    $86,"BUFFE",$D2   
                .word    L2740             ;link to DR1
BUFFR           .word    DOCOL             
                .word    USE               
                .word    AT                
                .word    DUP               
                .word    TOR               
L2758           .word    PBUF              
                .word    ZBRAN             
L2760           .word    $FFFC             ;L2758-L2760
                .word    USE               
                .word    STORE             
                .word    R                 
                .word    AT                
                .word    ZLESS             
                .word    ZBRAN             
L2767           .word    $14               ;L2776-L2767
                .word    R                 
                .word    TWOP              
                .word    R                 
                .word    AT                
                .word    LIT,$7FFF         
                .word    ANDD              
                .word    ZERO              
;          .WORD RSLW
                .word    RSW               
L2776           .word    R                 
                .word    STORE             
                .word    R                 
                .word    PREV              
                .word    STORE             
                .word    RFROM             
                .word    TWOP              
                .word    SEMIS             
;
;                                       BLOCK
;                                       SCREEN 60 LINE 1
;
L2788           .byte    $85,"BLOC",$CB    
                .word    L2751             ;link to BUFFER
BLOCK           .word    DOCOL             
                .word    OFSET             
                .word    AT                
                .word    PLUS              
                .word    TOR               
                .word    PREV              
                .word    AT                
                .word    DUP               
                .word    AT                
                .word    R                 
                .word    SUB               
                .word    DUP               
                .word    PLUS              
                .word    ZBRAN             
L2804           .word    $34               ;L2830-L2804
L2805           .word    PBUF              
                .word    ZEQU              
                .word    ZBRAN             
L2808           .word    $14               ;L2818-L2808
                .word    DROP              
                .word    R                 
                .word    BUFFR             
                .word    DUP               
                .word    R                 
                .word    ONE               
;          .WORD RSLW
                .word    RSW               
                .word    TWO               
                .word    SUB               
L2818           .word    DUP               
                .word    AT                
                .word    R                 
                .word    SUB               
                .word    DUP               
                .word    PLUS              
                .word    ZEQU              
                .word    ZBRAN             
L2826           .word    $FFD6             ;L2805-L2826
                .word    DUP               
                .word    PREV              
                .word    STORE             
L2830           .word    RFROM             
                .word    DROP              
                .word    TWOP              
                .word    SEMIS             ;end of BLOCK
;
;
;                                       (LINE)
;                                       SCREEN 61 LINE 2
;
L2838           .byte    $86,"(LINE",$A9   
                .word    L2788             ;link to BLOCK
PLINE           .word    DOCOL             
                .word    TOR               
                .word    CSLL              
                .word    BBUF              
                .word    SSMOD             
                .word    RFROM             
                .word    BSCR              
                .word    STAR              
                .word    PLUS              
                .word    BLOCK             
                .word    PLUS              
                .word    CSLL              
                .word    SEMIS             
;
;                                       .LINE
;                                       SCREEN 61 LINE 6
;
L2857           .byte    $85,".LIN",$C5    
                .word    L2838             ;link to (LINE)
DLINE           .word    DOCOL             
                .word    PLINE             
                .word    DTRAI             
                .word    TYPE              
                .word    SEMIS             
;
;                                       MESSAGE
;                                       SCREEN 61 LINE 9
;
L2868           .byte    $87,"MESSAG",$C5  
                .word    L2857             ;link to .LINE
MESS            .word    DOCOL             
                .word    WARN              
                .word    AT                
                .word    ZBRAN             
L2874           .word    $1B               ;L2888-L2874
                .word    DDUP              
                .word    ZBRAN             
L2877           .word    $11               ;L2886-L2877
                .word    CLIT              
                .byte    4                 
                .word    OFSET             
                .word    AT                
                .word    BSCR              
                .word    SLASH             
                .word    SUB               
                .word    DLINE             
L2886           .word    BRAN              
L2887           .word    13                ;L2891-L2887
L2888           .word    PDOTQ             
                .byte    6,"MSG # "        
                .word    DOT               
L2891           .word    SEMIS             
;
;                                       LOAD
;                                       SCREEN 62 LINE 2
;
L2896           .byte    $84,"LOA",$C4     
                .word    L2868             ;link to MESSAGE
LOAD            .word    DOCOL             
                .word    BLK               
                .word    AT                
                .word    TOR               
                .word    IN                
                .word    AT                
                .word    TOR               
                .word    ZERO              
                .word    IN                
                .word    STORE             
                .word    BSCR              
                .word    STAR              
                .word    BLK               
                .word    STORE             
                .word    INTER             
                .word    RFROM             
                .word    IN                
                .word    STORE             
                .word    RFROM             
                .word    BLK               
                .word    STORE             
                .word    SEMIS             
;
;                                       -->
;                                       SCREEN 62 LINE 6
;
L2924           .byte    $C3,"--",$BE      
                .word    L2896             ;link to LOAD
                .word    DOCOL             
                .word    QLOAD             
                .word    ZERO              
                .word    IN                
                .word    STORE             
                .word    BSCR              
                .word    BLK               
                .word    AT                
                .word    OVER              
                .word    MOD               
                .word    SUB               
                .word    BLK               
                .word    PSTOR             
                .word    SEMIS             
;
;    XEMIT writes one ascii character to terminal
;
;
XEMIT
;	  TYA
;          SEC
;          LDY #$1A
;          ADC (UP),Y
;          STA (UP),Y
;          INY            ; bump user varaible OUT
;          LDA #0
;          ADC (UP),Y
;          STA (UP),Y
                lda   0,x               ;fetch character to output
;          STX XSAVE
                jsr   cout             ;and display it
;          LDX XSAVE
                jmp   POP               
;
;         XKEY reads one terminal keystroke to stack
;
;
XKEY
;          STX XSAVE
                jsr   cin              ;might otherwise clobber it while
;          LDX XSAVE      ; inputting a char to accumulator
                jmp   PUSHOA            
;
;         XQTER leaves a boolean representing terminal break
;
;
XQTER
     ;          jsr   cbrk              ;if Ctrl-c, set C else clear C
     clc
                lda   #$00              ;0
                rol   a                 ;move carry to bit 0
                jmp   PUSHOA            
;
;         XCR displays a CR and LF to terminal
;
;
XCR
;          STX XSAVE
                jsr   crout               ;use monitor call
;          LDX XSAVE
                jmp   NEXT              
;
; ***                                      -DISC
;                                       machine level sector R/W
;
;L3030     .BYTE $85,"-DIS",$C3
;          .WORD L2924    ; link to -->
;DDISC     .WORD *+2
;          LDA 0,X
;          STA $C60C
;          STA $C60D      ; store sector number
;          LDA 2,X
;          STA $C60A
;          STA $C60B      ; store track number
;          LDA 4,X
;          STA $C4CD
;          STA $C4CE      ; store drive number
;          STX XSAVE
;          LDA $C4DA      ; sense read or write
;          BNE L3032
;          JSR $E1FE
;          JMP L3040
;L3032     JSR $E262
;L3040     JSR $E3EF      ; head up motor off
;          LDX XSAVE
;          LDA $C4E1      ; report error code
;          STA 4,X
;          JMP POPTWO
;
;                                       -BCD
;                             Convert binary value to BCD
;
L3050           .byte    $84,"-BC",$C4     
                .word    L2924             ;link to -DISC
DBCD            .word    DOCOL             
                .word    ZERO,CLIT         
                .byte    10                
                .word    USLAS,CLIT        
                .byte    16                
                .word    STAR,OR,SEMIS     

;
; ***                                       R/W
;                              Read or write one sector
;
;L3060     .BYTE $83,"R/",$D7
;          .WORD L3050    ; link to -BCD
;RSLW      .WORD DOCOL
;          .WORD ZEQU,LIT,$C4DA,CSTOR
;          .WORD SWAP,ZERO,STORE
;          .WORD ZERO,OVER,GREAT,OVER
;          .WORD LIT,SECTL-1,GREAT,OR,CLIT
;          .BYTE 6
;          .WORD QERR
;          .WORD ZERO,LIT,SECTR,USLAS,ONEP
;          .WORD SWAP,ZERO,CLIT
;          .BYTE $12
;          .WORD USLAS,DBCD,SWAP,ONEP
;          .WORD DBCD,DDISC,CLIT
;          .BYTE 8
;          .WORD QERR
;          .WORD SEMIS
;
;
;                                           RSW
;                              Read or write one sector
;
L3070           .byte    $83,"RS",$D7      
                .word    L3050             ;link to R/W
RSW             .word    DOCOL             
                .word    TOR               
                .word    BBUF, STAR, LIT, $4000, PLUS, DUP
                .word    LIT, $6800, GREAT, LIT, $6, QERR
                .word    RFROM, ZBRAN, $4, SWAP
                .word    BBUF, CMOVE       
                .word    SEMIS             
;
;
;                                       '
;                                       SCREEN 72 LINE 2
;
L3202           .byte    $C1,$A7           
                .word    L3070             ;link to RSW
TICK            .word    DOCOL             
                .word    DFIND             
                .word    ZEQU              
                .word    ZERO              
                .word    QERR              
                .word    DROP              
                .word    LITER             
                .word    SEMIS             
;
;                                       FORGET
;                                       Altered from model
;                                       SCREEN 72 LINE 6
;
L3217           .byte    $86,"FORGE",$D4   
                .word    L3202             ;link to ' TICK
FORG            .word    DOCOL             
                .word    TICK,NFA,DUP      
                .word    FENCE,AT,ULESS,CLIT
                .byte    $15               
                .word    QERR,TOR,VOCL,AT  
L3220           .word    R,OVER,ULESS      
                .word    ZBRAN,L3225-*     
                .word    FORTH,DEFIN,AT,DUP
                .word    VOCL,STORE        
                .word    BRAN,$FFFF-24+1   ;L3220-*
L3225           .word    DUP,CLIT          
                .byte    4                 
                .word    SUB               
L3228           .word    PFA,LFA,AT        
                .word    DUP,R,ULESS       
                .word    ZBRAN,$FFFF-14+1  ;L3228-*
                .word    OVER,TWO,SUB,STORE
                .word    AT,DDUP,ZEQU      
                .word    ZBRAN,$FFFF-39+1  ;L3225-*
                .word    RFROM,DP,STORE    
                .word    SEMIS             
;
;                                       BACK
;                                       SCREEN 73 LINE 1
;
L3250           .byte    $84,"BAC",$CB     
                .word    L3217             ;link to FORGET
BACK            .word    DOCOL             
                .word    HERE              
                .word    SUB               
                .word    COMMA             
                .word    SEMIS             
;
;                                       BEGIN
;                                       SCREEN 73 LINE 3
;
L3261           .byte    $C5,"BEGI",$CE    
                .word    L3250             ;link to BACK
                .word    DOCOL             
                .word    QCOMP             
                .word    HERE              
                .word    ONE               
                .word    SEMIS             
;
;                                       ENDIF
;                                       SCREEN 73 LINE 5
;
L3273           .byte    $C5,"ENDI",$C6    
                .word    L3261             ;link to BEGIN
ENDIF           .word    DOCOL             
                .word    QCOMP             
                .word    TWO               
                .word    QPAIR             
                .word    HERE              
                .word    OVER              
                .word    SUB               
                .word    SWAP              
                .word    STORE             
                .word    SEMIS             
;
;                                       THEN
;                                       SCREEN 73 LINE 7
;
L3290           .byte    $C4,"THE",$CE     
                .word    L3273             ;link to ENDIF
                .word    DOCOL             
                .word    ENDIF             
                .word    SEMIS             
;
;                                       DO
;                                       SCREEN 73 LINE 9
;
L3300           .byte    $C2,"D",$CF       
                .word    L3290             ;link to THEN
                .word    DOCOL             
                .word    COMP              
                .word    PDO               
                .word    HERE              
                .word    THREE             
                .word    SEMIS             
;
;                                       LOOP
;                                       SCREEN 73 LINE 11
;
;
L3313           .byte    $C4,"LOO",$D0     
                .word    L3300             ;link to DO
                .word    DOCOL             
                .word    THREE             
                .word    QPAIR             
                .word    COMP              
                .word    PLOOP             
                .word    BACK              
                .word    SEMIS             
;
;                                       +LOOP
;                                       SCREEN 73 LINE 13
;
L3327           .byte    $C5,"+LOO",$D0    
                .word    L3313             ;link to LOOP
                .word    DOCOL             
                .word    THREE             
                .word    QPAIR             
                .word    COMP              
                .word    PPLOO             
                .word    BACK              
                .word    SEMIS             
;
;                                       UNTIL
;                                       SCREEN 73 LINE 15
;
L3341           .byte    $C5,"UNTI",$CC    
                .word    L3327             ;link to +LOOP
UNTIL           .word    DOCOL             
                .word    ONE               
                .word    QPAIR             
                .word    COMP              
                .word    ZBRAN             
                .word    BACK              
                .word    SEMIS             
;
;                                       END
;                                       SCREEN 74 LINE 1
;
L3355           .byte    $C3,"EN",$C4      
                .word    L3341             ;link to UNTIL
                .word    DOCOL             
                .word    UNTIL             
                .word    SEMIS             
;
;                                       AGAIN
;                                       SCREEN 74 LINE 3
;
L3365           .byte    $C5,"AGAI",$CE    
                .word    L3355             ;link to END
AGAIN           .word    DOCOL             
                .word    ONE               
                .word    QPAIR             
                .word    COMP              
                .word    BRAN              
                .word    BACK              
                .word    SEMIS             
;
;                                       REPEAT
;                                       SCREEN 74 LINE 5
;
L3379           .byte    $C6,"REPEA",$D4   
                .word    L3365             ;link to AGAIN
                .word    DOCOL             
                .word    TOR               
                .word    TOR               
                .word    AGAIN             
                .word    RFROM             
                .word    RFROM             
                .word    TWO               
                .word    SUB               
                .word    ENDIF             
                .word    SEMIS             
;
;                                       IF
;                                       SCREEN 74 LINE 8
;
L3396           .byte    $C2,"I",$C6       
                .word    L3379             ;link to REPEAT
IF              .word    DOCOL             
                .word    COMP              
                .word    ZBRAN             
                .word    HERE              
                .word    ZERO              
                .word    COMMA             
                .word    TWO               
                .word    SEMIS             
;
;                                       ELSE
;                                       SCREEN 74 LINE 10
;
L3411           .byte    $C4,"ELS",$C5     
                .word    L3396             ;link to IF
                .word    DOCOL             
                .word    TWO               
                .word    QPAIR             
                .word    COMP              
                .word    BRAN              
                .word    HERE              
                .word    ZERO              
                .word    COMMA             
                .word    SWAP              
                .word    TWO               
                .word    ENDIF             
                .word    TWO               
                .word    SEMIS             
;
;                                       WHILE
;                                       SCREEN 74 LINE 13
;
L3431           .byte    $C5,"WHIL",$C5    
                .word    L3411             ;link to ELSE
                .word    DOCOL             
                .word    IF                
                .word    TWOP              
                .word    SEMIS             
;
;                                       SPACES
;                                       SCREEN 75 LINE 1
;
L3442           .byte    $86,"SPACE",$D3   
                .word    L3431             ;link to WHILE
SPACS           .word    DOCOL             
                .word    ZERO              
                .word    MAX               
                .word    DDUP              
                .word    ZBRAN             
L3449           .word    $0C               ;L3455-L3449
                .word    ZERO              
                .word    PDO               
L3452           .word    SPACE             
                .word    PLOOP             
L3454           .word    $FFFC             ;L3452-L3454
L3455           .word    SEMIS             
;
;                                       <#
;                                       SCREEN 75 LINE 3
;
L3460           .byte    $82,"<",$A3       
                .word    L3442             ;link to SPACES
BDIGS           .word    DOCOL             
                .word    PAD               
                .word    HLD               
                .word    STORE             
                .word    SEMIS             
;
;                                       #>
;                                       SCREEN 75 LINE 5
;
L3471           .byte    $82,"#",$BE       
                .word    L3460             ;link to <#
EDIGS           .word    DOCOL             
                .word    DROP              
                .word    DROP              
                .word    HLD               
                .word    AT                
                .word    PAD               
                .word    OVER              
                .word    SUB               
                .word    SEMIS             
;
;                                       SIGN
;                                       SCREEN 75 LINE 7
;
L3486           .byte    $84,"SIG",$CE     
                .word    L3471             ;link to #>
SIGN            .word    DOCOL             
                .word    ROT               
                .word    ZLESS             
                .word    ZBRAN             
L3492           .word    $7                ;L3496-L3492
                .word    CLIT              
                .byte    $2D               
                .word    HOLD              
L3496           .word    SEMIS             
;
;                                       #
;                                       SCREEN 75 LINE 9
;
L3501           .byte    $81,$A3           
                .word    L3486             ;link to SIGN
DIG             .word    DOCOL             
                .word    BASE              
                .word    AT                
                .word    MSMOD             
                .word    ROT               
                .word    CLIT              
                .byte    9                 
                .word    OVER              
                .word    LESS              
                .word    ZBRAN             
L3513           .word    7                 ;L3517-L3513
                .word    CLIT              
                .byte    7                 
                .word    PLUS              
L3517           .word    CLIT              
                .byte    $30               
                .word    PLUS              
                .word    HOLD              
                .word    SEMIS             
;
;                                       #S
;                                       SCREEN 75 LINE 12
;
L3526           .byte    $82,"#",$D3       
                .word    L3501             ;link to #
DIGS            .word    DOCOL             
L3529           .word    DIG               
                .word    OVER              
                .word    OVER              
                .word    OR                
                .word    ZEQU              
                .word    ZBRAN             
L3535           .word    $FFF4             ;L3529-L3535
                .word    SEMIS             
;
;                                       D.R
;                                       SCREEN 76 LINE 1
;
L3541           .byte    $83,"D.",$D2      
                .word    L3526             ;link to #S
DDOTR           .word    DOCOL             
                .word    TOR               
                .word    SWAP              
                .word    OVER              
                .word    DABS              
                .word    BDIGS             
                .word    DIGS              
                .word    SIGN              
                .word    EDIGS             
                .word    RFROM             
                .word    OVER              
                .word    SUB               
                .word    SPACS             
                .word    TYPE              
                .word    SEMIS             
;
;                                       D.
;                                       SCREEN 76 LINE 5
;
L3562           .byte    $82,"D",$AE       
                .word    L3541             ;link to D.R
DDOT            .word    DOCOL             
                .word    ZERO              
                .word    DDOTR             
                .word    SPACE             
                .word    SEMIS             
;
;                                       .R
;                                       SCREEN 76 LINE 7
;
L3573           .byte    $82,".",$D2       
                .word    L3562             ;link to D.
DOTR            .word    DOCOL             
                .word    TOR               
                .word    STOD              
                .word    RFROM             
                .word    DDOTR             
                .word    SEMIS             
;
;                                       .
;                                       SCREEN 76  LINE  9
;
L3585           .byte    $81,$AE           
                .word    L3573             ;link to .R
DOT             .word    DOCOL             
                .word    STOD              
                .word    DDOT              
                .word    SEMIS             
;
;                                       ?
;                                       SCREEN 76 LINE 11
;
L3595           .byte    $81,$BF           
                .word    L3585             ;link to .
QUES            .word    DOCOL             
                .word    AT                
                .word    DOT               
                .word    SEMIS             
;
;                                       LIST
;                                       SCREEN 77 LINE 2
;
L3605           .byte    $84,"LIS",$D4     
                .word    L3595             ;link to ?
LIST            .word    DOCOL             
                .word    DECIM             
                .word    CR                
                .word    DUP               
                .word    SCR               
                .word    STORE             
                .word    PDOTQ             
                .byte    6,"SCR # "        
                .word    DOT               
                .word    CLIT              
                .byte    16                
                .word    ZERO              
                .word    PDO               
L3620           .word    CR                
                .word    I                 
                .word    THREE             
                .word    DOTR              
                .word    SPACE             
                .word    I                 
                .word    SCR               
                .word    AT                
                .word    DLINE             
                .word    PLOOP             
L3630           .word    $FFEC             
                .word    CR                
                .word    SEMIS             
;
;                                       INDEX
;                                       SCREEN 77 LINE 7
;
L3637           .byte    $85,"INDE",$D8    
                .word    L3605             ;link to LIST
                .word    DOCOL             
                .word    CR                
                .word    ONEP              
                .word    SWAP              
                .word    PDO               
L3647           .word    CR                
                .word    I                 
                .word    THREE             
                .word    DOTR              
                .word    SPACE             
                .word    ZERO              
                .word    I                 
                .word    DLINE             
                .word    QTERM             
                .word    ZBRAN             
L3657           .word    4                 ;L3659-L3657
                .word    LEAVE             
L3659           .word    PLOOP             
L3660           .word    $FFE6             ;L3647-L3660
                .word    CLIT              
                .byte    $0C               ;form feed for printer
                .word    EMIT              
                .word    SEMIS             
;
;                                       TRIAD
;                                       SCREEN 77 LINE 12
;
L3666           .byte    $85,"TRIA",$C4    
                .word    L3637             ;link to INDEX
                .word    DOCOL             
                .word    THREE             
                .word    SLASH             
                .word    THREE             
                .word    STAR              
                .word    THREE             
                .word    OVER              
                .word    PLUS              
                .word    SWAP              
                .word    PDO               
L3681           .word    CR                
                .word    I                 
                .word    LIST              
                .word    PLOOP             
L3685           .word    $FFF8             ;L3681-L3685
                .word    CR                
                .word    CLIT              
                .byte    $F                
                .word    MESS              
                .word    CR                
                .word    CLIT              
                .byte    $0C               ;form feed for printer
                .word    EMIT              
                .word    SEMIS             
;
;                                       VLIST
;                                       SCREEN 78 LINE 2
;
;
L3696           .byte    $85,"VLIS",$D4    
                .word    L3666             ;link to TRIAD
VLIST           .word    DOCOL             
                .word    CLIT              
                .byte    $80               
                .word    OUT               
                .word    STORE             
                .word    CON               
                .word    AT                
                .word    AT                
L3706           .word    OUT               
                .word    AT                
                .word    CSLL              
                .word    GREAT             
                .word    ZBRAN             
L3711           .word    $A                ;L3716-L3711
                .word    CR                
                .word    ZERO              
                .word    OUT               
                .word    STORE             
L3716           .word    DUP               
                .word    IDDOT             
                .word    SPACE             
                .word    SPACE             
                .word    PFA               
                .word    LFA               
                .word    AT                
                .word    DUP               
                .word    ZEQU              
                .word    QTERM             
                .word    OR                
                .word    ZBRAN             
L3728           .word    $FFD4             ;L3706-L3728
                .word    DROP              
                .word    SEMIS             
;
;                                       MON
;                                       SCREEN 79 LINE 3
;
NTOP            .byte    $83,"MO",$CE      
                .word    L3696             ;link to VLIST
MON             .word    *+2      
wait1:         dec 0                    ;low digit 0
               bne   wait1
               dec 1                    ;digit 1
               bne   wait1
               dec 2                    ;if we get here, counted 64K
               lda   2                  ;get digit 2
               lsr   a                  ;and use bit 2 as flasher
               lsr   a
               sta   $C000
               jmp   wait1
 brk         
                jmp   ($FFFC)       ;back to SBC Monitor
;          STX XSAVE
;          BRK       ; break to monitor which is assumed
;          LDX XSAVE ; to save this as reentry point
;          JMP NEXT
;

lf:
        pha
        lda #$0a
        jsr krn_chrout
        pla
        rts


TOP                                     ;end of listing

