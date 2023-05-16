;------------------------
; Automatic Fan Kelompok B8
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global main
;=================================================================

main:
RCALL initialize_motor
RCALL SPI_MAX7219_init
RCALL MAX7219_disp_text
loop:
RCALL DHT11_sensor
RCALL HC_SR04_sensor

RJMP loop

first_condition: ;Jika kondisi sekitar dingin
CBI PORTD, 5
CBI PORTD, 6
RCALL turn_off_motor
SBI PORTD, 4
RJMP continue 

second_condition: ; Jika kondisi sekitar normal
CBI PORTD, 6 
SBI PORTD, 5 
CBI PORTD, 4
; RCALL turn_off_motor
RJMP continue 

third_condition: ; Jika kondisi sekitar panas
SBI PORTD, 6
CBI PORTD, 5
RCALL turn_on_motor
CBI PORTD, 4
RJMP continue 

;================================================================
;DHT11 to MAX7219 Code
;================================================================

DHT11_sensor:
;-----------------------------------------------------------------
    RCALL delay_2s      ;wait 2s for DHT11 to get ready
;-----------------------------------------------------------------
;start_signal
;------------
    ;==LED Set PD5 and PD6 as output
    SBI DDRD, 4
    SBI DDRD, 5
    SBI DDRD, 6 
    ;Initialize Servo
    SBI DDRB, 4
    ;
    SBI   DDRD, 7       ;pin PD7 as o/p
    CBI   PORTD, 7      ;first, send low pulse
    RCALL delay_20ms    ;for 20ms
    SBI   PORTD, 7      ;then send high pulse
;-----------------------------------------------------------------
;responce signal
;---------------
    CBI   DDRD, 7       ;pin PD7 as i/p
w1: SBIC  PIND, 7
    RJMP  w1            ;wait for DHT11 low pulse
w2: SBIS  PIND, 7
    RJMP  w2            ;wait for DHT11 high pulse
w3: SBIC  PIND, 7
    RJMP  w3            ;wait for DHT11 low pulse
;-----------------------------------------------------------------
    RCALL DHT11_reading ;read humidity (1st byte of 40-bit data)
    MOV   R25, R24
    RCALL DHT11_reading
    RCALL DHT11_reading ;read temp (3rd byte of 40-bit data)

    ;Pengkondisian
    CPI R24, 30 ; Kondisi Cuaca Panas ; IF >= 30
    BRSH third_condition
    CPI R24, 20 ;Kondisi Cuaca Normal : IF >= 20 and < 30 
    BRSH second_condition
    CPI R24, 20 ; Kondisi Cuaca Dingin : IF < 20
    BRLO first_condition
    continue:

;-----------------------------------------------------------------
;convert temp & humidity bytes to decimal & display on MAX7219
;-------------------------------------------------------------
    MOV   R28, R24
    LDI   R29, 0x07
    LDI   R30, 0x06
    ;-------------------
    RCALL binary2decimal  ;temp in decimal
    ;-------------------
    MOV   R28, R25
    LDI   R29, 0x02
    LDI   R30, 0x01
    ;-------------------
    RCALL binary2decimal  ;humidity in decimal
    ;-------------------
    RET                   ;go back & get another sensor reading
;=================================================================

DHT11_reading:
    LDI   R16, 8        ;set counter for receiving 8 bits
    CLR   R24           ;clear data register
    ;-------------------------------------------------------
w4: SBIS  PIND, 7
    RJMP  w4            ;detect data bit (high pulse)
    RCALL delay_timer0  ;wait 50us & then check bit value
    ;-------------------------------------------------------
    SBIS  PIND, 7       ;if received bit=1, skip next inst
    RJMP  skp           ;else, received bit=0, jump to skp
    SEC                 ;set carry flag (C=1)
    ROL   R24           ;shift in 1 into LSB data register
    RJMP  w5            ;jump & wait for low pulse
