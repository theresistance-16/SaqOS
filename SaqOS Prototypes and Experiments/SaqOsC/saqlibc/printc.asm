BITS 16

global printc 

printc:
   push bp
   mov bp, sp
   push si

   mov si, [bp + 4]
   mov ah, 0x0E
   jmp print

print:
    
    mov al, [si]
    cmp al, 0
    je .done 
    int 0x10
    inc si
    jmp print

.done:
    pop si
    pop bp 
    ret