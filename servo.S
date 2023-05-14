;------------------------
; Assembly Code
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
; .global servo_motor
.global main

main:

RCALL servo_motor

RCALL main
;===============================================================
servo_motor:
;-----------
    SBI   DDRB, 4         ;pin PB4 o/p for servo control
    ; SBI   DDRB, 0         ;PB0 o/p, red LED: pos 0 deg
    ; SBI   DDRB, 1         ;PB1 o/p, green LED: pos 90 deg
    ; SBI   DDRB, 2         ;PB2 o/p, blue LED: pos 180 deg
;---------------------------------------------------------------
again:     
    LDI   R27, 1          ;counter for LED control
    LDI   R26, 8          ;counter for # of rotation pos
    LDI   ZL, lo8(rotate_pos)
    LDI   ZH, hi8(rotate_pos)
    ;-----------------------------------------------------------
l1: LPM   R16, Z+         ;load rotation pos
    RCALL rotate_servo    ;& rotate servo
    DEC   R26
    BRNE  l1              ;go back & get another rotate pos
    ;-----------------------------------------------------------
    RET         ;go back & repeat
;---------------------------------------------------------------
rotate_pos:
.byte 40,70,90,110,180,110,90,70
;===============================================================
rotate_servo:
;------------
    LDI   R20, 10         ;count to give enough cycles of PWM
ls2: SBI   PORTB, 4
    RCALL delay_timer0Servo
    CBI   PORTB, 4        ;send msec pulse to rotate servo
    RCALL delay_20ms_servo      ;wait 20ms before re-sending pulse
    DEC   R20
    BRNE  ls2              ;go back & repeat PWM signal
    ;-----------------------------------------------------------
    ; CPI   R27, 1
    ; BREQ  red_LED         ;if pos 0 deg, turn ON red LED
    ; CPI   R27, 3
    ; BREQ  green_LED       ;if pos 90 deg, turn ON green LED
    ; CPI   R27, 5
    ; BREQ  blue_LED        ;if pos 180 deg, turn ON blue LED
    ; CPI   R27, 7
    ; BREQ  green_LED       ;if pos 90 deg, turn ON green LED
bak:RCALL delay_ms        ;0.5s delay
    CBI   PORTB, 0
    CBI   PORTB, 1
    ; CBI   PORTB, 2        ;turn OFF all LEDs
    INC   R27
    RET                   ;& return to main subroutine
;-------------------
; red_LED:                  ;subroutine to turn ON red LED
;     SBI   PORTB, 0
;     CBI   PORTB, 1
;     ; CBI   PORTB, 2
;     RJMP  bak
; ;------------------
; green_LED:                ;subroutine to turn ON green LED
;     CBI   PORTB, 0
;     SBI   PORTB, 1
;     ; CBI   PORTB, 2
;     RJMP  bak
; ;------------------
; blue_LED:                 ;subroutine to turn ON blue LED
;     CBI   PORTB, 0
;     CBI   PORTB, 1
;     ; SBI   PORTB, 2
;     RJMP  bak
;===============================================================
;delay subroutines
;===============================================================
delay_timer0Servo:             ;delay via Timer0
    ;-----------------------------------------------------------
    CLR   R21
    OUT   TCNT0, R21      ;initialize timer0 with count=0
    MOV   R21, R16
    OUT   OCR0A, R21
    LDI   R21, 0b00001100
    OUT   TCCR0B, R21     ;timer0: CTC mode, prescaler 256
    ;-----------------------------------------------------------
ls3: IN    R21, TIFR0      ;get TIFR0 byte & check
    SBRS  R21, OCF0A      ;if OCF0=1, skip next instruction
    RJMP  ls3              ;else, loop back & check OCF0 flag
    ;-----------------------------------------------------------
    CLR   R21
    OUT   TCCR0B, R21     ;stop timer0
    ;-----------------------------------------------------------
    LDI   R21, (1<<OCF0A)
    OUT   TIFR0, R21      ;clear OCF0 flag
    RET
;===============================================================

;===============================================================
delay_ms:                 ;delay 0.5s
    LDI   R21, 255
ls7 :LDI   R22, 255
ls8 :LDI   R23, 41
l9 :DEC   R23
    BRNE  l9
    DEC   R22
    BRNE  ls8
    DEC   R21
    BRNE  ls7
    RET

;===============================================================
delay_20ms_servo:               ;delay 20ms
    LDI   R21, 255
ls4: LDI   R22, 210
ls5: LDI   R23, 2
ls6: DEC   R23
    BRNE  ls6
    DEC   R22
    BRNE  ls5
    DEC   R21
    BRNE  ls4
    RET