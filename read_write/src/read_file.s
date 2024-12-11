.section .rodata
.align 4
filename:
    .asciz "text.txt"          # File to read

new_filename:
    .asciz "c_text.txt"

sentence_msg:
    .asciz "Sentences: "

word_msg:
    .asciz "Words: "

newline:
    .asciz "\n"

ucase_msg:
    .asciz "Uppercase: "

lcase_msg:
    .asciz "Lowercase: " 

error_msg:
    .asciz "Error: Read failed.\n"

.section .data
.align 4
bufferstr: 
    .space 2048

.text
.globl _start

_start:
    # Set buffer address
    lui s0, %hi(bufferstr)
    addi s0, s0,%lo(bufferstr) 

    # Open file
    li a0, -100                         # AT_FDCWD
    la a1, filename                     # File name
    li a2, 0                            # O_RDONLY
    li a3, 0                            # Mode (unused for O_RDONLY)
    li a7, 56                           # Syscall number for openat
    ecall
    bltz a0, exit_error                 # Exit if open failed
    mv s1, a0                           # Save file descriptor in s1

read_loop:
    # Read from file
    mv a0, s1                           # File descriptor
    mv a1, s0                           # Buffer address
    li a2, 2048                         # Buffer size
    li a7, 63                           # Syscall number for read
    ecall
    bltz a0, read_error                 # Exit if read failed
    beqz a0, close_file                 # End of file (read 0 bytes)
    
    mv s2, a0                           # Save byte count for overwriting

count_and_save:
    ### Counting and saving ###

    ## Letters ##
    jal x1, add_letters_to_buffer       # Push to buffer latin letters
    jal x1, count_letters           
    
    # Save counts as ascii characters for each letter
    mv t0, sp                           # Get stack pointer
    li a1, 2                            # Informs save_count that we're updating values
    li t2, 52                           # Letter count - 2 (less than)

    # TODO 
    # ADD UNSIGNED VALUES TO COUNT
    # OVERFLOW OCCURS
    update_count_values:
        addi t0, t0, 2                  # Get count for letter saved in third byte
        lb a0, 0(t0)                    # Load count value
        jal x1, save_count              # Save it in ascii format value -> [hundreds][tens][ones]

        addi t2, t2, -1                 # Keep track of letter count already converted
        
        bgt t2, zero, update_count_values
    

    ## Cases ##
    jal x1, count_cases                 # get U/L case count, t2 = UpC, t3=LoC
    
    # Lowercase
    mv a0, t3                           # Use L case count as arg
    li a1, 1                            # Informs save_count that we're saving values
    jal x1, save_count                  # Count L case count
    
    # Uppercase
    mv a0, t2                           # Use U case count as arg
    li a1, 1                            # Informs save_count that we're saving values
    jal x1, save_count                  # Count U case count
    
    ## Words ##
    jal x1, count_words                 # Get word count
    
    mv a0, t2                           # Use word count as arg
    li a1, 1                            # Informs save_count that we're saving values
    jal x1, save_count                  # Save word count

    ## Sentences ##
    jal x1, count_sentences             # Get sentence count
    
    mv a0, t2                           # Use sentence count as arg
    li a1, 1                            # Informs save_count that we're saving values
    jal x1, save_count                  # Save sentence count


