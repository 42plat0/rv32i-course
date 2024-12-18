.data
    START: .word 0
.text
    main:
        # Load starting address of data at 0xA
        lui a6, %hi(START)
        #addi a6, a6, %lo(START)
        
        # Go back a byte
        # And increment a6 by 1 searching for empty memory space to write to
        addi a6, a6, -1
        
        # Save head node address
        addi a0, a6, 1
        
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
        addi a6, a6, -1

        # Save head node address
        addi a0, a6, 1
        
        # Choose node to delete and store to a1
        # Choosing by storing address of head.next (2nd node = V)
        lw a1, 1(a0)
        
        # Save node_to_delete.next & node_to_delete.prev addresses 
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
        addi a6, a6, 1
        
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
        addi a6, a6, 1

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
        ##### Add node - a1 - to head node - a0 #####

        # LOAD PREVIOUS TAIL AND HEAD
        # load tail at head's previous
        lw t1, 5(a0) # t1 = head.previous
        # load head at tail's previous
        lw t2, 1(t1) # t2 = tail.next
        
        # UPDATE NEW_NODE'S PREV AND NEXT
        # new_node.next -> head
        sw t2, 1(a1)
	    # new_node.prev -> previous_tail_node 
        sw t1, 5(a1)
        
        # UPDATE HEAD'S PREV TO NEW_NODE
        # head_node.prev -> tail
        sw a1, 5(a0)
        
        # UPDATE BEFORE-TAIL.NEXT AND HEAD.PREVIOUS
        # Save before-tail.next -> new_node
        sw a1, 1(t1)
        # Save head.previous -> new_node
        sw a1, 5(t2)
        
        # Return
        jalr x0, x1, 0
    
    del_node:
        # Deleted node contains addresses to next and previous node
        # So we use these addresses to wire nodes in between
        # !Does not account for head node being deleted
        
        # save previous node: 	previous_node = `del_node.previous`
        # s1 = deleted_node.previous
        # save next node:     	next_node = `del_node.next`
        # s2 = deleted_node.next
        
        # Return -1
        addi s4, zero, -1
        # Exit program with code 1
        beq a1, zero, error_exit
        
        # SAVE BETWEEN NODE ADDRESSE THAT ARE NEXT TO DELETED NODE
        # Load deleted_node.previous
        lw s1, 1(a1)
        # Load deleted_node.next
        lw s2, 5(a1)

        # DELETE NODE
        sb zero, 0(a1)
        sw zero, 1(a1)
        sw zero, 5(a1)
        
        # CONNECT NODES IN BETWEEN
        
        # UPDATE NODES
        # Update next node's previous to s2
        addi t1, s1, 5
        sw s2, 0(t1)
        
        # Update prev node's next to s1
        addi t1, s2, 1
        sw s1, 0(t1)
        
        # Return head node on success
        add s0, a0, zero
        
        # Return
        jalr x0, x1, 0
        
    print_list:
        # PRINT NODE VAL BY TRAVERSING THE LIST
        # LOAD HEAD FROM TAIL.NEXT
        # LOAD ADDRESS AT .NEXT AND LOAD ASCII VALUE
        # AT THAT ADDRESS
                
        # get head.previous (-> tail) tail value address
        lw s3, 5(a0)
        
        # save tail value address
        add t1, s3, zero
        
        # instantiate written byte count to return
        add s0, zero, zero
        add t4, s5, zero
        
        traverse_list:
            # get curr_node.next value (address) at t1
            addi t1, t1, 1
            
            # load node value at t1.next
            lw t3, 0(t1)
            
            # Print ascii char at t3
            lb a0, 0(t3)
            li a7, 11
            ecall 
            
            # save curr_node
            # and increment when loop starts
            # to get curr_node.next
            # Needed to check whether 
            # we reached starting node
            addi t1, t3, 0
            
            # ERROR HANDLING
            add t2, a0, zero
            
            # Return -1
            addi s0, zero, -1
            
            # Exit program with code 1
            beq t2, zero, error_exit
            
            # Save bytes written node when successful
            addi t4, t4, 1
            
            # Loop again, if printed_node is not starting point (tail)
            bne t1, s3, traverse_list
        
        # Return bytes written in total
        add s0, s0, t4
        
        # Go back to main
        jalr x0, x1, 0
    
    error_exit:
        li a0, 1
        li a7, 93
        ecall
        
    exit:
        li a7, 10
        ecall
        
    