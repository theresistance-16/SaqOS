bits 16
org 0x7c00

setup:
    cli
    xor cx, cx
    xor bx, bx
    xor dx, dx
    xor ah, ah
    xor al, al
    mov ds, bx
    mov ss, bx
    mov es, bx
    mov sp, 0x7c00
    sti ;register init

    mov bx, buffer ;we move our input buffer in bx
    mov dx, msg ;our welcome msg goes into dx
    mov cx, exitmsg ;our exitmsg goes into cx
    jmp start_tty


start_tty:
    mov ah, 0x0E ;enable tty
    jmp print_welcome ;jmp down

print_welcome:
    
    mov al, [dx] ;mov the contents of dx inside al so int 0x10 prints to screen
    int 0x10 ;first byte on screen

    cmp al, 0 ;check if al reached null

    je saqshellsetup ;we jump to saqshellsetup because we need to drop down two lines and enable waiting for a keyboard press

    inc dx ;inc dx so next byte goes into al

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
    je escape

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

escape:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    mov al, 0x0D
    int 0x10
    
    mov al, 0x0A
    int 0x10

    mov al, [cx]
    int 0x10

    cmp al, 0
    je halt_cpu

    inc cx

    jmp escape

halt_cpu:
    cli
    hlt
    


;data section

buffer: times 128 db 0

msg db "Welcome to SaqOs Bootloader! Initialized registers: bx, dx, ah, al, ds, ss, es, sp. press esc to hlt cpu", 0

exitmsg db "See you soon! Halting Cpu...", 0

times 510 - ($ - $$) db 0
db 0x55, 0xAA

