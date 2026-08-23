;saqknewline.asm, usage: %include saqlib/saqknewline.asm
;to make a newline, call this function, registers in use: ah, al



saqknewline:
    mov ah, 0x0E
    mov al, 0x0D 
    int 0x10

    mov al, 0x0A
    int 0x10

    ret