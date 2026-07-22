bits 16
org 0x7c00


setup_registers:
    cli
    xor al, al ;we mov msg byte by byte 
    xor ah, ah ;here we store bios tty address 0x0E
    xor bx, bx ;this register stores our msg

    ;we need segment registers too

    mov es, bx
    mov ss, bx
    mov ds, bx

    mov bx, msg

    sti

    jmp tty_setup




tty_setup:
    mov ah, 0x0E
    jmp print_loop_msg



print_loop_msg:
    mov al, [bx] ;mov into al the bytes inside register bx

    cmp al, 0 ;check if we reached the null terminator
    je cpu_hlt 

    int 0x10 ;interupt cpu and tel cpu to send bytes from al to screen

    inc bx ;we inc bx so the next byte goes into AL register

    jmp print_loop_msg



cpu_hlt:
    cli
    hlt



msg db "SaqOs Bootloader Version 1, No Kernel YET", 0

times 510 - ($ - $$) db 0 ;pad rest of the bootloader with 0
db 0x55, 0xAA ;the magical num
