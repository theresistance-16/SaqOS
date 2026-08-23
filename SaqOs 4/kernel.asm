BITS 16

ORG 0x0000

section .text ;instructions and hardcoded strings and outputs

kernel_main:
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
		
    xor si, si
    xor cx, cx
    mov bx, kernel_msg

    mov ah, 0x0E


    jmp welcome


welcome:
    mov al, [bx]
    cmp al, 0
    je handle_newline

    int 0x10

    inc bx

    jmp welcome

handle_newline:
    mov ah, 0x0E

    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    mov al, 0x0D
    int 0x10


    mov si, userbuffer
    mov bx, cmd

    jmp kernelshell


kernelshell:
    mov al, [bx]
    cmp al, 0
    je wait_forinput

    int 0x10
    
    inc bx

    jmp kernelshell


wait_forinput:
    mov ah, 0x00
    int 0x16

    cmp al, 0x0D

    je handle_enter_n_check

    cmp al, 0x08

    je handle_bakspc

    cmp al, 0x20

    je handle_spc

    mov [si], al

    mov ah, 0x0E
    int 0x10


    inc si
    jmp wait_forinput


handle_bakspc:
 	mov cx, userbuffer
	cmp si, cx ;check if we are at 0 byte or less, then jmp back to wait for input because we dont want the user to backspace the prompt away
	jle wait_forinput

	mov ah, 0x0E
	mov al, 0x08 
	int 0x10
	
	mov al, 0x20 ;replace the last byte with emtpy space ON SCREEN
	int 0x10
	
	mov al, 0x08 ;replacing last byte with empty space makes the cursor go one right agian, we go one left 
	int 0x10 

    dec si

    mov byte [si], 0

    jmp wait_forinput

handle_spc:
    mov ah, 0x0E
    mov al, 0x20
    int 0x10
    mov [si], al
    inc si
    jmp wait_forinput

handle_enter_n_check:
    
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    mov byte [si], 0 ;replace the enter with zero

    jmp check_help_stp


check_help_stp:
    mov si, userbuffer
    mov bx, help
    jmp check_help

check_help:
    mov al, [bx]
    mov ah, [si]

    cmp al, ah
    jne check_saqver_stp

    cmp al, 0
    je print_help_stp

    inc bx
    inc si

    jmp check_help
    
print_help_stp:
    mov ah, 0x0E
    mov bx, help_out

    jmp print_help

print_help:
    mov al, [bx]
    cmp al, 0
    je handle_newline
    int 0x10
    inc bx
    jmp print_help

check_saqver_stp:
    mov si, userbuffer
    mov bx, saqver
    jmp check_saqver

check_saqver:
    mov ah, [bx]
    mov al, [si]

    cmp al, ah
    jne check_panic_stp
    cmp al, 0
    je print_saqver_stp

    inc bx
    inc si
    jmp check_saqver

print_saqver_stp:
    mov ah, 0x0E
    mov bx, saqver_out
    jmp print_saqver

print_saqver:
    mov al, [bx]
    cmp al, 0
    je handle_newline
    int 0x10
    inc bx
    jmp print_saqver

check_panic_stp:
    mov si, userbuffer ;we move the buffer back into si again so it points at the beginning (the inc from before altered the pointer to point somewhere else)
    mov bx, panic
    jmp check_panic

check_panic:
    mov al, [bx]
    mov ah, [si]
    cmp al, ah
    jne check_src_stp
    cmp al, 0
    je print_panic_stp

    inc bx
    inc si
    jmp check_panic

print_panic_stp:
    mov ah, 0x0E
    mov bx, panic_out
    jmp print_panic

print_panic:
    mov al, [bx]
    cmp al, 0
    je halt
    int 0x10
    inc bx
    jmp print_panic

check_src_stp:
    mov si, userbuffer
    mov bx, src ;si is userbuffer
    jmp check_src

check_src:
    mov ah, [si]
    mov al, [bx]
    cmp al, ah
    jne check_exit_stp
    cmp al, 0
    je print_src_stp
    inc bx
    inc si
    jmp check_src

print_src_stp:
    mov ah, 0x0E
    mov bx, src_out
    jmp print_src

print_src:
    mov al, [bx]
    cmp al, 0
    je handle_newline
    int 0x10
    inc bx
    jmp print_src

check_exit_stp:
    mov si, userbuffer
    mov bx, exit
    jmp check_exit

check_exit:
    mov al, [si]
    mov ah, [bx]
    cmp al, ah
    jne check_echo
    cmp al, 0
    je print_exit_stp
    inc bx
    inc si
    jmp check_exit

print_exit_stp:
    mov ah, 0x0E
    mov bx, exit_out
    jmp print_exit

