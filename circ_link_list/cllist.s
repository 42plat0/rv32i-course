.data
    START: .word 0

.text
    main:
        # Block size per node
        addi a2, a2, 12
        
        lui a6, %hi(START)
        # add a6, %lo(START)
        
        addi a6, a6, -4
        
        # Save head node address
        addi a0, a6, 4
        
        ##############
        ##### R ######
        ##############
        # Head node
        addi, t0, zero, 82
        jal x1, alloc_node
        
        ##############
        ##### I ######
        ##############
        
        # Create next node
        addi, t0, zero, 73
        jal x1, alloc_node

        # Add node to head
        jal x1, add_tail
        
        # Update previous node
        jal x1, update_node
        
        ##############
        ##### S ######
        ##############
        # Create next node
        addi, t0, zero, 83
        jal x1, alloc_node

        # Add node to head
        jal x1, add_tail
        
        # Update previous node
        jal x1, update_node
        
        ##############
        ##### C ######
        ##############
        # Create next node
        addi, t0, zero, 67
        jal x1, alloc_node

        # Add node to head
        jal x1, add_tail
        
        # Update previous node
        jal x1, update_node
        
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
        sw a6, 0(a6)
        # Get next node address
        # addi t6, a6, 8

        # Go to next memory segment
        addi a6, a6, 4
        # Save PREV
        sw a6, 0(a6)
        
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
        mul t6, a2, t5 # 12 * -1
        
        # new_node.next -> head
        sw a0, 4(a1)
	    # new_node.prev -> previous_node (perrasys apatine eilute!)
        add t0, a1, t6 # Previous node
        sw t0, 8(a1)
        # head_node.prev -> tail
        sw a1, 8(a0)
        
        # Go back to main
        jalr x0, x1, 0
        
    update_node:
        # Get -12
        li t5, -1
        mul t6, a2, t5 # 12 * -1
        
        # update previous node 
        # previous_node.next -> tail
        add t0, a1, t6
        sw a1, 4(t0)
        
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

        lw a0, 24(t0)
        li a7, 11
        ecall

        lw a0, 36(t0)
        li a7, 11
        ecall

        lw a0, 48(t0)
        li a7, 11
        ecall
        # Go back to main
        jalr x0, x1, 0
    
    del_node:
        
    exit:
        li a7, 10
        ecall
        
    