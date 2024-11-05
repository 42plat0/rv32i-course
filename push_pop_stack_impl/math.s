.data
    A: .word 13
    B: .word 1
    C: .word 1
    D: .word 5

.text
    main:
        # Store constant value
        addi a1, zero, -10
        
        # Store memory adress of function after math
        addi t0, t0, print
        jal x1, push
        
        # Store variables
        lw t0, D
        jal x1, push
        lw t0, C
        jal x1, push
        lw t0, B
        jal x1, push
        lw t0, A
        jal x1, push

        # Calculate
        jal x1, math
        
        print:
        # Print result X
        add a0, zero, a1
        li a7, 1
        ecall
                
        # Exit function
        li a7, 10
        ecall
        
    math:   
        # Calculate
        jal x1, pop # D
        add a1, a1, t0
        jal x1, pop # C
        add a1, a1, t0
        jal x1, pop # C
        add a1, a1, t0
        jal x1, pop # C
        add a1, a1, t0
        
        # Restore return address to main
        jal x1, pop
        add x1, zero, t0
        jalr x0, x1, 0

    push:
        addi sp, sp, -4
        sw t0, 0(sp)
        jalr x0, x1, 0
    
    pop:
        lw t0, 0(sp)
        addi sp, sp, 4
        jalr x0, x1, 0
 