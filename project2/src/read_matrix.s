.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw ra, 12(sp)
    

    # step 1
    addi sp, sp, -8
    sw a1, 0(sp)
    sw a2, 4(sp)

    addi a1, x0, 0
    jal fopen
    addi t0, x0, -1
    beq a0, t0, fopen_error

    lw a1, 0(sp)
    lw a2, 4(sp)
    addi sp, sp, 8
    

    # step 2
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    # should read 8 bytes but not 2
    addi t0, x0, 8
    mv a0, t0
    jal malloc
    beq a0, x0, malloc_error
    mv t0, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # call fread to read num of rows
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    # also need to store the pointer
    sw t0, 12(sp)

    mv a1, t0
    addi a2, x0, 8
    jal fread
    addi a2, x0, 8
    bne a0, a2, fread_error

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    addi sp, sp, 16

    lw s0, 0(t0) # rows
    lw s1, 4(t0) # cols
    sw s0, 0(a1)
    sw s1, 0(a2)
    
    # step 3
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    mv t1, s0
    mv t2, s1
    mul a0, t1, t2
    slli a0, a0, 2
    mv s2, a0
    jal malloc
    beq a0, x0, malloc_error
    mv t2, a0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12
    

    # step 4
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    # also need to store the pointer
    sw t2, 12(sp)

    mv a1, t2
    add a2, x0, s2
    jal fread
    add a2, x0, s2
    bne a0, a2, fread_error
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t2, 12(sp)
    addi sp, sp, 16

    # step 5
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw t2, 12(sp)

    jal fclose
    bne a0, x0, fclose_error

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t2, 12(sp)
    addi sp, sp, 16

    # step 6
    addi a0, t2, 0

    # Epilogue    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    

    jr ra

malloc_error:
    li a0, 26
    j exit
fopen_error:
    li a0, 27
    j exit
fclose_error:
    li a0, 28
    j exit
fread_error:
    li a0, 29
    j exit
