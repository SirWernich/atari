    processor 6502
    include "../headers/vcs.h"
    include "../headers/macro.h"

    seg code
    org $F000
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start of the ROM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Start:
    CLEAN_START

    ldx #$80            ; blue background
    stx COLUBK

    lda #$1C            ; yellow playfield
    sta COLUPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by configuring VSync and VBlank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
    lda #%00000010      ; 2
    sta VBLANK          ; turn on VBLANK
    sta VSYNC           ; turn on VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; generate 3 lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC
    sta WSYNC
    sta WSYNC

    lda #0
    sta VSYNC           ; turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; generate 37 lines of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #37
WriteVBlank:
    sta WSYNC
    dex
    bne WriteVBlank

    lda #0
    sta VBLANK          ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set the CTRLPF register to allow playfield reflection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #%00000001      ; CTRLPF register (D0 means reflect the PF)
    stx CTRLPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw the 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; skip 7 scanlines with no PF set
    ldx #0
    stx PF0
    stx PF1
    stx PF2

    ldx #7
TopPFBlankRenderLoop:
    sta WSYNC
    dex
    bne TopPFBlankRenderLoop

    ; set the PF0 to 1110 (LSB first) and PF1-PF2 as 1111 1111
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    
    ldx #7
TopPFRenderLoop:
    sta WSYNC
    dex
    bne TopPFRenderLoop
    
    ; set the next 164 lines only with PF0 third bit enabled
    ldx #%00100000
    stx PF0
    ldx #0
    stx PF1
    stx PF2
    
    ldx #164
MiddlePlayFieldLoop:
    sta WSYNC
    dex
    bne MiddlePlayFieldLoop

    ; set the PF0 to 1110 (LSB first) and PF1-PF2 as 1111 1111
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    
    ; skip 7 vertical lines with no PF set
    ldx #7
BottomPFRenderLoop:
    sta WSYNC
    dex
    bne BottomPFRenderLoop
    
    ; skip 7 scanlines with no PF set
    ldx #0
    stx PF0
    stx PF1
    stx PF2

    ldx #7
BottomPFBlankRenderLoop:
    sta WSYNC
    dex
    bne BottomPFBlankRenderLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; output 30 VBLANK overscan lines to complete the frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK

    ldx #30
BottomVBlankLoop:
    sta WSYNC
    dex
    bne BottomVBlankLoop

    lda #0
    sta VBLANK          ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop to next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fill ROM to 4k
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start
    .word Start