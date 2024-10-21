.data
    counter: .word 0
    arg: .word 8
    print_arg: .word 4

.text
    main:
        # Counter equal 0
        lw a2, counter
        # While loop var
        lw a3, arg
        # Not to print var
        lw a4, print_arg
        
        jal x1, Loop_and_print
        
    Loop_and_print:
        beq a2, a3, Exit
        # Go to increment when it is 4, to become 5
        beq a2, a4, Increment # counter == 4
        
        # Add counter to print register
        add a0, x0, a2
        # Print integer
        li a7, 1
        ecall
        # Increment counter
        addi a2, a2, 1
        # Go back
        jal x0, Loop_and_print
    
    Increment:
        # Increment counter
        addi a2, a2, 1
        # Go back
        jal x0, Loop_and_print

    Exit:
        # Exit function
        addi x0, x0, 0