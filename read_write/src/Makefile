run: read_file
	@if command -v qemu-riscv64 > /dev/null 2>&1; then\
		qemu-riscv64 ./read_file; \
	else \
		./read_file; \
	fi
	
qemu: read_file
	qemu-riscv64-static -g 1234 read_file

read_file: read_file.o
	riscv64-unknown-elf-ld -o read_file read_file.o

read_file.o: read_file.s
	riscv64-unknown-elf-as -o read_file.o read_file.s

clean:
	rm -rf read_file read_file.o

gdb:
	riscv64-unknown-elf-gdb

memmdump:
	qemu-riscv64-static -strace read_file

cmemmdump:
	qemu-riscv64-static -strace -d in_asm,cpu  read_file
