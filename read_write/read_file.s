.section .rodata
filename:
    .asciz "text.txt"          # File to read

sentence_msg:
    .asciz "\nSentences: "

newline:
    .asciz "\n"

.data
.align 2
bufferstr: 
    .space 2048
error_msg:
    .asciz "Error: Read failed.\n"
    
.text
.globl _start

_start:
    lui s0, %hi(bufferstr)
    addi s0, s0,%lo(bufferstr) # Set buffer address
    


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
    mv a1, s0                  # Buffer address
    li a2, 1024                # Buffer size
    li a7, 63                  # Syscall number for read
    ecall
    bltz a0, read_error        # Exit if read failed
    beqz a0, close_file        # End of file (read 0 bytes)
    mv a2,a0                   # Bytes to print

    
    # Write to stdout
    li a0, 1                   # Stdout file descriptor
    mv a1, s0                  # Buffer address
    li a7, 64                  # Syscall number for write
    ecall
    bltz a0, write_error       # Exit if write failed

    jal x1, count_sentences

    j read_loop                # Continue reading

count_sentences:

    addi t2, zero, -1 # Counter
    mv t1, s0

    # create stack
    addi sp, sp, -20

    add_sentence:
        addi t2, t2, 1

    loop_sentence:
        # check for end of sentence (33, 46, 63)
        lb t4, 0(t1)

        addi t1, t1, 1
        addi t5, zero, 33 # Checker
        beq t4, t5, add_sentence
        addi t5, zero, 46
        beq t4, t5, add_sentence
        addi t5, zero, 63
        beq t4, t5, add_sentence

        bnez t4, loop_sentence

    print_sentence:
        # Write to stdout
        li a0, 1                   # Stdout file descriptor
        la a1, sentence_msg        # Message address
        li a2, 12                  # Message length
        li a7, 64                  # Syscall number for write
        ecall

        
        addi t2, t2, 48 # Get num ascii code
        addi sp, sp, -4
        sw t2, 0(sp)

        # Write to stdout
        li a0, 1                   # Stdout file descriptor
        mv a1, sp               # Buffer address
        li a2, 1
        li a7, 64                  # Syscall number for write
        ecall
        
        # # Write to stdout
        li a0, 1                   # Stdout file descriptor
        la a1, newline        # Message address
        li a2, 1                  # Message length
        li a7, 64                  # Syscall number for write
        ecall

        # sw t2, 0(sp)

close_file:
    # Close the file
    mv a0, t0                  # File descriptor
    li a7, 57                  # Syscall number for close
    ecall

    # Exit successfully
    li a0, 0
    li a7, 93
    ecall

read_error:
write_error:
exit_error:

    li a0, 1
    li a7, 93
    ecall