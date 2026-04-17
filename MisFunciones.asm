; ============================================================
; MisFunciones.asm
; ============================================================

.686
.model flat, c

.code

; ------------------------------------------------------------
; Mi_pow: Calcula x elevado a la potencia y (x^y)
; ------------------------------------------------------------
Mi_pow PROC
    ; --- Configuración inicial de la pila ---
    PUSH    EBP                     ; Guarda el puntero base anterior
    MOV     EBP, ESP                ; Establece el nuevo puntero base para esta función

    ; 1. Cargar los números a la calculadora (FPU)
    FLD     QWORD PTR [EBP+16]      ; Mete "y" (exponente) a la pila: ST(0) = y
    FLD     QWORD PTR [EBP+8]       ; Mete "x" (base) a la pila: ST(0) = x, ST(1) = y

    ; 2. Aplicar logaritmo para resolver la potencia
    ; La instrucción FYL2X hace: y * log2(x)
    FYL2X                           ; El resultado queda en ST(0)

    ; 3. Separar el número en Parte Entera y Parte Fraccionaria
    ; Esto se hace porque la función de potencia (F2XM1) solo acepta [-1,1].
    FLD     ST(0)                   ; Duplica el resultado actual
    FRNDINT                         ; Redondea a entero: ST(0) = parte_entera
    FSUB    ST(1), ST(0)            ; Resta el entero al total: ST(1) = parte_fraccionaria
    
    ; 4. Calcular 2 elevado a la parte fraccionaria
    FXCH    ST(1)                   ; Intercambia: ST(0) = fraccion, ST(1) = entero
    F2XM1                           ; Calcula (2^fraccion) - 1
    FLD1                            ; Carga un 1 constante
    FADDP   ST(1), ST(0)            ; Suma el 1: ST(0) = 2^fraccion

    ; 5. Aplicar la parte entera (Escalado)
    ; Multiplica (2^fraccion) por (2^entero) para obtener el resultado final
    FSCALE                          ; ST(0) = ST(0) * 2^ST(1)

    ; 6. Limpieza y salida
    FSTP    ST(1)                   ; Saca el valor entero que ya no necesitamos

    ; El resultado final se queda en ST(0) para que C/C++ lo reciba
    MOV     ESP, EBP                ; Restaura el puntero de la pila
    POP     EBP                     ; Restaura el puntero base
    RET                             ; Regresa al programa principal
Mi_pow ENDP


; ------------------------------------------------------------
; Mi_sqrt: Calcula la raiz cuadrada de x (x^(1/2))
; ------------------------------------------------------------
Mi_sqrt PROC
    ; --- Configuración inicial de la pila ---
    PUSH    EBP                     ; Guarda el puntero base anterior
    MOV     EBP, ESP                ; Establece el nuevo puntero base para esta función

    ; 1. Cargar el número
    FLD     QWORD PTR [EBP+8]       ; Mete "x" a la pila: ST(0) = x

    ; 2. Calcular la raíz cuadrada directamente
    ; La instrucción FSQRT hace: x ^ (1/2)
    FSQRT                           ; ST(0) = sqrt(x)

    ; 3. Limpieza y salida
    MOV     ESP, EBP                ; Restaura el puntero de la pila
    POP     EBP                     ; Restaura el puntero base
    RET                             ; Regresa al programa principal
Mi_sqrt ENDP

; ------------------------------------------------------------
; Mi_fact: Calcula el factorial de x (x!)
; ------------------------------------------------------------
Mi_fact PROC
    ; --- Configuración inicial de la pila ---
    PUSH    EBP                     ; Guarda el puntero base anterior
    MOV     EBP, ESP                ; Establece el nuevo puntero base para esta función

    ; 1. Cargar x y preparar x-1
    FLD     QWORD PTR [EBP+8]       ; ST(0) = x
    FLD     ST(0)                   ; ST(0) = x,    ST(1) = x
    FLD1                            ; ST(0) = 1.0
    FSUBP   ST(1), ST(0)            ; ST(0) = x-1,  ST(1) = x

    ; --- Si ST(0) <= 0 devuelve 1.0 directamente ---
    FLDZ                            ; ST(0) = 0.0
    FCOMIP  ST(0), ST(1)            ; Compara 0.0 con ST(0) entonces pop ST(0)
    JNB     resultado               ; Si x <= 1 saltar a la etiqueta "resultado"

    ; 2. Se crea un bucle con la siguiente consideración:
    ; ST(0) = Originalmente sera x-1, durante el bucle se convierte en el contador
    ; ST(1) = Originalmente sera x,   durante el bucle se convierte en el acumulador
bucle:
    FMUL    ST(1), ST(0)            ; ST(1) = acumulador * contador
    FLD1                            ; ST(0) = 1.0
    FSUBP   ST(1), ST(0)            ; ST(0) = contador - 1

    ; 2.1 El bucle se ejecutara de manera indefinida hasta que ST(0) == 1
    FLD1                            ; ST(0) = 1.0,  ST(1) = contador
    FCOMIP  ST(0), ST(1)            ; Compara 1.0 con contador, pop ST(0) automaticamente
                                    ; ST(0) = contador
    JA      bucle                   ; Si contador > 1 saltar a la etiqueta "bucle"

resultado:
    ; 3. Limpieza: descarta el contador, deja solo el resultado
    FSTP    ST(0)                   ; Descarta el contador, ST(0) = x!

    MOV     ESP, EBP                ; Restaura el puntero de la pila
    POP     EBP                     ; Restaura el puntero base
    RET                             ; Regresa al programa principal
Mi_fact ENDP

END