.section .data:
    newline: .string "\n"
li x6, -1 # Print argument
li x7, 7 # While terminator
main:
    li x5, -1 # Counter which goes up
    addi x5, x6, 1
loop:
    addi x5, x5, 1
    blt x7, x5, exit
    beq x5, x6, loop
    li a7, 1
    add a0, x5, zero
    ecall
    bne x5, x7, loop
print_newline:
    la a0, newline
    li a7, 4
    ecall
    beq x0, x0, main
exit:
    li a7, 10
    ecall
