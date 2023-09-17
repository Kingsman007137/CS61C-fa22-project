xori t0, x0, 7

ori t1, x0, 9

addi s0, t0, 9

andi s1, s0, 7

slli s1, t0, 2

srli t2, t0, 2

srai t0, t0, 2

ori t0, x0, -1
slti a0, t0, 5

addi a0, a0, -9
srli t2, a0, 15
addi t0, x0, -15
andi s0, t0, -25

srai t2, a0, 0