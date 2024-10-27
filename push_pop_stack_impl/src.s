.data
    A: .word 7
    B: .word 4
    C: .word 1
    D: .word 2
    const: .word -10
    
#Issaugom returna registre ‘a’ 
#Nueinam i funkcija ir pushinam DCBA
#Popinam DCBA
#Skaiciuojam
#Loadinam i x1 issaugota ‘a’ reiksme
#Gryztam 
#Printinam 
#Exitinam

# x = A + B + C - 10 + D

.text
    main:
        jal x1, calc_x
        jal x0, print
    calc_x:
        # Store constant value
        addi a1, zero, -10
        
        # Store return to main (print func) adress
        add a0, x1, zero
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
        jal x1, pop # D
        add a1, a1, t0
        jal x1, pop # C
        add a1, a1, t0
        jal x1, pop # C
        add a1, a1, t0
        jal x1, pop # C
        add a1, a1, t0
        
        # Restore return address to main
        add x1, zero, a0
        jalr x0, x1, 0
        
    push:
        addi sp, sp, -4
        sw t0, 0(sp)
        jalr x0, x1, 0
    
    pop:
        lw t0, 0(sp)
        addi sp, sp, 4
        jalr x0, x1, 0
     
    print:
        add a0, zero, a1
        li a7, 1
        ecall
        
    exit:
        li a7, 10
        ecall