.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    addi t0, x0, 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    beq a2, a4, outer_loop_start
error:
    li a0, 38
    j exit
    # Prologue
outer_loop_start:
    #t0 counts the current row of m0
    addi t0, t0, -1
    add t1, x0, a1
    add t5, x0, a5
    add t6, x0, a6
outer_loop_continue:
    #m1 col index, reset at the start of every outer loop
    add t2, x0, x0

inner_loop_start:
    #compute m1 start addr
    slli t2, t2, 2
    add t2, t2, a3
    # Prologue
    addi sp, sp, -44
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw t0, 20(sp)
    sw t1, 24(sp)
    sw t2, 28(sp)
    sw t5, 32(sp)
    sw t6, 36(sp)
    sw ra, 40(sp)
    
    #a0, a2 don't need to change
    mv a1, t2
    addi a3, x0, 1
    add a4, x0, t5
    jal dot
    #t6 will change, always be the current start of matrix d
    lw t6, 36(sp)
    sw a0, 0(t6)

    # Epilogue
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw t0, 20(sp)
    lw t1, 24(sp)
    lw t2, 28(sp)
    lw t5, 32(sp)
    lw ra, 40(sp)
    addi sp, sp, 44

inner_loop_end:
    #remake the t2 to the m1 col num
    sub t2, t2, a3
    srli t2, t2, 2
    addi t2, t2, 1
    # change the start of d
    addi t6, t6, 4
    blt t2, t5, inner_loop_start

outer_loop_end:
    addi t0, t0, 1
    #a0 is always the start of m0
    slli t3, a2, 2
    add a0, a0, t3
    blt t0, a1, outer_loop_continue
    # Epilogue

    jr ra
