.data
    START: .word 0

.text
    main:
        # Block size per node
        addi a2, a2, 12
        
        # Load starting address of data at 0xA
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
        ##### V ######
        ##############
        
        # Create next node
        addi, t0, zero, 86
        jal x1, alloc_node

        # Add node to head
        jal x1, add_tail
        
        # Update previous node
        jal x1, update_node_before_tail
        
        ##############
        ##### I ######
        ##############
        
        # Create next node
        addi, t0, zero, 73
        jal x1, alloc_node

        # Add node to head
        jal x1, add_tail
        
        # Update previous node
        jal x1, update_node_before_tail
        
        ##############
        ##### S ######
        ##############
        # Create next node
        addi, t0, zero, 83
        jal x1, alloc_node

        # Add node to head
        jal x1, add_tail
        
        # Update previous node
        jal x1, update_node_before_tail
        
        ##############
        ##### C ######
        ##############
        # Create next node
        addi, t0, zero, 67
        jal x1, alloc_node

        # Add node to head
        jal x1, add_tail
        
        # Update previous node
        jal x1, update_node_before_tail
        
        # Print list
        jal x1, print_list
        
        ##############
        # del node V #
        ##############
        lui a0, %hi(START)
        add a1, a0, a2 # Get second node from head at a0
        jal x1, del_node
        
        # Update nodes
        jal x1, update_node_after_del
        
        # Iterpti i istrinto node'o vieta kaip taila ir sulinkinti tinkamai
        # Pvz. N1 -> N2 -> N3 -> N4
        # Pvz. N1 -> *deleted* -> N3 -> N4
        # Tai. N1 -> *N5* -> N3 -> N4
        # Tai. N1 -> N5 -> N3 -> N4 -> *N6*
        ######################################
        # Problema su tailo addinimu
        ##############
        ##### C ######
        ##############
        
        # Load starting address of data at 0xA
        lui a6, %hi(START)
        # add a6, %lo(START)
        
        addi a6, a6, -4
        
        # Create next node
        addi, t0, zero, 63
        jal x1, alloc_node
        
        # Add node to head
        jal x1, add_tail
        
        # Update previous node
        jal x1, update_node_before_tail
        
        # Exit
        jal x0, exit
    
    alloc_node:
        # Ieskoti tuscios vietos kuri prasideda su 0
        
        # Go to next memory segment
        addi a6, a6, 4
        
        # Load current mem address value
        lw t1, 0(a6)
        
        # Checks if current memory block is empty
        bnez t1, alloc_node
        
        # Save current address of node
        add a1, a6, zero 
        
        # Save value
        sb t0, 0(a6)
        
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
        
        # Issaugoti naujo NODe addressa i S0
        
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
    
    del_node:
        sw zero, 0(a1)
        sw zero, 4(a1)
        sw zero, 8(a1)
        
        
        jalr x0, x1, 0
    
    update_node_after_del:
        # After deleting node at a1 (Node 2)
        # Change previous node next at a1 - 12 (Node 1)
        # And next node at a1 + 12 (Node 3)
        # .next and .prev stored addresses
        
        # Get -12
        li t5, -1
        mul t6, a2, t5 # 12 * -1
        
        # Node 1
        add t0, a1, t6
        
        # Node 3
        add t1, a1, a2
        
        # Node_1.next -> Node3
        sw t1, 4(t0)
        
        # Node_3.previous -> Node1
        sw t0, 8(t1)
        
        jalr x0, x1, 0
    
    update_node_before_tail:
        # After adding new tail
        # Update previous node to point to tail (new node)
        
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
        
    exit:
        li a7, 10
        ecall
        
    