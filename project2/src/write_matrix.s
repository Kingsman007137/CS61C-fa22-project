.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw ra, 4(sp)
    

    # step 1
    ebreak
    addi sp, sp, -12
    sw a1, 0(sp)
    sw a2, 4(sp)
    sw a3, 8(sp)

    addi a1, x0, 1
    jal fopen
    addi t0, x0, -1
    beq a0, t0, fopen_error

    lw a1, 0(sp)
    lw a2, 4(sp)
    lw a3, 8(sp)
    addi sp, sp, 12


    # step 2
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)

    addi a0, x0, 8
    jal malloc
    add t0, a0, x0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    addi sp, sp, 16

    # call fwrite to write the num of rows and cols
    addi sp, sp, -20
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw t0, 16(sp)

    sw a2, 0(t0)
    sw a3, 4(t0)
    mv a1, t0
    addi a2, x0, 2
    addi a3, x0, 4
    jal fwrite
    addi a2, x0, 2
    bne a0, a2, fwrite_error

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw t0, 16(sp)
    addi sp, sp, 20


    # step 3
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)

    mul s0, a2, a3
    mv a2, s0
    addi a3, x0, 4
    jal fwrite
    bne a0, s0, fwrite_error

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    addi sp, sp, 16


    # step 4
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)

    jal fclose
    bne a0, x0, fclose_error

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    addi sp, sp, 16

    # Epilogue    
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8

    jr ra

fopen_error:
    li a0, 27
    j exit
fclose_error:
    li a0, 28
    j exit
fwrite_error:
    li a0, 30
    j exit
