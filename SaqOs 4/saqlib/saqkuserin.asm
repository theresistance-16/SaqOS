;saqkuserin.asm Usage: %include "saqlib/saqkuserin.asm"
;this function waits for user input, and puts the user entered bytes into bx. So makesure to mov a variable that has free bytes inside bx, else this wont work!
;this function also prints the user typed letter to screen and checks and handles either, space, enter or backspace for you also
;so for example, the user hits enter after typing something so this happens:
;it makes a newline and sets al to 0x0D so you can cmp it to 0x0D to replace it with a 0 so then you can cmp the user entered string with cmpstr
;the proccess is similar to backspace and space
;keep in mind, userin will also null terminate the string for you if enter gets pressed so you can instantly cmpstr with the hardcoded string


;how enter exaclty works:
;after executing userin, cmp di with 0 to check (je) if user hit enter so then you can je to a label, that compares (cmpstr) bx with your desired string.
;also, a newline will be automatically made for you so you can directly use kprint to print a string back
;we will also null terminate the user entered string inside bx

;back space and space will be handeled inside the function and the function will work until enter gets hit and it will ret

;again, the usertyped bytes goes into bx, which means you have to move a desired variable into bx

;IMPORTANT: You NEED to move your buffer into bx AND si in order for this func to work so for example: mov si, your_buff and move bx, your_buff
;and then: call saqkuserin
;also dont forget to draw a cursor before waiting for input :)


saqkuserin:
    mov ah, 0x00
    int 0x16
    mov [bx], al

    cmp al, 0x0D ;carriage return (enter)
    je .enter

    cmp al, 0x08
    je .backspace

    cmp al, 0x20
    je .space

    inc bx

    mov ah, 0x0E
    int 0x10 ;we print the user typed letter on display

    jmp saqkuserin

.enter:
    ;we need to write logic so if its enter, it jmps to a compare 
    mov di, 0 ;The signal code if enter got pressed (which it did when it jmps here)

    mov ah, 0x0E ;make spacings/newline
    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    mov byte [bx], 0 ;user entered 0x0D got replaced with null
    ret

.backspace:
    ;so lets assume the caller (me) read the top documentation and actually moves the buffer into si, then we can compare bx (the advaced buffer) to the fresh buffer (si)
    cmp bx, si
    jle saqkuserin ;we dont want to backspace the prompt away, so we compare if bx is at 0 or less, if it is it just jmps back to userin
    ;else
    mov ah, 0x0E
    mov al, 0x08
    int 0x10 ;cursor went one left (under the letter we want to delete)

    mov al, 0x20 ;mov white space into al
    int 0x10 ;remove the charecter on display

    ;the cursor went one right, we move it back

    mov al, 0x08
    int 0x10

    dec bx ;we move the ptr one left, where the deleted letter will be and it wont point at the actual back space anymore

    mov byte [bx], 0 ;over write the letter with a 0

    jmp saqkuserin

    ;now the 0x08 does stay at the very right, but it gets ignored and almost certainly reset when comparing
.space:
    mov ah, 0x0E
    mov al, 0x20
    int 0x10 ;cursor moved one right
    inc bx ;now the pointer skipped one block also!
    jmp saqkuserin
