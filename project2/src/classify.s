.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    # Prologue
    addi sp, sp, -36
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw ra, 32(sp)

    addi t0, x0, 5
    bne a0, t0, argc_error

    # Read pretrained m0
    ebreak # 1
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    addi a0, x0, 8
    jal malloc
    beq a0, x0, malloc_error
    mv s3, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    ebreak # 2
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    lw a0, 4(a1)
    mv a1, s3
    addi a2, a1, 4
    jal read_matrix
    mv s0, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12


    # Read pretrained m1
    ebreak # 3
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    addi a0, x0, 8
    jal malloc
    beq a0, x0, malloc_error
    mv s4, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    ebreak # 4
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    lw a0, 8(a1)
    mv a1, s4
    addi a2, a1, 4
    jal read_matrix
    mv s1, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12


    # Read input matrix
    ebreak # 5
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    addi a0, x0, 8
    jal malloc
    beq a0, x0, malloc_error
    mv s5, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    ebreak # 6
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    lw a0, 12(a1)
    mv a1, s5
    addi a2, a1, 4
    jal read_matrix
    mv s2, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12


    # Compute h = matmul(m0, input)
    # m0: n * m, input: m * k ==> h: n * k
    ebreak # 7
    lw t1, 0(s3)
    lw t2, 4(s5)

    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    # malloc space to fit h
    mul a0, t1, t2
    slli a0, a0, 2
    jal malloc
    beq a0, x0, malloc_error
    mv a6, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    ebreak # 8
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)

    mv a0, s0
    lw a1, 0(s3)
    lw a2, 4(s3)
    mv a3, s2
    lw a4, 0(s5)
    lw a5, 4(s5)
    jal matmul

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28

    # s6 store the h
    mv s6, a6


    # Compute h = relu(h)
    ebreak # 9
    lw t1, 0(s3)
    lw t2, 4(s5)

    addi sp, sp, -8
    sw a0, 0(sp)
    sw a1, 4(sp)

    mv a0, s6
    mul a1, t1, t2
    jal relu

    lw a0, 0(sp)
    lw a1, 4(sp)
    addi sp, sp, 8


    # Compute o = matmul(m1, h)
    # m1: n * m, input: m * k ==> o: n * k
    lw t1, 0(s4)
    lw t2, 4(s5)

    ebreak # 10
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    # malloc space to fit o
    mul a0, t1, t2
    slli a0, a0, 2
    jal malloc
    beq a0, x0, malloc_error
    mv a6, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    ebreak # 11
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)

    mv a0, s1
    lw a1, 0(s4)
    lw a2, 4(s4)
    mv a3, s6
    lw a4, 0(s3)
    lw a5, 4(s5)
    jal matmul

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28

    # s7 store the o
    mv s7, a6


    # Write output matrix o
    ebreak # 12
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    lw a0, 16(a1)
    mv a1, s7
    lw a2, 0(s4)
    lw a3, 4(s5)
    jal write_matrix

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12


    # Compute and return argmax(o)
    ebreak # 13
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    mv a0, s7
    lw a1, 0(s4)
    lw a2, 4(s5)
    mul a1, a1, a2
    jal argmax
    mv t0, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12


    # If enabled, print argmax(o) and newline
    ebreak # 14
    addi t1, x0, 1
    beq a2, t1, done

    ebreak # 15
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw t0, 12(sp)

    mv a0, t0
    jal print_int
    # ascii code of '\n'
    addi a0, x0, 10
    jal print_char

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    addi sp, sp, 16
     
done:
    ebreak # 16
    mv a0, t0

    # Epilogue    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 36

    jr ra

malloc_error:
    li a0, 26
    j exit
argc_error:
    li a0, 31
    j exit
