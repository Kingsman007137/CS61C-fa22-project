.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    
    addi t0, x0, 1
    bge a1, t0, loop_start
    li a0, 36
    j exit
loop_start:
    add t0, x0, a0
    add t1, x0, a1
loop_continue:
    #compute to the t3th of the array
    add t2, x0, a1
    sub t3, t2, t1
    #get t3th value
    slli t3, t3, 2
    add t3, t3, t0
    lw t4, 0(t3)
    
    bge t4, x0, loop_end
    sub t4, t4, t4
    sw t4, 0(t3)
loop_end:
    addi t1, t1, -1
    addi t2, x0, 1
    bge t1, t2, loop_continue

    # Epilogue


    jr ra
