.data
    str: .string "abcdefghz"

.text
    # Load address to register
    li t0, 0x10000000
    
    la a2, str
    print:
    add a0, a2, zero
    li a7, 4
    ecall