print:
    ### Prints ###

    # Sentence
    la a1, sentence_msg                 # Sentence message address
    li a2, 12                           # Message length
    jal x1, print_msg

    li a2, 3                            # Load length of result
    jal x1, print_result
    add sp, sp, a2                      # Increment sp to print next number 

    jal x1, print_newline
    
    # Word
    la a1, word_msg                     # Word message address
    li a2, 8                            # Message length
    jal x1, print_msg 
    
    li a2, 3                            # Load length of result
    jal x1, print_result
    add sp, sp, a2                      # Increment sp to print next number 

    jal x1, print_newline

    # Cases
    la a1, ucase_msg                    # Uppercase message address
    li a2, 12                           # Message length
    jal x1, print_msg
    
    li a2, 3                            # Load length of result
    jal x1, print_result
    add sp, sp, a2                      # Increment sp to print next number 
    jal x1, print_newline
    
    la a1, lcase_msg                    # Lowercase message address
    li a2, 12                           # Message length
    jal x1, print_msg
    
    li a2, 3                            # Load length of result
    jal x1, print_result
    add sp, sp, a2                      # Increment sp to print next number
    jal x1, print_newline

    # Letter counts
    letter_print_loop:        
        li a2, 5                        # Set string length 
        jal x1, print_result            # Print out letter and its count
        add sp, sp, a2                  # Increment sp to print next number
        jal x1, print_newline

        # Check if next letter exists
        lb t1, 5(sp)                    
        bgt t1, zero, letter_print_loop

    jal x1, open_new                    # Open new file
    mv t2, a0                           # Save file descriptor for new file to close it latter after writing
    jal x1, change_letters              # Change letters in original buffer
    jal x1, write_new                   # Write and close new file with changed buffer

    j close_file                        # Close file

write_new:
    # Write to file
    mv a1, s0                           # Buffer address
    mv a2, s2                           # Bytes to print
    li a7, 64                           # Syscall number for write
    ecall
    bltz a0, write_error                # Exit if write failed
    
    # Close the file
    mv a0, t2                           # File descriptor
    li a7, 57                           # Syscall number for close
    ecall

    jalr x0, x1, 0

change_letters:
    mv t1, s0
        
    beq zero, zero, check_letters

    g_upp_case:
        li t3, 80                       # P character
        sb t3, 0(t1)                    # Save P for G

        beqz zero, check_letters

    g_lo_case:
        li t3, 112                      # p character
        sb t3, 0(t1)                    # Save p for g
        
    check_letters:
        lb t4, 0(t1)                    # Load current char
        
        # G  checker
        li t3, 71               
        beq t4, t3, g_upp_case

        # g  checker
        li t3, 103              
        beq t4, t3, g_lo_case

        addi t1, t1, 1                  # Advance pointer

        bnez t4, check_letters

    jalr x0, x1, 0

open_new:
    # Create new file
    li a0, -100                         # AT_FDCWD
    la a1, new_filename                 # File name
    li a2, 64|1                         # O_CREAT | O_WRONLY
    li a3, 0644                         # rw, r, r permissions
    li a7, 56                           # Syscall number for openat
    ecall
    bltz a0, exit_error                 # Exit if open failed

    jalr x0, x1, 0

count_letters:
    # Count letters based on their case seperately
    # By their index in buffer
    # Every letter appears by 5 bytes 
    # [Letter][:][0][0][0]
    # 0-130 A-Z , in 5 bytes, 0-a, 5-b, 10-c
    # 130-260 a-z
    
    mv t1, s0
    mv t2, sp
    
    li a0, 5                             # Space between letters in stack
    li a1, 2                             # Space to count number
    
    beq zero, zero, loop_letters         # Go back to loop

    add_upc_letter_count:
        mul t0, t0, a0                   # Get letter place in array 

        add t2, sp, t0                   # Get letter in place
        add t2, t2, a1                   # Get count number

        lbu t3, 0(t2)                     # Load value

        addi t3, t3, 1                   # Increment letters count value
        sb t3, 0(t2)                     # Save it back

        beqz zero, loop_letters          # Go back to loop
    
    add_lc_letter_count:
        addi t0, t0, 26                  # Lowercase letters are above lower
        mul t0, t0, a0                   # Get letter place in array 

        add t2, sp, t0                   # Get letter in place
        add t2, t2, a1                   # Get count number

        lbu t3, 0(t2)                     # Load value

        addi t3, t3, 1                   # Increment letters count value
        sb t3, 0(t2)                     # Save it back
    
    # Iterate letters
    loop_letters:                   
        lb t4, 0(t1)                     # Load letter
        
        beqz t4, return                  # No char left

        addi t1, t1, 1                   # go to next letter
        
        addi t0, t4, -65                 # subtract first Uppercase letter ascii code
        blt t0, zero, loop_letters       # Is not a letter

        beqz t0, add_upc_letter_count    # Check Upper case start
        addi t5, zero, 25                # Upper case end
        ble t0, t5, add_upc_letter_count # Is in boundary of upper case letters

        addi t0, t4, -97                 # Lowercase
        blt t0, zero, loop_letters       # Is not a letter

        beqz t0, add_lc_letter_count     # Checker Lower case start
        addi t5, zero, 25                # Lower case end
        ble t0, t5, add_lc_letter_count  # Is in boundary of lower case letters

        bnez t4, loop_letters

    return:
        jalr x0, x1, 0

    jalr x0, x1, 0 

