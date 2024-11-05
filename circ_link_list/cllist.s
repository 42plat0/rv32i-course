.data
    START: .word 0

.text
    main:
        # Letter count
        li t2, 0
        # Block size per node
        addi a2, a2, 12
        
        lui a6, %hi(START)
        # add a6, %lo(START)
        
        addi a6, a6, -4
        
        ##############
        ##### R ######
        ##############
        # Head node
        addi, t0, zero, 82
        jal x1, alloc_node
        
        # Update letter count
        addi t2, t2, 1
        
        ##############
        ##### I ######
        ##############
        
        # Create next node
        addi, t0, zero, 73
        jal x1, alloc_node
        # Update letter count
        addi t2, t2, 1
        # Add node to head
        jal x1, add_tail
        
        ##############
        ##### S ######
        ##############
        # Create next node
        addi, t0, zero, 83
        jal x1, alloc_node
        # Update letter count
        addi t2, t2, 1
        # Add node to head
        jal x1, add_tail
        
        # Print list
        jal x1, print_list
        
        jal x0, exit
    
    alloc_node:
        # Go to next memory segment
        addi a6, a6, 4
        add a1, a6, zero # Save current address of node
        
        # Save value
        sw t0, 0(a6)
        # Go to next memory segment
        addi a6, a6, 4
        # Save NEXT
        sw t0, 0(a6)
        # Go to next memory segment
        addi a6, a6, 4
        # Save PREV
        sw t0, 0(a6)
        # Go back to main
        jalr x0, x1, 0
        
    ###################
    #### Add nodes ####
    # node count = 2
    # 12 byte blocks for each
    # 24 bytes in total
    # [value] 4 
    # [next]  4
    # [prev]  4
    add_tail:
        ##### Add node - a1 - to head node - a0 #####
        
        # Get -12
        li t5, -1
        mul t6, a2, t5
        
        # Calculate distance to head node from current node
        addi t3, t2, -1 # (Letter count - 1) * 2
        mul t1, t3, t6 # Distance
        
        # Head node
        add a0, a1, t1
        # Add current at a1 to a0.next
        sw a1, 4(a0) # NEXT
        sw a1, 8(a0) # PREVIOUS
        # Add head node at a0 to prev at current 
        sw a0, 4(a1) # NEXT
        sw a0, 8(a1) # PREVIOUS
        
        # Go back to main
        jalr x0, x1, 0
        
    print_list:
        add t0, a0, zero
        
        lw a0, 0(t0)
        li a7, 11
        ecall
        
        lw a0, 12(t0)
        li a7, 11
        ecall
    
    del_node:
        
    exit:
        li a7, 10
        ecall
        
    