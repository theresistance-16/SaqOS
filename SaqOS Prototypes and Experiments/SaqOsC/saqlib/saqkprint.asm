;saqkprint.asm, usage: %include/saqlib/saqkprint.asm
;To print a string to the display, mov your null terminated string into si.
;Then, your string in SI will be loaded into AL and then using int 0x10 getting printed on display.
;then call saqkprint
;Keep in mind saqkprint doesnt make newlines for you, so you have to call saqknewline


saqkprint:
    pusha ;push all registers on stack
    mov ah, 0x0E
    jmp .print

.print:
    mov al, [si]
    cmp al, 0
    je .done
    int 0x10
    inc SI
    jmp .print

.done:
    popa ;pop all registers back in
    ret