print_exit:
    mov al, [bx]
    cmp al, 0
    je  print_exit1_stp
    int 0x10
    inc bx
    jmp print_exit

print_exit1_stp:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10

    mov bx, exit1_out
    jmp print_exit1

print_exit1:
    mov al, [bx]
    cmp al, 0
    je halt
    int 0x10
    inc bx
    jmp print_exit1

    ;all the code on top and the print_unkown_stp code is legacy version 3 way of printing strings on disp, now i have saqkprint


check_echo:
    mov bx, userbuffer
    mov si, echo

    call saqkcmpstr

    cmp al, 1
    je check_clear
    cmp al, 0
    je print_echo

print_echo:

    mov si, echo_out
    call saqkprint

    mov bx, echo_buffer
    mov si, echo_buffer
    call saqkuserin ;saqksuerin puts the input into echo_buffer

    cmp di, 0 ;check if enter was hit
    je print_echo_out

print_echo_out:
    mov si, echo_buffer
    call saqkprint
    jmp handle_newline

    ;newline gets handled all by saqkuserin

check_clear:
    mov bx, userbuffer
    mov si, clear

    call saqkcmpstr

    cmp al, 1
    je check_reboot
    cmp al, 0
    je cmd_clear

cmd_clear:
    pusha

    mov ah, 0x06 ;for clearing text
    mov al, 0x00 ;0x00 means clear all
    mov bh, 0x07 ;0 for black background and 7 for light grey text, 
    mov cx, 0x0000 ;top left corner (0/0 for x/y coordinates)
    mov dx, 0x184F ;bottom right corner (24/79)

    int 0x10

    ;i forgot resetting the cursor to the top left

    mov ah, 0x02 ;set cursor pos
    mov bh, 0x00 ;page num 0?
    mov dx, 0x0000 ; row: 0 col: 0, top left
    int 0x10
    

    popa

    jmp handle_newline


check_reboot:
    mov bx, userbuffer
    mov si, reboot

    call saqkcmpstr

    cmp al, 1
    je print_unknown_stp
    cmp al, 0
    je restart

restart:
    ;before we just reboot, lets say a message the user wont see anyway because it will happe n in 0.00001 seconds
    mov si, reboot_out
    call saqkprint

    ;no need for newline

    mov word [0x0472], 0x1234 ;set warm boot flag so BIOS doenst hang, those addresses are like magic nums to me
    JMP 0xFFFF:0x0000 ;sysreboot

print_unknown_stp:
    mov bx, unknown_out
    mov ah, 0x0E
    jmp print_unknown

print_unknown:
    mov al, [bx]
    cmp al, 0
    je handle_newline
    int 0x10
    inc bx
    jmp print_unknown

halt:
    cli 
    hlt



;hardcoded commands/prompt here:
cmd: db "SaqKernel> ", 0
panic: db "panic", 0 
help: db "help", 0
exit: db "exit", 0
saqver: db "sysinfo", 0 ;in v4 i changed to sysinfo instead, sounds less goofy
src: db "src", 0
echo: db "echo", 0
clear: db "clear", 0 ;special case, output is clearing screen
reboot: db "reboot", 0 ;special case #2, it rejmps to kernel i think




;messages here:
kernel_msg: db "Welcome to SaqKernel! You Are in Ring 0, that means You have Full control over YOUR own Hardware. Type 'help' for all commands.", 0x0D, 0x0A, 0

;output of requested commands here:
help_out: db "All Commands: src, help, exit, sysinfo, panic, echo, reboot, clear. (USE PANIC CAREFULLY!, IT PANICS THE KERNEL!) (more commands to come and direct ring 0 lib calls) also, just type echo and then you will get a prompt on what you want to echo.", 0
src_out: db "Source Code: https://github.com/theresistance-16/SaqOS", 0
saqver_out: db "kernel version: 4 Saqbootloader version: 4", 0
panic_out: db "ERR! KERNEL HAS HALTED! SysRequest: 'panic', halting kernel...", 0
exit_out: db "Exitting SaqKernel and Halting kernel...", 0
exit1_out: db "Its safe to poweroff your pc now", 0
unknown_out: db "Unknown Command! Type 'help' to get all commands.", 0
echo_out: db "What do you want to echo?> ", 0
reboot_out: db "Rebooting kernel...", 0


;includes here:
%include "saqlib/saqkprint.asm"
%include "saqlib/saqkcmpstr.asm"
%include "saqlib/saqkuserin.asm"
%include "saqlib/saqknewline.asm"

section .bss ;buffer section

;buffers
echo_buffer resb 200
userbuffer resb 512 

;i used resb in version 4 instead so it doesnt make my kernel over 1 mb already

section .text
times (512 * 4) - ($ - $$) db 0 ;pad the kernel out so it corresponds to the sector count (4 sectors long, 4 x 512 bytes)
