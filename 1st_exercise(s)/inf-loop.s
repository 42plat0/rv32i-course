.data
str: .string "Hello, world!"
newline: .string "\n"
otherstr: .string "Nope, world!"

.text
    li x22, 10
    li x23, 11
    bne, x22, x23, Main
    
    # Will not get called
    la a0, otherstr
    li a7 4
    ecall

    Main:
        la a0, str
        li a7, 4
        
        la a0, newline
        li a7, 4
        ecall
        
        # Instantiates infinite loop
        jal x1, Main
