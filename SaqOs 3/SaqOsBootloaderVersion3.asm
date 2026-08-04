bits 16
org 0x7c00

;register  and msg setup
registers:
    cli
    xor ax, ax
    xor al, al
    xor ah, ah
    xor bx, bx
    xor di, di
    xor si, si
    xor bp, bp

    mov es, bx
    mov ss, bx
    mov ds, bx

    mov sp, 0x7C00
    mov ax, 0x0000
    mov ss, ax

    sti

    mov bx, welcome

    jmp tty_setup



tty_setup:

    mov ah, 0x0E ;video service
    jmp welcom_msg



welcom_msg:
    mov al, [bx]
    
    cmp al, 0
    je spacing_before_ask

    int 0x10
    inc bx

    jmp welcom_msg

spacing_before_ask:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    ;should look clean now

    jmp ask_setup

ask_setup:

    mov ah, 0x0E ;just in case

    mov bx, ask_for_y

    jmp ask




ask:
    ;ah is still 0x0E, need to change bx to ask_for_y
    mov al, [bx]
    

    cmp al, 0
    je wait_for_input

    int 0x10
    inc bx

    jmp ask



wait_for_input:
    mov ah, 0x00
    int 0x16

    cmp al, 'y' ;if we dont check for an enter, and if we only get ONE letter (either y/n) it should directly boot to kernel or halt
    je mov_letter_to_screen_setup

    CMP AL, 'n'
    JE mov_letter_to_screen_setup

    jmp wrong_anwser_setup

    ;yeah i wont write backspace or enter logic in this version, too much work at the moment, and if backspace dont exist, he cant remove the asking msg

mov_letter_to_screen_setup:
    MOV AH, 0x0E
    JMP mov_letter_to_screen
    

mov_letter_to_screen:
    int 0x10 ;n or y should be on display

    cmp al, 'n'
    je n_msg_setup

    cmp al, 'y'
    je boot_to_kernel_setup

    jmp wrong_anwser_setup

boot_to_kernel_setup:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    mov si, boot_msg

    JMP boot_kernel_msg_print

boot_kernel_msg_print: ;I NEED TO WRITE A DAMN LIBRARY! I CANT ALWAYS WRITE INT 0x10 int 0x10 intx kiqfporoqjiwrf, well, will happen in version 4 :)
    mov al, [si]
    cmp al, 0
    JE boot_to_kernel
    
    int 0x10
    inc si

    JMP boot_kernel_msg_print

boot_to_kernel: 
    mov ax, 0x1000
    mov es, ax
    mov bx, 0x0000

    mov ah, 0x02 ;read from disk

    mov al, 4 ;read sector 4 (the kernel maybe?)

    mov ch, 0 ;cylinder 0, whatever that is

    mov dh, 0 ;head 0, also dont know what that is

    mov cl, 2 ;sector 2, sector one was our bootloader? idk 

    int 0x13 ;bios now copies the sector that the kernel is in to ram at address 0x1000:0x0000

    JMP 0x1000:0x0000 ;that goes to our kernel that loaded in ram


wrong_anwser_setup:
    mov ah, 0x0E ;do we make a new line??? 

    mov al, 0x0D
    int 0x10 ;yes we make a new line

    mov al, 0x0A
    int 0x10

    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10 ;twice

    mov si, wrong
    jmp wrong_anwser
    
wrong_anwser:
    mov al, [si]

    cmp al, 0
    je halt

    int 0x10
    inc si 
    JMP wrong_anwser
    

n_msg_setup:
    mov ah, 0x0E ;do we make a newline for n msg?????????????????
    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10 ;i guess we do make a newline


    mov si, msg_for_n

    jmp n_msg

n_msg:
    mov al, [si] 
    cmp al, 0
    je halt

    int 0x10

    inc si

    jmp n_msg


halt:
    cli
    hlt


msg_for_n db "Its safe to poweroff your pc now!", 0
boot_msg db "Booting SaqKernel...", 0
wrong db "Please Type either y to boot into saqos or n to halt cpu!", 0
welcome db "Welcome to SaqOs Bootloader Version 3!", 0
ask_for_y db "Do you want to boot into SaqOs? Y/n> ", 0

times 510 - ($ - $$) db 0
db 0x55
db 0xAA
;gosh i really need to write my own libraries so i dont need to write the same code for millions of times
