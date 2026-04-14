; ============================================================
; MisFunciones.asm
; ============================================================

.686
.model flat, c

.code

; ------------------------------------------------------------
; MiPow: Calcula x elevado a la potencia y (x^y)
; ------------------------------------------------------------
MiPow PROC
    ; --- Configuración inicial de la pila ---
    PUSH    EBP                     ; Guarda el puntero base anterior
    MOV     EBP, ESP                ; Establece el nuevo puntero base para esta función

    ; 1. Cargar los números a la calculadora (FPU)
    FLD     QWORD PTR [EBP+16]     ; Mete "y" (exponente) a la pila: ST(0) = y
    FLD     QWORD PTR [EBP+8]      ; Mete "x" (base) a la pila: ST(0) = x, ST(1) = y

    ; 2. Aplicar logaritmo para resolver la potencia
    ; La instrucción FYL2X hace: y * log2(x)
    FYL2X                          ; El resultado queda en ST(0)

    ; 3. Separar el número en Parte Entera y Parte Fraccionaria
    ; Esto se hace porque la función de potencia (F2XM1) solo acepta [-1,1].
    FLD     ST(0)                  ; Duplica el resultado actual
    FRNDINT                        ; Redondea a entero: ST(0) = parte_entera
    FSUB    ST(1), ST(0)           ; Resta el entero al total: ST(1) = parte_fraccionaria
    
    ; 4. Calcular 2 elevado a la parte fraccionaria
    FXCH    ST(1)                  ; Intercambia: ST(0) = fraccion, ST(1) = entero
    F2XM1                          ; Calcula (2^fraccion) - 1
    FLD1                           ; Carga un 1 constante
    FADDP   ST(1), ST(0)           ; Suma el 1: ST(0) = 2^fraccion

    ; 5. Aplicar la parte entera (Escalado)
    ; Multiplica (2^fraccion) por (2^entero) para obtener el resultado final
    FSCALE                         ; ST(0) = ST(0) * 2^ST(1)

    ; 6. Limpieza y salida
    FSTP    ST(1)                  ; Saca el valor entero que ya no necesitamos

    ; El resultado final se queda en ST(0) para que C/C++ lo reciba
    MOV     ESP, EBP                ; Restaura el puntero de la pila
    POP     EBP                     ; Restaura el puntero base
    RET                             ; Regresa al programa principal
MiPow ENDP

END