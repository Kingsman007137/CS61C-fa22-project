addi s0, x0, -5
addi t0, x0, 1

sub s1, s0, t0	# -6
mul t2, x0, x0

beq s0, s1, end	

Loop:  
	sub t2, t2, t0
	bne t2, s1, Loop	
	bne t0, x0, label2
	
label4:
	bgeu t0, s1, end
	bgeu s1, x0, label3 
	
label2:
	mul s1, s0, s0
	add t2, x0, x0
Loop2:
	addi t2, t2, 5
	bge s1, t2, Loop2
	bgeu s1, t0, label4
		
label3: 
	bltu t0, s1, end
	and t0, t0, t1
	
end:
	mul a0, s0, s1
    