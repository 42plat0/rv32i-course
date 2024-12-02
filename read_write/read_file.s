.section .data
filename:
    .asciz "text_eng.txt"          # File to read

error_msg:
    .asciz "Error: Read failed.\n"

.section .text
.globl _start

_start:
    addi sp, sp, -1024         # Allocate 1024 bytes on the stack
    mv t1, sp                  # Use stack as buffer

    # Open file
    li a0, -100                # AT_FDCWD
    la a1, filename            # File name
    li a2, 0                   # O_RDONLY
    li a3, 0                   # Mode (unused for O_RDONLY)
    li a7, 56                  # Syscall number for openat
    ecall
    bltz a0, exit_error        # Exit if open failed
    mv t0, a0                  # Save file descriptor in t0

read_loop:
    # Read from file
    mv a0, t0                  # File descriptor
    mv a1, t1                  # Buffer address
    li a2, 1024                # Buffer size
    li a7, 63                  # Syscall number for read
    ecall
    bltz a0, read_error        # Exit if read failed
    beqz a0, close_file        # End of file (read 0 bytes)
    mv a2,a0                   # Bytes to print
    # Write to stdout
    li a0, 1                   # Stdout file descriptor
    mv a1, t1                  # Buffer address
    li a7, 64                  # Syscall number for write
    ecall
    bltz a0, write_error       # Exit if write failed

    j read_loop                # Continue reading

close_file:
    # Close the file
    mv a0, t0                  # File descriptor
    li a7, 57                  # Syscall number for close
    ecall

    # Free stack
    addi sp, sp, 1024          # Restore stack

    # Exit successfully
    li a0, 0
    li a7, 93
    ecall

read_error:
write_error:
exit_error:
    # Free stack and exit with error
    addi sp, sp, 1024          # Restore stack
    li a0, 1
    li a7, 93
    ecall