add_letters_to_buffer:
    # Z-A(90-65), z-a(122-97), :(58)
    li t3, 58                            # :
    li t1, 122                           # Start z
    li t2, 96                            # End   a - 1

    lowercase:
        # Save 3 bytes for storing numbers
        addi sp, sp, -1                  # Increment stack pointer    
        addi s3, s3, 1                   # Increment stack byte count
        sb zero, 0(sp)                   # Ones  
        
        addi sp, sp, -1                  # Increment stack pointer
        addi s3, s3, 1                   # Increment stack byte count
        sb zero, 0(sp)                   # Tens
        
        addi sp, sp, -1                  # Increment stack pointer
        addi s3, s3, 1                   # Increment stack byte count
        sb zero, 0(sp)                   # Hundreds 
        
        # Save starting to characters - letter and :
        addi sp, sp, -1                  # Increment stack pointer
        addi s3, s3, 1                   # Increment stack byte count
        sb t3, 0(sp)                     # Save : for display

        addi s3, s3, 1                   # Increment stack byte count
        addi sp, sp, -1                  # Increment stack pointer
        sb t1, 0(sp)                     # Save letter

        addi t1, t1, -1
        bgt t1, t2, lowercase

    li t1, 90                            # Start Z
    li t2, 64                            # End   A - 1
    
    uppercase:
        # Save 3 bytes for storing numbers
        addi sp, sp, -1                  # Increment stack pointer    
        addi s3, s3, 1                   # Increment stack byte count
        sb zero, 0(sp)                   # Ones  

        addi sp, sp, -1                  # Increment stack pointer
        addi s3, s3, 1                   # Increment stack byte count
        sb zero, 0(sp)                   # Tens

        addi sp, sp, -1                  # Increment stack pointer
        addi s3, s3, 1                   # Increment stack byte count
        sb zero, 0(sp)                   # Hundreds 
        
        # Save starting to characters - letter and :
        addi sp, sp, -1                  # Increment stack pointer
        addi s3, s3, 1                   # Increment stack byte count
        sb t3, 0(sp)                     # Save : for display

        addi sp, sp, -1                  # Increment stack pointer
        addi s3, s3, 1                   # Increment stack byte count
        sb t1, 0(sp)                     # Save letter

        addi t1, t1, -1                  # Go backwards from Z to A
        bgt t1, t2, uppercase

    jalr x0, x1, 0


print_msg: # print string before count

    # Write to stdout
    li a0, 1                             # Stdout file descriptor
    li a7, 64                            # Syscall number for write
    ecall

    jalr x0, x1, 0

print_newline:
    # Write to stdout
    li a0, 1                             # Stdout file descriptor
    la a1, newline                       # Message address
    li a2, 1                             # Message length
    li a7, 64                            # Syscall number for write
    ecall

    jalr x0, x1, 0

print_result:
    li a0, 1                             # Stdout file descriptor
    mv a1, sp                            # Buffer address
    li a7, 64                            # Syscall number for write
    ecall
    
    jalr x0, x1, 0

