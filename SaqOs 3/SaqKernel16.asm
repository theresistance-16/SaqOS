BITS 16
ORG 0x0000

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
    jne print_unknown_stp
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




cmd: db "SaqKernel> ", 0
panic: db "panic", 0 
help: db "help", 0
exit: db "exit", 0
saqver: db "saqver", 0
src: db "src", 0
kernel_msg: db "Welcome to SaqKernel! You Are in Ring 0, that means You have Full control over YOUR own Hardware. Type 'help' for all commands.", 0x0D, 0x0A, 0
help_out: db "All Commands: src, help, exit, saqver, panic. (USE PANIC CAREFULLY!, IT PANICS THE KERNEL!) (more commands to come and direct ring 0 lib calls)", 0
src_out: db "Source Code: https://github.com/theresistance-16/SaqOS", 0
saqver_out: db "SaqKernel Version: 3 Saqbootloader version: 3", 0
panic_out: db "ERR! KERNEL HAS HALTED! SysRequest: 'panic', halting kernel...", 0
exit_out: db "Exitting SaqKernel and Halting kernel...", 0
exit1_out: db "Its safe to poweroff your pc now", 0
unknown_out: db "Unknown Command! Type 'help' to get all commands.", 0

userbuffer: times 512 db 0 
times (512 * 4) - ($ - $$) db 0 ;pad the kernel out so it corresponds to the sector count
