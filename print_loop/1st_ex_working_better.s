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
        
        jal loop
        

    loop:
        # a2 = iterator variable
        # a3 = range limit
        # a4 = int not to print
        
        beq a2, a3, exit
        # Go to increment when it is 4, to become 5
        beq a2, a4, jumpOverPrint # counter == 4
        # Print
        jal print
        
        # Increment counter
        addi a2, a2, 1
        # Go back
        jal x0, loop
    
    print:
        # Add counter to print register and print
        add a0, x0, a2
        li a7, 1
        ecall
    
        jr x1
        
    jumpOverPrint:
        # After going back we skip jumping to print, so no need to increment
        jr x1

    exit:
        # Exit 
        li a7 10
        ecall