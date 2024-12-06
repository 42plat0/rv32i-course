.section .data
filename:
    .asciz "text_eng.txt"          # File to read

error_msg:
    .asciz "Error: Read failed.\n"

newline:
    .asciz "\n"

.section .text
.globl _start

_start:
    addi sp, sp, -1024         # Allocate 1024 bytes on the stack
    mv s0, sp                  # Use stack as buffer

    # Open file
    li a0, -100                # AT_FDCWD
    la a1, filename            # File name
    li a2, 0                   # O_RDONLY
    li a3, 0                   # Mode (unused for O_RDONLY)
    li a7, 56                  # Syscall number for openat
    ecall
    bltz a0, exit_error        # Exit if open failed
    mv s1, a0                  # Save file descriptor in t0

read_loop:
    # jal x1, count_cases
    # jal x1, count_sentences
    # jal x1, count_words
    
    # Read from file
    mv a0, s1                  # File descriptor
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

    j read_loop                # Continue reading

ucase_msg:
    .asciz "Uppercase:\n"
lcase_msg:
    .asciz "Lowercase:\n"   

count_cases:
    addi t2, zero, -1 # Uppercase ctr
    add t3, zero, zero # Lowercase ctr
    mv t1, sp

    add_ucase_count:
        addi t2, t2, 1
        beq zero, zero, loop_cases
    
    add_lcase_count:
        addi t3, t3, 1

    loop_cases:
        # check for cases
        lb t4, 0(sp)
        
        beqz t4, print_cases

        addi sp, sp, 1
        
        addi t0, t4, -65

        # addi t5, zero, 0 # Checker Upper case start
        beqz t0, add_ucase_count

        addi t5, zero, 25 # Upper case end
        ble t0, t5, add_ucase_count

        addi t0, t4, -97
        # addi t5, zero, 97 # Checker Lower case start
        beqz t0, add_lcase_count

        addi t5, zero, 25 # Lower case end
        ble t0, t5, add_lcase_count

        bnez t4, loop_cases

    print_cases:
        # Write to stdout
        li a0, 1                   # Stdout file descriptor
        la a1, ucase_msg                  # Buffer address
        li a2, 11
        li a7, 64                  # Syscall number for write
        ecall

        li a0, 1                   # Stdout file descriptor
        la a1, lcase_msg                  # Buffer address
        li a2, 11
        li a7, 64                  # Syscall number for write
        ecall

    jalr x0, x1, 0

sentence_msg:
    .asciz "Sentences:\n"
word_msg:
    .asciz "Words:\n"

count_sentences:

    addi t2, zero, -1 # Counter
    mv t1, sp

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
        la a1, sentence_msg                  # Buffer address
        li a2, 11
        li a7, 64                  # Syscall number for write
        ecall
        
        # addi sp, sp, -4
        # sw t2, 0(sp)
    mv t1, zero
    jalr x0, x1, 0


count_words:
    addi t2, zero, -1 # Counter
    mv t1, sp

    add_word_count:
        addi t2, t2, 1

    loop_words:
        # check for spaces, need to include also last 
        lb t4, 0(t1)

        addi t1, t1, 1

        addi t5, zero, 32 # Checker
        beq t4, t5, add_word_count

        bnez t4, loop_words

    print_words:
        # Write to stdout
        li a0, 1                   # Stdout file descriptor
        la a1, word_msg                  # Buffer address
        li a2, 7
        li a7, 64                  # Syscall number for write
        ecall

    mv t1, zero

    jalr x0, x1, 0




close_file:
    # Close the file
    mv a0, s1                  # File descriptor
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