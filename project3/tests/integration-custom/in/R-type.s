addi t0, x0, -1
addi t1, x0, 7

add t2, t0, t1

sub s0, t0, t1

addi s0, x0, 9
and a0, s0, t1 

or a0, s0, t1

xor t1, t1, s0

addi t1, x0, 3
sll s1, s0, t1 

srl s1, s0, t1

addi t0, x0, -17
sra  t0, t0, t1

slt a0, t0, t1

addi t0, x0, 3
addi t1, x0, 6
mul a0, t1, t0

add s1, t0, t1
sub t2, t1, t0
addi s0, s2, -50

mulh a0, s0, s1
mulh a0, s0, s0

addi t0, x0, 99
add t1, t0, t0
mulhu t1, t1, t1