```asm
;===============================================================================
; @file       G6_TPL3_ED2.asm
;
; @author     Conde_Ana_Victoria
;             Goicoechea_Emilia
;             Lauc_Mirko
;             Lurgo_Donato
;             Bertalot_Renata
;
; @date       7/9/2026
;
; @version    1.0
;===============================================================================

;===============================================================================
; DIRECTIVAS DE INCLUSIÓN
;===============================================================================
    LIST P=16F887
    #include "p16f887.inc"

;===============================================================================
; CONFIGURACIÓN GENERAL DEL MCU
;===============================================================================
    __CONFIG _CONFIG1, _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF

;===============================================================================
; DEFINICIÓN DE CONSTANTES
;===============================================================================
    #DEFINE CTRL_DSPL_1 PORTC,RC0
    #DEFINE CTRL_DSPL_2 PORTC,RC1
    #DEFINE CTRL_DSPL_3 PORTC,RC2

;===============================================================================
; DEFINICIÓN DE VARIABLES
;===============================================================================
    CBLOCK 0x20
        DELAY1_Init
        DELAY2_Init
        DELAY3_Init

        DELAY1
        DELAY2
        DELAY3

        DATA_DSPL_1
        DATA_DSPL_2
        DATA_DSPL_3

        COUNTER_DSPL
        COUNTER_SEGMENTS
    ENDC

;===============================================================================
; DECLARACIÓN DE MACROS PARA CONFIGURACIÓN DE REGISTROS
;===============================================================================

;-------------------------------------------------------------------------------
; Configuración de displays
;-------------------------------------------------------------------------------
CFG_DSPL MACRO
        ; Banco 3: configuración digital
        BSF     STATUS,RP0
        BSF     STATUS,RP1
        CLRF    ANSEL
        CLRF    ANSELH

        ; Banco 1: RC0, RC1 y RC2 como salidas
        BSF     STATUS,RP0
        BCF     STATUS,RP1
        BCF     TRISC,TRISC0
        BCF     TRISC,TRISC1
        BCF     TRISC,TRISC2

        ; Banco 0
        BCF     STATUS,RP0
        BCF     STATUS,RP1

        ; Estados iniciales
        BCF     CTRL_DSPL_1
        BCF     CTRL_DSPL_2
        BCF     CTRL_DSPL_3

        ; Datos correspondientes al Grupo 6
        MOVLW   D'10'
        MOVWF   DATA_DSPL_1

        MOVLW   D'0'
        MOVWF   DATA_DSPL_2

        MOVLW   D'6'
        MOVWF   DATA_DSPL_3
    ENDM

;-------------------------------------------------------------------------------
; Configuración del PORTD como salida
;-------------------------------------------------------------------------------
CFG_DIGITS_DSPL MACRO
        BSF     STATUS,RP0
        BCF     STATUS,RP1
        CLRF    TRISD

        BCF     STATUS,RP0
        BCF     STATUS,RP1
        CLRF    PORTD
    ENDM

;-------------------------------------------------------------------------------
; Apaga todos los segmentos
;-------------------------------------------------------------------------------
DSPL_ALL_OFF MACRO
        BCF     STATUS,RP0
        BCF     STATUS,RP1
        CLRF    PORTD
    ENDM

;-------------------------------------------------------------------------------
; Enciende todos los segmentos
;-------------------------------------------------------------------------------
DSPL_ALL_ON MACRO
        BCF     STATUS,RP0
        BCF     STATUS,RP1

        BSF     PORTD,RD0
        BSF     PORTD,RD1
        BSF     PORTD,RD2
        BSF     PORTD,RD3
        BSF     PORTD,RD4
        BSF     PORTD,RD5
        BSF     PORTD,RD6
    ENDM

;-------------------------------------------------------------------------------
; Delay aproximado de 2 ms
;-------------------------------------------------------------------------------
CFG_DELAY_2ms MACRO
        MOVLW   D'1'
        MOVWF   DELAY1_Init

        MOVLW   D'45'
        MOVWF   DELAY2_Init

        MOVLW   D'15'
        MOVWF   DELAY3_Init
    ENDM

;-------------------------------------------------------------------------------
; Delay aproximado de 300 ms
;-------------------------------------------------------------------------------
CFG_DELAY_300ms MACRO
        MOVLW   D'3'
        MOVWF   DELAY1_Init

        MOVLW   D'248'
        MOVWF   DELAY2_Init

        MOVLW   D'133'
        MOVWF   DELAY3_Init
    ENDM

;-------------------------------------------------------------------------------
; Delay aproximado de 1 s
;-------------------------------------------------------------------------------
CFG_DELAY_1s MACRO
        MOVLW   D'10'
        MOVWF   DELAY1_Init

        MOVLW   D'248'
        MOVWF   DELAY2_Init

        MOVLW   D'133'
        MOVWF   DELAY3_Init
    ENDM

;===============================================================================
; INICIALIZACIÓN DEL MCU
;===============================================================================
    ORG     0x00
    GOTO    INICIO

    ORG     0x05

;===============================================================================
; INICIO
;===============================================================================
INICIO
        ; Configuración de puertos
        CFG_DSPL
        CFG_DIGITS_DSPL

        ; Inicialización del contador
        CALL    RST_COUNTER_DSPL

        ; Testeo inicial de displays
        CALL    TEST_DSPL

        ; Delay utilizado para el multiplexado
        CFG_DELAY_2ms

;===============================================================================
; PROGRAMA PRINCIPAL
;===============================================================================
MAIN_LOOP
        CALL    MUX_DSPL
        GOTO    MAIN_LOOP

;===============================================================================
; SUBRUTINA DE DELAY
;===============================================================================
; @brief
;       Retardo mediante tres bucles anidados.
;
;===============================================================================
DELAY_3LOOP
        MOVFW   DELAY1_Init
        MOVWF   DELAY1

LOOP1
        MOVFW   DELAY2_Init
        MOVWF   DELAY2

LOOP2
        MOVFW   DELAY3_Init
        MOVWF   DELAY3

LOOP3
        DECFSZ  DELAY3,F
        GOTO    LOOP3

        DECFSZ  DELAY2,F
        GOTO    LOOP2

        DECFSZ  DELAY1,F
        GOTO    LOOP1

        RETURN

;===============================================================================
; RESET DEL CONTADOR DE DISPLAY
;===============================================================================
RST_COUNTER_DSPL
        MOVLW   D'3'
        MOVWF   COUNTER_DSPL
        RETURN

;===============================================================================
; DECREMENTO DEL CONTADOR DE DISPLAY
;===============================================================================
DECF_COUNTER_DSPL
        DECF    COUNTER_DSPL,F
        RETURN

;===============================================================================
; MULTIPLEXADO DE DISPLAYS
;===============================================================================
MUX_DSPL
        ; Delay entre actualizaciones
        CALL    DELAY_3LOOP

        ; ¿COUNTER_DSPL = 3?
        MOVLW   D'3'
        SUBWF   COUNTER_DSPL,W
        BTFSC   STATUS,Z
        GOTO    UPDATE_DSPL_3

        ; ¿COUNTER_DSPL = 2?
        MOVLW   D'2'
        SUBWF   COUNTER_DSPL,W
        BTFSC   STATUS,Z
        GOTO    UPDATE_DSPL_2

        ; ¿COUNTER_DSPL = 1?
        MOVLW   D'1'
        SUBWF   COUNTER_DSPL,W
        BTFSC   STATUS,Z
        GOTO    UPDATE_DSPL_1

        ; Si el contador llegó a 0, reiniciarlo
        CALL    RST_COUNTER_DSPL
        RETURN

;===============================================================================
; ACTUALIZACIÓN DISPLAY 1
;===============================================================================
UPDATE_DSPL_1
        MOVF    DATA_DSPL_1,W
        CALL    TABLE_DECO_DSPL_CC
        MOVWF   PORTD

        MOVF    COUNTER_DSPL,W
        CALL    TABLE_CTRL_DSPL_CC
        MOVWF   PORTC

        CALL    DECF_COUNTER_DSPL
        RETURN

;===============================================================================
; ACTUALIZACIÓN DISPLAY 2
;===============================================================================
UPDATE_DSPL_2
        MOVF    DATA_DSPL_2,W
        CALL    TABLE_DECO_DSPL_CC
        MOVWF   PORTD

        MOVF    COUNTER_DSPL,W
        CALL    TABLE_CTRL_DSPL_CC
        MOVWF   PORTC

        CALL    DECF_COUNTER_DSPL
        RETURN

;===============================================================================
; ACTUALIZACIÓN DISPLAY 3
;===============================================================================
UPDATE_DSPL_3
        MOVF    DATA_DSPL_3,W
        CALL    TABLE_DECO_DSPL_CC
        MOVWF   PORTD

        MOVF    COUNTER_DSPL,W
        CALL    TABLE_CTRL_DSPL_CC
        MOVWF   PORTC

        CALL    DECF_COUNTER_DSPL
        RETURN

;===============================================================================
; TEST DE DISPLAYS
;===============================================================================
; @brief
;       Enciende los segmentos uno a uno para cada display.
;       Luego enciende y apaga todos los segmentos.
;
;===============================================================================
TEST_DSPL
        CALL    RST_COUNTER_DSPL

LOOP_TEST_DSPL
        ; Selecciona display
        MOVF    COUNTER_DSPL,W
        CALL    TABLE_CTRL_DSPL_CC
        MOVWF   PORTC

        ; Apaga todos los segmentos
        DSPL_ALL_OFF

        ; Delay inicial
        CFG_DELAY_300ms
        CALL    DELAY_3LOOP

        ; Comienza con el segmento A
        MOVLW   B'00000001'
        MOVWF   PORTD

        MOVLW   D'7'
        MOVWF   COUNTER_SEGMENTS

LOOP_TEST_SEGMENT
        ; Espera
        CALL    DELAY_3LOOP

        ; Desplaza el segmento hacia la izquierda
        BCF     STATUS,C
        RLF     PORTD,F

        DECFSZ  COUNTER_SEGMENTS,F
        GOTO    LOOP_TEST_SEGMENT

        ; Enciende todos los segmentos
        DSPL_ALL_ON

        ; Espera 2 segundos aproximadamente
        CFG_DELAY_1s
        CALL    DELAY_3LOOP

        CFG_DELAY_1s
        CALL    DELAY_3LOOP

        ; Apaga todos los segmentos
        DSPL_ALL_OFF

        CFG_DELAY_1s
        CALL    DELAY_3LOOP

        CFG_DELAY_1s
        CALL    DELAY_3LOOP

        ; Cambia de display
        DECFSZ  COUNTER_DSPL,F
        GOTO    LOOP_TEST_DSPL

        ; Reinicia contador
        CALL    RST_COUNTER_DSPL

        RETURN

;===============================================================================
; TABLA LUT - DECODIFICACIÓN CÁTODO COMÚN
;===============================================================================
;
;        RD7 RD6 RD5 RD4 RD3 RD2 RD1 RD0
;         dp  g   f   e   d   c   b   a
;
;  0     00 11 11 11 11 11 11   -> 3Fh
;  1     00 00 00 00 00 11 11 0 -> 06h
;  2     01 01 10 11 11 0  11  -> 5Bh
;  3     01 00 10 01 11 11 11  -> 4Fh
;  4     01 10 01 10 01 10 0   -> 66h
;  5     01 10 11 01 10 11 01  -> 6Dh
;  6     01 11 11 01 11 11 01  -> 7Dh
;  7     00 00 00 00 00 11 11 1 -> 07h
;  8     01 11 11 11 11 11 11  -> 7Fh
;  9     01 10 11 11 10 11 11  -> 67h
;  A     01 10 11 11 01 11 11  -> 6Fh
;
;===============================================================================
    ORG     0x0080

TABLE_DECO_DSPL_CC
        ADDWF   PCL,F

        RETLW   B'00111111'     ; 0
        RETLW   B'00000110'     ; 1
        RETLW   B'01011011'     ; 2
        RETLW   B'01001111'     ; 3
        RETLW   B'01100110'     ; 4
        RETLW   B'01101101'     ; 5
        RETLW   B'01111101'     ; 6
        RETLW   B'00000111'     ; 7
        RETLW   B'01111111'     ; 8
        RETLW   B'01100111'     ; 9
        RETLW   B'01101111'     ; A

;===============================================================================
; TABLA DE CONTROL DE DISPLAYS
;===============================================================================
;
; COUNTER = 0 -> ninguno
; COUNTER = 1 -> RC0
; COUNTER = 2 -> RC1
; COUNTER = 3 -> RC2
;
;===============================================================================
TABLE_CTRL_DSPL_CC
        ADDWF   PCL,F

        RETLW   B'00000000'
        RETLW   B'00000001'
        RETLW   B'00000010'
        RETLW   B'00000100'

;===============================================================================
    END
;===============================================================================
```
