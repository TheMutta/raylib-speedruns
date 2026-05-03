.PHONY: all clean nasm_target c_target cpp_target

# phony targets
all: nasm_target c_target cpp_target
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
	gcc c/main.c.o -o c/c.elf -lraylib

c/main.c.o: c/main.c
	gcc -c c/main.c -o c/main.c.o -lraylib

# cpp targets
cpp_target: cpp/cpp.elf

cpp/cpp.elf: cpp/main.cpp.o
	gcc cpp/main.cpp.o -o cpp/cpp.elf -lraylib

cpp/main.cpp.o: cpp/main.cpp
	g++ -c cpp/main.cpp -o cpp/main.cpp.o -lraylib