save_count:
    # a0 = count, t6 = divisor/validator, t3 = hundreds, t1 = tens, t5 = ones
    # a1 = validator, 1 if adding, 2 if updating
    # t0 = stack pointer when updating count values
    
    # Get 100s 10ths and 1s
    li t6, 100
    div t3, a0, t6                       # Hundreds count
    rem t4, a0, t6                       # 10's

    li t6, 10
    rem t5, t4, t6                       # 1's count
    div t1, t4, t6                       # 10's count
    
    # Get num ascii code
    addi t3, t3, 48                      # Hundreds
    addi t1, t1, 48                      # Tens
    addi t5, t5, 48                      # Ones

    li t6, 1                             # Validator

    beq t6, a1, adding

    # Change values in the stack if they do exist 
    updating:
        sb t3, 0(t0)                     # Hundreds
        addi t0, t0, 1                   # Update stack pointer

        sb t1, 0(t0)                     # Tens
        addi t0, t0, 1                   # Update stack pointer

        sb t5, 0(t0)                     # Ones
        addi t0, t0, 1                   # Update stack pointer

        beqz zero, back_main

    # Add numbers to stack if they do not exist
    adding:
        addi sp, sp, -1                  # Update stack pointer
        sb t5, 0(sp)                     # Ones
        
        addi sp, sp, -1                  # Update stack pointer
        sb t1, 0(sp)                     # Tens

        addi sp, sp, -1                  # Update stack pointer
        sb t3, 0(sp)                     # Hundreds

    back_main:
        jalr x0, x1, 0

count_cases:
    mv t1, s0                            # Buffer
    addi t2, zero, -1                    # Uppercase ctr
    add t3, zero, zero                   # Lowercase ctr

    add_ucase_count:
        addi t2, t2, 1                   # UpC counter
        beq zero, zero, loop_cases       # Go back to loop
    
    add_lcase_count:
        addi t3, t3, 1                   # LoC counter

    loop_cases: # check for cases
        lb t4, 0(t1)                     # Load letter
        
        beqz t4, go_back 

        addi t1, t1, 1                   # Go to next letter
        
        addi t0, t4, -65                 # subtract first Uppercase letter ascii code
        blt t0, zero, loop_cases         # Is not a letter
        beqz t0, add_ucase_count         # Check Upper case start
        addi t5, zero, 25                # Upper case end
        ble t0, t5, add_ucase_count      # Is in boundary of upper case letters

        addi t0, t4, -97                 # Check for lowercase
        blt t0, zero, loop_cases         # Is not a letter
        beqz t0, add_lcase_count         # Checker Lower case start
        addi t5, zero, 25                # Lower case end
        ble t0, t5, add_lcase_count      # Is in boundary of lower case letters

        bnez t4, loop_cases

    go_back:
        jalr x0, x1, 0

count_words:
    addi t2, zero, 1                     # Counter, starts from 1 to account for last sentence not having a space
    mv t1, s0
    li t5, 32                            # Checker for [SPACE]

    beqz zero, loop_words

    add_word_count:
        lb t3, -2(t1)                    # Load value before space

        beq t3, t4, loop_words           # Do not increment counter if value before is [SPACE]
        addi t2, t2, 1

    loop_words:                          # Check for spaces
        lb t4, 0(t1)                     # Load letter
        addi t1, t1, 1                   # Increment buffer pointer
        beq t4, t5, add_word_count       # Increment word count if space appears
        bnez t4, loop_words              # While there is a letter
        
    jalr x0, x1, 0


count_sentences:
    addi t2, zero, 0                     # Sentence counter initialization
    mv t1, s0                            # Buffer address

    beqz zero, loop_sentence

    add_sentence:
        lb t3, -2(t1)                    # Load char before current char

        beq t3, t4, loop_sentence        # Do not increment counter if value before is the same


        addi t2, t2, 1                   # Sentence counter

    loop_sentence:                       # Check for end of sentence - !(33), .(46), ?(63)
        lb t4, 0(t1)

        addi t1, t1, 1                   # Load char

        li t5, 33                        # ! character
        beq t4, t5, add_sentence  
        li t5, 46                        # . character
        beq t4, t5, add_sentence
        li t5, 63                        # ? character
        beq t4, t5, add_sentence

        bnez t4, loop_sentence           # While there is a char

    jalr x0, x1, 0

close_file:
    # Close the file
    mv a0, s1                           # File descriptor
    li a7, 57                           # Syscall number for close
    ecall

    # Exit successfully
    li a0, 0
    li a7, 93
    ecall

read_error:
write_error:
exit_error:
    la a1, error_msg                    # Word message address
    li a2, 20                           # Message length
    jal x1, print_msg

    li a0, 1
    li a7, 93
    ecall