.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
check_num:
    addi t0, x0, 1
    bge a2, t0, check_stride
    li a0, 36
    j exit
check_stride:
    blt a3, t0, error
    bge a4, t0, loop_start
error:
    li a0, 37
    j exit
loop_start:
    #t0 store the sum
    add t0, x0, x0
    add t1, x0, a2
loop_continue:
    #get the t2th value of the first array
    sub t2, a2, t1
    mul t2, t2, a3
    slli t2, t2, 2
    add t2, t2, a0
    lw t4, 0(t2)
    #the second array is almost the same
    sub t2, a2, t1
    mul t2, t2, a4
    slli t2, t2, 2
    add t2, t2, a1
    lw t5, 0(t2)

    mul t4, t4, t5
    add t0, t0, t4
loop_end:
    addi t1, t1, -1
    addi t2, x0, 1
    bge t1, t2, loop_continue
    mv a0, t0

    # Epilogue


    jr ra
