bits 16
org 0x7c00

setup:
    cli
    xor ax, ax
    xor bp, bp
    xor bx, bx
    xor si, si
    xor ah, ah
    xor al, al
    mov ds, bx
    mov ss, bx
    mov es, bx
    mov sp, 0x7c00
    sti ;register init

    mov bx, buffer ;we move our input buffer in bx
    mov si, msg ;our welcome msg goes into si
    mov bp, exitmsg ;our exitmsg goes into bp
    jmp start_tty


start_tty:
    mov ah, 0x0E ;enable tty
    jmp print_welcome ;jmp down

print_welcome:
    
    mov al, [si] ;mov the contents of si inside al so int 0x10 prints to screen
    int 0x10 ;first byte on screen

    cmp al, 0 ;check if al reached null

    je saqshellsetup ;we jump to saqshellsetup because we need to drop down two lines and enable waiting for a keyboard press

    inc si ;inc dx so next byte goes into al

    jmp print_welcome


saqshellsetup:
    mov al, 0x0D ;0x0D makes the cursor go very left
    int 0x10
    mov al, 0x0A ;0x0A makes a new line, cursor stays at very left
    int 0x10
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    mov al, '>' ;print cursor
    int 0x10
    mov al, 0x20 ;make a space
    int 0x10
    jmp saqshell

    


saqshell:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D ;check if user pressed enter
    je handle_enter
    cmp al, 0x08 ;check if user pressed backspace
    je handle_backspc
    cmp al, 0x1B ;check if user pressed escape
    je spaces

    jmp move_letter_to_screen ;else we jump to moving the letters inside al to screen and inc bx for next letter


handle_enter:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10

    mov al, '>' ;rewrite the cursor on new line
    int 0x10
    mov al, 0x20
    int 0x10

    mov bx, buffer ;we make bx start pointing at the beginning, so we dont get a buffer overflow (the letters still stay on panel) 
    jmp saqshell

handle_backspc:
    mov ax, buffer
    cmp ax, bx ;compare ax with bx
    jle saqshell ;if bx is same or less than ax, the user is trying to delete my cursor!
    mov ah, 0x0E ;switch to tty quickly
    mov al, 0x08 
    int 0x10 ;move cursor one left
    mov al, ' ' ;we overwrite the byte with nothing
    int 0x10 ;great we overwritten the byte, but our cursor went one right, we gotta go one left
    mov al, 0x08
    int 0x10 ;good, our cursor is now at the empty space, but the byte itself is still in bx so we remove itself

    dec bx ;go one back
    mov byte [bx], 0 ;good we overwritten the misstyped byte with 0 
    jmp saqshell


spaces:
    mov ah, 0x0E

    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    jmp escape

escape:



    mov al, [bp]
    int 0x10

    cmp al, 0
    je halt_cpu

    inc bp ;holy, i forgot to inc bp but incremented cx instead, the cpu went nuts

    jmp escape

halt_cpu:
    cli
    hlt
    

move_letter_to_screen:
    ;i fully forgot about this label lol
    mov ah, 0x0E ;set tty mode again
    mov [bx], al ;move the byte inside al to bx
    int 0x10 ;send the byte to screen
    inc bx ;inc bx so the next byte has the space
    jmp saqshell
;data section

buffer: times 60 db 0

msg db "Welcome to SaqOs Bootloader! Initialized registers: bx, dx, ah, al, ds, ss, es, sp, ax (lol i made some mistakes in the code and nope, theyre not all the registers). press esc to hlt cpu", 0

exitmsg db "See you soon! Halting Cpu...", 0

times 510 - ($ - $$) db 0
db 0x55, 0xAA

