.data
    START: .word 0
.text
    main:
        # Block size per node
        addi a2, a2, 12
        
        # Load starting address of data at 0xA
        lui a6, %hi(START)
        #addi a6, a6, %lo(START)
        
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
        ##### V ######
        ##############
        
        # Create next node
        addi, t0, zero, 86
        jal x1, alloc_node
        
        # Add node to head
        jal x1, add_tail


        ##############
        ##### I ######
        ##############
        # Create next node
        addi, t0, zero, 73
        jal x1, alloc_node
        
        # Add node to head
        jal x1, add_tail

        
        ##############
        ##### S ######
        ##############
        # Create next node
        addi, t0, zero, 83
        jal x1, alloc_node
        
        # Add node to head
        jal x1, add_tail


        ##############
        ##### C ######
        ##############
        # Create next node
        addi, t0, zero, 67
        jal x1, alloc_node

        # Add node to head
        jal x1, add_tail
        
        # Print list
        jal x1, print_list
        
        ##################
        ##### del V ######
        ##################

        # Load head at 0xA because print_list overwrote it
        lui a6, %hi(START)
        
        # Save head node address
        add a0, a6, zero
        
        # Choose node to delete and store to a1
        addi a1, a0, 12
        
        # Save addresses of .next & .prev of to be deleted node 
        # And delete it
        jal x1, del_node

        
        ##############
        ##### V ######
        ##############
        
        # Create next node
        addi, t0, zero, 86
        jal x1, alloc_node

        # Add node to head
        jal x1, add_tail
        
        # Print new list
        jal x1, print_list
        
        # Exit
        jal x1, exit
        
    alloc_node:        
        # Go to next memory segment
        addi a6, a6, 4
        
        # Load current mem address value
        lw t1, 0(a6)
        
        # Ieskoti tuscios vietos kuri prasideda su 0
        # Checks if current memory block is empty
        bnez t1, alloc_node
        
        # Save address of newly created node
        add s0, a6, zero
        
        # Load newly created node address
        add a1, s0, zero
        
        # Save value
        sb t0, 0(a6)
        
        # Go to next memory segment
        addi a6, a6, 4

        # Save NEXT
        sw a1, 0(a6)
        
        # Go to next memory segment
        addi a6, a6, 4
        
        # Save PREV
        sw a1, 0(a6)
        
        
        # Go back to main
        jalr x0, x1, 0
        
    add_tail:
        ###################
        #### Add nodes ####
        # node count = 2
        # 12 byte blocks for each
        # 24 bytes in total
        # [value] 4 
        # [next]  4
        # [prev]  4
        ##### Add node - a1 - to head node - a0 #####

        # LOAD PREVIOUS TAIL AND HEAD
        # load tail at head's previous
        lw t1, 8(a0) # t1 = head.previous
        # load head at tail's previous
        lw t2, 4(t1) # t2 = tail.next
        
        # UPDATE NEW_NODE'S PREV AND NEXT
        # new_node.next -> head
        sw t2, 4(a1)
	    # new_node.prev -> previous_tail_node 
        sw t1, 8(a1)
        
        # UPDATE HEAD'S PREV TO NEW_NODE
        # head_node.prev -> tail
        sw a1, 8(a0)
        
        # UPDATE BEFORE-TAIL.NEXT AND HEAD.PREVIOUS
        # Save before-tail.next -> new_node
        sw a1, 4(t1)
        # Save head.previous -> new_node
        sw a1, 8(t2)
        
        # Return
        jalr x0, x1, 0
    
    del_node:
        # save previous node: 	previous_node = `del_node.previous`
        # s1 = deleted_node.previous
        # save next node:     	next_node = `del_node.next`
        # s2 = deleted_node.next
        
        # SAVE NODE ADDRESSES

        # Load deleted_node.previous
        lw s1, 4(a1)
        # Load deleted_node.next
        lw s2, 8(a1)

        # DELETE NODE
        sw zero, 0(a1)
        sw zero, 4(a1)
        sw zero, 8(a1)
        
        # UPDATE NODES
        # Update next node's previous to s2
        addi t1, s1, 8
        sw s2, 0(t1)
        
        # Update prev node's next to s1
        addi t1, s2, 4
        sw s1, 0(t1)
        
        # Return
        jalr x0, x1, 0
        
    print_list:
        # PRINT HEAD NODE AND TRAVERSE THE LIST        
        # save head address
        add s3, a0, zero
        
        # print head's value
        lw a0, 0(s3)
        li a7, 11
        ecall
        
        # save head.next
        addi t1, s3, 4
        
        traverse_list:
            # Value address of node
            lw t2, 0(t1)
            
            lw a0, 0(t2)
            li a7, 11
            ecall 
            
            # Get .next value of current node
            addi t1, t2, 4
            
            # Check what next address is
            lw t3, 0(t1)
            
            # Loop again, if head node hasn't been reached
            bne t3, s3, traverse_list
        
        
        # Go back to main
        jalr x0, x1, 0
    
    exit:
        li a7, 10
        ecall
        
    