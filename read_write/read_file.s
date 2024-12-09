.section .rodata
.align 4
filename:
    .asciz "text_eng.txt"          # File to read

sentence_msg:
    .asciz "\nSentences: "

word_msg:
    .asciz "Words: "

newline:
    .asciz "\n"

ucase_msg:
    .asciz "Uppercase: "

lcase_msg:
    .asciz "Lowercase: " 

.section .data
.align 4
bufferstr: 
    .space 2048

error_msg:
    .asciz "Error: Read failed.\n"
    
.text
.globl _start

_start:
    # addi sp, sp, -1024 # Create stack for results

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


    ### Counting and saving ###

    ## Cases ##
    jal x1, count_cases     # get U/L case count, t2 = UpC, t3=LoC
    
    mv a0, t3               # Use L case count as arg
    jal x1, save_count      # Count L case count
    
    mv a0, t2               # Use U case count as arg
    jal x1, save_count      # Count U case count
    
    ## Words ##
    jal x1, count_words     # Get word count
    
    mv a0, t2               # Use word count as arg
    jal x1, save_count      # Save word count

    ## Sentences ##
    jal x1, count_sentences # get sentence count
    
    mv a0, t2               # Use sentence count as arg
    jal x1, save_count      # Save sentence count


    ### Prints ###

    # Sentence
    la a1, sentence_msg     # Sentence message address
    li a2, 12               # Message length
    jal x1, print_msg
    jal x1, print_result
    
    # Word
    la a1, word_msg         # Word message address
    li a2, 8                # Message length
    jal x1, print_msg 
    jal x1, print_result

    # Cases
    la a1, ucase_msg        # Uppercase message address
    li a2, 12               # Message length
    jal x1, print_msg
    jal x1, print_result
    
    la a1, lcase_msg        # Lowercase message address
    li a2, 12               # Message length
    jal x1, print_msg
    jal x1, print_result


    j close_file                # Continue reading

print_msg: # print string before count

    # Write to stdout
    li a0, 1                   # Stdout file descriptor
    li a7, 64                  # Syscall number for write
    ecall
    jalr x0, x1, 0

print_result:
    li a0, 1                   # Stdout file descriptor
    mv a1, sp                  # Buffer address
    li a2, 3                   # Len 
    li a7, 64                  # Syscall number for write
    ecall

    # Write to stdout
    li a0, 1                   # Stdout file descriptor
    la a1, newline             # Message address
    li a2, 1                   # Message length
    li a7, 64                  # Syscall number for write
    ecall

    addi sp, sp, 3 # Increment sp to print next number 

    jalr x0, x1, 0

save_count:
    # a0 = count, t6 = divisor, t3 = hundreds, t1 = tens, t5 = ones
    # Get 100s 10ths and 1s
    li t6, 100
    div t3, a0, t6 # Hundreds count
    rem t4, a0, t6 # 10's

    li t6, 10
    div t1, t4, t6 # 10's count
    rem t5, t4, t6 # 1's count
    
    # Get num ascii code
    addi t3, t3, 48 # Hundreds
    addi t1, t1, 48 # Tens
    addi t5, t5, 48 # Ones

    # Add numbers to stack

    # Ones
    addi sp, sp, -1 
    sb t5, 0(sp)
    
    # Tens
    addi sp, sp, -1
    sb t1, 0(sp)

    # Hundreds
    addi sp, sp, -1
    sb t3, 0(sp)

    jalr x0, x1, 0

count_cases:
    mv t1, s0                       # Buffer
    addi t2, zero, -1               # Uppercase ctr
    add t3, zero, zero              # Lowercase ctr

    add_ucase_count:
        addi t2, t2, 1              # UpC counter
        beq zero, zero, loop_cases  # Go back to loop
    
    add_lcase_count:
        addi t3, t3, 1              # LoC counter

    loop_cases: # check for cases
        lb t4, 0(t1)                # Load letter
        
        beqz t4, go_back 

        addi t1, t1, 1              # go to next letter
        
        addi t0, t4, -65            # subtract first Uppercase letter ascii code
        blt t0, zero, loop_cases    # Is not a letter
        beqz t0, add_ucase_count    # Check Upper case start
        addi t5, zero, 25           # Upper case end
        ble t0, t5, add_ucase_count # Is in boundary of upper case letters

        addi t0, t4, -97
        blt t0, zero, loop_cases    # Is not a letter
        beqz t0, add_lcase_count    # Checker Lower case start
        addi t5, zero, 25           # Lower case end
        ble t0, t5, add_lcase_count # Is in boundary of lower case letters

        bnez t4, loop_cases

    go_back:
        jalr x0, x1, 0

    jalr x0, x1, 0

count_words:
    addi t2, zero, 0 # Counter, starts from 1 to account for last sentence not having a space
    mv t1, s0

    add_word_count:
        addi t2, t2, 1

    loop_words:
        # check for spaces, need to include also last 
        lb t4, 0(t1)

        addi t1, t1, 1

        addi t5, zero, 32 # Checker
        beq t4, t5, add_word_count

        bnez t4, loop_words
        
    jalr x0, x1, 0


count_sentences:

    addi t2, zero, -1 # Counter
    mv t1, s0 # Buffer address

    add_sentence:
        addi t2, t2, 1 # Counter

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



    jalr x0, x1, 0

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