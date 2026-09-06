all:
	ia16-elf-gcc -ffreestanding -O2 -c saqlibc/test.c -o test.o
	nasm -f bin bootloader.asm -o boot.bin
	nasm -f elf kernel.asm -o kernel.o
	nasm -f elf saqlibc/printc.asm -o printc.o
	ia16-elf-ld -T linker.ld -o kernel.bin kernel.o printc.o test.o
	cat boot.bin kernel.bin > os.img
	qemu-system-x86_64 -drive format=raw,file=os.img

clean:
	rm printc.o
	rm test.o
	rm kernel.o
	rm os.img
	rm boot.bin
	rm kernel.bin 