skp:LSL   R24           ;shift in 0 into LSB data register
    ;-------------------------------------------------------
w5: SBIC  PIND, 7
    RJMP  w5            ;wait for DHT11 low pulse
    ;-------------------------------------------------------
    DEC   R16           ;decrement counter
    BRNE  w4            ;go back & detect next bit
    RET                 ;return to calling subroutine

;===============================================================
;MAX7219 subroutines
;===============================================================
SPI_MAX7219_init:
;----------------
.equ  SCK, 5
.equ  MOSI, 3
.equ  SS, 2
;--------------------------------------------------------------
      LDI   R17, (1<<MOSI)|(1<<SCK)|(1<<SS)
      OUT   DDRB, R17       ;set MOSI, SCK, SS as o/p
      ;--------------------------------------------------------
      LDI   R17, (1<<SPIE)|(1<<SPE)|(1<<MSTR)|(1<<SPR0)
      OUT   SPCR, R17       ;enable SPI as master, fsck=fosc/16
      ;--------------------------------------------------------
      LDI   R17, 0x0A       ;set segment intensity (0 to 15)
      LDI   R18, 8          ;intensity level = 8
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x09       ;set decoding mode command
      LDI   R18, 0b01100011 ;decoding byte
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x0B       ;set scan limit command
      LDI   R18, 0x07       ;8 digits connected to MAX7219
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x0C       ;set turn ON/OFF command
      LDI   R18, 0x01       ;turn ON MAX7219
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      RET
;==============================================================
MAX7219_disp_text:
;-----------------
      LDI   R17, 0x08       ;select digit 7
      LDI   R18, 0x0F       ;data = t
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x05       ;select digit 4
      LDI   R18, 0x4E       ;data = C
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x04       ;select digit 3
      LDI   R18, 0x00       ;data = space
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x03       ;select digit 2
      LDI   R18, 0x17       ;data = h
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      RET
;==============================================================
send_bytes:
      CBI   PORTB, SS       ;enable slave device MAX7219
      OUT   SPDR, R17       ;transmit command
      ;--------------------------------------------------------
ll2:  IN    R19, SPSR
      SBRS  R19, SPIF       ;wait for byte transmission
      RJMP  ll2             ;to complete
      ;--------------------------------------------------------
      OUT   SPDR, R18       ;transmit data
      ;--------------------------------------------------------
ll3:  IN    R19, SPSR
      SBRS  R19, SPIF       ;wait for byte transmission
      RJMP  ll3             ;to complete
      ;--------------------------------------------------------
      SBI   PORTB, SS       ;disable slave device MAX7219
      RET
;==============================================================
binary2decimal:
;--------------
      CLR   R26             ;set counter1, initial value 0
      CLR   R27             ;set counter2, initial value 0
      ;--------------------------------------------------------
l70:  CPI   R28, 100        ;compare R28 with 100
Ret:  BRMI  l80             ;jump when R28 < 100
      INC   R26             ;increment counter1 by 1
      SUBI  R28, 100        ;R28 = R28 - 100
      RJMP  l70
      ;--------------------------------------------------------
l80:  CPI   R28, 10         ;compare R28 with 10
      BRMI  dsp             ;jump when R28 < 10
      INC   R27             ;increment counter2 by 1
      SUBI  R28, 10         ;R28 = R28 - 10
      RJMP  l80
      ;--------------------------------------------------------  
dsp:  MOV   R18, R27
      MOV   R17, R29        ;select digit
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      MOV   R18, R28
      MOV   R17, R30        ;select digit
      RCALL send_bytes      ;send command & data to MAX7219    
      ;--------------------------------------------------------
      RET

;===============================================================
;Servo Code Updated
;===============================================================
servo_motor:
;-----------
    ;Inisialisasi Servo
    ; SBI   DDRB, 4         ;pin PB4 o/p for servo control
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

bak:RCALL delay_ms        ;0.5s d