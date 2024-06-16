####### Hanoi Towers #######

#######    Author    #######
#  Missael Cortes

####### C Code #######
# #include <stdio.h>
 
# // C recursive function to solve tower of hanoi puzzle
# void towerOfHanoi(int n, char from_rod, char to_rod, char aux_rod)
# {
#     if (n == 1)
#     {
#         printf("\n Move disk 1 from rod %c to rod %c", from_rod, to_rod);
#         return;
#     }
#     towerOfHanoi(n-1, from_rod, aux_rod, to_rod);
#     printf("\n Move disk %d from rod %c to rod %c", n, from_rod, to_rod);
#     towerOfHanoi(n-1, aux_rod, to_rod, from_rod);
# }
 
# int main()
# {
#     int n = 4; // Number of disks
#     towerOfHanoi(n, 'A', 'C', 'B');  // A, B and C are names of rods
#     return 0;
# }
# https://www.geeksforgeeks.org/c-program-for-tower-of-hanoi-2/
####### C Code #######

.eqv N, 3
.eqv OFFSET, 0x20
.eqv DATA_ADDR, 0x10010
.eqv WORD, 4

.text

main:

    # Counter
    addi s10, zero, 0
    # OFFSET
    addi s11, zero, OFFSET
    # N Disks
    addi s0, zero, N
    # Offset between each tower
    addi t0, zero, WORD

    # Towers A - B - C
    lui s1, DATA_ADDR	# A -> SRC
    addi s1, s1, 0
    add s2, s1, t0		# B -> AUX
    add s3, s2, t0		# C -> DST

    # Move B and C pointer to the start of stack
    mul t0, s0, s11		# start = N * OFFSET = N * 0x20
    add s2, s2, t0		# s2 -> s2 + start
    add s3, s3, t0		# s2 -> s2 + start
    
    # Initialize Tower A with N disks
    addi t0, zero, 0    # i = 0
    addi t1, s0, -1      # temp_n = n - 1
    for: blt t1, t0, endfor # i >= temp_n
    # {
        add t3, zero, s1    # Temp pointer to Tower A t3 -> s1
        mul t2, t0, s11     # Calc Index = i * OFFSET
        add t3, t3, t2      # Calc mem_addr to store "i"  t3 = t3 - Index
        addi t4, t0, 1
        sw t4, 0(t3)        # Store disk(i) to mem_addr
    # }

    # i++
    addi t0, t0, 1
    jal for

    endfor:
        jal ra, hanoi		# hanoi(n-1, SRC, DST, AUX)
        jal zero, end

hanoi:	
    addi t0, zero, 1
    if:	bne s0, t0, else
        sw zero, 0(s1)			# Del disk from SRC
        addi s1, s1, OFFSET		# MV SRC -> SRC + OFFSET
        addi s3, s3, -OFFSET	# MV DST -> DST - OFFSET
        sw s0, 0(s3)			# Add disk to DST
        
        addi s10, s10, 1		# counter = counter + 1
        
        jalr ra	
    
    else:	
    # start recursive call
        addi sp, sp, -WORD		# Push ra
        sw ra, 0(sp)

        addi sp, sp, -WORD		# Push s0
        sw s0, 0(sp)
        
        addi s0, s0, -1 # n = n - 1

        add t1, s2, zero # TEMP -> AUX
        add s2, s3, zero # AUX -> DST
        add s3, t1, zero # DST -> TEMP

        jal ra, hanoi		# hanoi(n-1, SRC, AUX, DST)

        add t1, s2, zero # TEMP -> AUX
        add s2, s3, zero # AUX -> DST
        add s3, t1, zero # DST -> TEMP
        
        lw s0, 0(sp)		# Pop s0
        addi sp, sp, WORD
        
        lw ra, 0(sp)		# Pop ra
        addi sp, sp, WORD
    # end recursive call

        sw zero, 0(s1)			# Del disk from SRC
        addi s1, s1, OFFSET		# MV SRC -> SRC + OFFSET
        addi s3, s3, -OFFSET	# MV DST -> DST - OFFSET
        sw s0, 0(s3)			# Add disk to DST
        
        addi s10, s10, 1			# counter = counter + 1
        
    # start recursive call
        addi sp, sp, -WORD		# Push ra
        sw ra, 0(sp)

        addi sp, sp, -WORD		# Push s0
        sw s0, 0(sp)
        
        addi s0, s0, -1 # n = n - 1

        add t1, s1, zero # TEMP -> SRC
        add s1, s2, zero # SRC -> AUX
        add s2, t1, zero # AUX -> TEMP

        jal ra, hanoi		# hanoi(n-1, AUX, DST, SRC)

        add t1, s1, zero # TEMP -> SRC
        add s1, s2, zero # SRC -> AUX
        add s2, t1, zero # AUX -> TEMP
        
        lw s0, 0(sp)		# Pop s0
        addi sp, sp, WORD
        
        lw ra, 0(sp)		# Pop ra
        addi sp, sp, WORD
    # end recursive call
        
        jalr ra

end: nop
