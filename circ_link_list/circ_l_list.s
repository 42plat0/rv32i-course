.data
    start: .word 0
    
.text
    main:
        # Letter counter
        li t0, 0
        
        # First letter - start
        
        lui a6, %hi(start)
        # addi a6, %lo(start)
        
        addi a0, a0, 82
        jal x1, alloc_node
        addi a1, a1, 1
        
        # Add tail
        addi a6, a6, 4 # Go to other byte
        
        addi a0, zero, 73
        jal x1, alloc_node
        addi a1, a1, 1
        
        jal x0, exit
        
    alloc_node:
        # Save value
        sb a0, 0(a6)
        
        addi a6, a6, 4
        
        # Save next value
        sw a6, 0(a6)
        
        addi a6, a6, 4
        # Save previous value
        sw a6, 0(a6)
        
        jalr x0, x1, 0
    
    add_tail:
        # Adds node (a1) to the head (a0)

    del_node:
        # Deletes node
        
    print_list:
        # Prints linked list
        
    exit:
        # Exit function
        li a7, 10
        ecall
        
    