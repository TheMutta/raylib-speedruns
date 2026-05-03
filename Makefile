.PHONY: all clean nasm_target c_target

# phony targets
all: nasm_target c_target
clean:
	rm -rf */*.o */*.elf

# disable implicit make rules since it likes to complain
.SUFFIXES:
MAKEFLAGS += -r

# nasm targets
nasm_target: nasm/nasm.elf

nasm/nasm.elf: nasm/main.asm.o
	gcc nasm/main.asm.o -o nasm/nasm.elf -no-pie -lraylib

nasm/main.asm.o: nasm/main.asm
	nasm -felf64 nasm/main.asm -o nasm/main.asm.o

# c targets
c_target: c/c.elf

c/c.elf: c/main.c.o

c/main.c.o: c/main.c
	gcc c/main.c -o c/c.elf -lraylib


