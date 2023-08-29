.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    
    addi t0, x0, 1
    bge a1, t0, loop_start
    li a0, 36
    j exit
loop_start:
ebreak
    add t0, x0, a0
    add t1, x0, a1
    #t2 store the largest value
    lw t2, 0(t0)
    #t3 store the return value: index
    add t3, x0, x0
loop_continue:
    #compute to the t5th of the array
    add t4, x0, a1
    sub t5, t4, t1
    #get t5th value
    slli t5, t5, 2
    add t5, t5, t0
    lw t6, 0(t5)

    bge t2, t6, loop_end
    mv t2, t6
    sub t3, t5, t0
    srli t3, t3, 2
loop_end:
    addi t1, t1, -1
    addi t4, x0, 1
    bge t1, t4, loop_continue
    mv a0, t3
    
    # Epilogue
    
    jr ra
