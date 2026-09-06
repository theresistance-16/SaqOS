;saqkcmpstr.asm, usage: %include "saqlib/saqkcmpstr.asm"
;To compare two strings, mov one Null terminated string into bx and another  Null terminated string into si
;Then, your string inside Si will beloaded in al, and the one inside bx will be loaded in ah, both al and ah will be compared
;When the string is equal, the number 0 will be loaded into register al, when its not equal, the number 1 will be loaded into al.
;So after calling, compare al to 1, and je to your other fallback label and before you saqkstrcmp again, make sure to mov the 
;cmp al to 0, je to the label that prints your command with kprint


;IMPORTANT: Before calling this function, move your string (or user buffer) into bx and another string into si, doesnt matter where
;but both strings need to be in si and bx, so lets say: mov bx, userbuffer and then mov si, hardcodedstring to cmp to userbuffer and then:
;call saqkcmpstr 
;after call saqkcmpstr do:
;cmp al, 1 (not equal)
;je check_other_command 
;cmp al, 0 (equal)
;je print_command


saqkcmpstr:
    mov al, [si]
    mov ah, [bx]
    cmp al, ah
    jne .notequ
    cmp al, 0
    je .equal
    inc si
    inc bx
    jmp saqkcmpstr

.notequ:
    mov al, 1
    ret

.equal:
    mov al, 0
    ret
