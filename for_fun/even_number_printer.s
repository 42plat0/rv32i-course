.data:
    even_num: .word 0
    terminator: .word 10
    nl: .string "\n"
    null: .string "0" # Needed to properly align instructions without which we couldnt run program
.text:
    main:
        lw a2, even_num
        lw a3, terminator
        lw a4, nl
        
        j loop_print
    loop_print:
        bge a2, a3, exit
        addi a2, a2, 2
        
        add a0, x0, a2
        li a7, 1
        ecall
        
        la a0, nl
        li a7, 4
        ecall
        
        j loop_print
        
    exit:
        addi x0, x0, 0