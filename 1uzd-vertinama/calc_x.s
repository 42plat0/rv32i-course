.data
    A: .word 3
    B: .word 3
    C: .word 3
    D: .word 1
    const: .word -10
    
    dummy: .word 420

.text
    load_constants:
        lw t0, const # Nepushint i funckija, turi buti funkcijoje jau
        lw t1, A
        lw t2, B
        lw t3, C
        lw t4, D
    
        addi sp, sp, -24 # Initialize stack
        
    push:
        sw t1, 20(sp) # A
        sw t2, 16(sp) # B
        sw t3, 12(sp)  # C
        sw t4, 8(sp)  # D
        
        sw t0, 4(sp)  # -10 Nepushint i funckija, turi buti funkcijoje jau

        jal x1, calc_x
        
        jal x0, print

    calc_x:        
        # Save return adress to print
        sw x1, 0(sp)
                add s1, t1, t2 # A + B
        add s1, s1 t0 # A + B + 10
        
        add t1, t4, t3 # D - C
        
        add s1, s1, t1 #  A + B + 10 + D - C
        jal x1, pop
        
        lw x1, 0(sp)
        addi sp, sp, 4
        
        add s1, a4, a3 # x = A + B
        add s1, s1, a2 # x += C
        add s1, s1, a1 # x += D
        add s1, s1, a0 # x += -10
        
        ret
    
    pop:
        lw a0, 4(sp) # -10
        lw a1, 8(sp) # D
        lw a2, 12(sp) # C
        lw a3, 16(sp) # B
        lw a4, 20(sp) # A
        
        addi sp, sp, 20
        ret
        
    
    print:
        add a0, zero, s1
        li a7, 1
        ecall
        
    exit:
        li a7, 10
        ecall