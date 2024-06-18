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

.text

main:
    # RGB vars
    addi s8, zero, 31    # COLOR_MULTIPLIER
    addi s9, zero, 255   # MAX_COLOR_VALUE
    
    # Counter
    addi s10, zero, 0
    # OFFSET
    addi s11, zero, 0x20
    # N Disks
    addi s0, zero, 3
    # Offset between each tower
    addi t0, zero, 4

    # Towers A - B - C
    lui s1, 0x10001	    # A -> SRC
    addi s1, s1, 0
    add s2, s1, t0		# B -> AUX
    add s3, s2, t0		# C -> DST
    
    # LEDs A - B - C
    lui s4, 0xF0000       # A -> SRC
    addi s5, s4, 4        # B -> AUX
    addi s6, s5, 4        # C -> DST

    # Move B and C pointer to the start of stack
    mul t0, s0, s11		# start = N * OFFSET = N * 0x20
    add s2, s2, t0		# s2 -> s2 + start
    add s3, s3, t0		# s3 -> s3 + start
    
    add s5, s5, t0		# s2 -> s2 + start
    add s6, s6, t0		# s3 -> s3 + start
    
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
        
        add t5, zero, s4    # Temp pointer to Tower A t5 -> s4
        add t5, t5, t2      # Calc mem_addr to store "i"  t5 = t5 - Index
        
        # Calculate color value for disk i
        mul t2, t4, s8      # t2 = t2 * COLOR_MULTIPLIER
        rem t2, t2, s9      # t2 = t2 % MAX_COLOR_VALUE (to fit within color range)
        
        # Generate RGB value (example: R = t2, G = 0, B = 0)
        addi t3, zero, 60       # Green component (example: set to 60)
        addi t4, zero, 120      # Blue component (example: set to 120)
        
        slli t2, t2, 16         # Shift Red component to the most significant byte
        slli t3, t3, 8          # Shift Green component to the second byte
        
        or t2, t2, t3           # Combine Red and Green components
        or t2, t2, t4           # Combine with Blue component
        
        sw t2, 0(t5)        # Store color value
        
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
        addi s1, s1, 0x20		# MV SRC -> SRC + OFFSET
        addi s3, s3, -0x20	    # MV DST -> DST - OFFSET
        sw s0, 0(s3)			# Add disk to DST
        
        lw t3, 0(s4)            # Load color t3 <- SRC
        sw zero, 0(s4)          # Set 0 to SRC
        addi s4, s4, 0x20       # MV SRC -> SRC + OFFSET
        addi s6, s6, -0x20      # MV DST -> DST + OFFSET
        sw t3, 0(s6)            # Set color t3 -> DST
        
        addi s10, s10, 1		# counter = counter + 1
        
        jalr ra	
    
    else:	
    # start recursive call
        addi sp, sp, -4		# Push ra
        sw ra, 0(sp)

        addi sp, sp, -4		# Push s0
        sw s0, 0(sp)
        
        addi s0, s0, -1 # n = n - 1

        ## Towers ##
        # Data
        add t1, s2, zero # TEMP -> AUX
        add s2, s3, zero # AUX -> DST
        add s3, t1, zero # DST -> TEMP
        
        # LEDs
        add t2, s5, zero # TEMP -> AUX
        add s5, s6, zero # AUX -> DST
        add s6, t2, zero # DST -> TEMP

        jal ra, hanoi		# hanoi(n-1, SRC, AUX, DST)

        # Data
        add t1, s2, zero # TEMP -> AUX
        add s2, s3, zero # AUX -> DST
        add s3, t1, zero # DST -> TEMP
        
        # LEDs
        add t2, s5, zero # TEMP -> AUX
        add s5, s6, zero # AUX -> DST
        add s6, t2, zero # DST -> TEMP
        ## Towers ##
        
        lw s0, 0(sp)		# Pop s0
        addi sp, sp, 4
        
        lw ra, 0(sp)		# Pop ra
        addi sp, sp, 4
    # end recursive call

        sw zero, 0(s1)			# Del disk from SRC
        addi s1, s1, 0x20		# MV SRC -> SRC + OFFSET
        addi s3, s3, -0x20	    # MV DST -> DST - OFFSET
        sw s0, 0(s3)			# Add disk to DST
        
        lw t3, 0(s4)            # Load color t3 <- SRC
        sw zero, 0(s4)          # Set 0 to SRC
        addi s4, s4, 0x20       # MV SRC -> SRC + OFFSET
        addi s6, s6, -0x20      # MV DST -> DST + OFFSET
        sw t3, 0(s6)            # Set color t3 -> DST
        
        addi s10, s10, 1		# counter = counter + 1
        
    # start recursive call
        addi sp, sp, -4		# Push ra
        sw ra, 0(sp)

        addi sp, sp, -4		# Push s0
        sw s0, 0(sp)
        
        addi s0, s0, -1 # n = n - 1

        ## Towers ##
        #Data
        add t1, s1, zero # TEMP -> SRC
        add s1, s2, zero # SRC -> AUX
        add s2, t1, zero # AUX -> TEMP
        
        # LEDs
        add t2, s4, zero # TEMP -> SRC
        add s4, s5, zero # SRC -> AUX
        add s5, t2, zero # AUX -> TEMP

        jal ra, hanoi		# hanoi(n-1, AUX, DST, SRC)

        # Data
        add t1, s1, zero # TEMP -> SRC
        add s1, s2, zero # SRC -> AUX
        add s2, t1, zero # AUX -> TEMP
        
        # LEDs
        add t2, s4, zero # TEMP -> SRC
        add s4, s5, zero # SRC -> AUX
        add s5, t2, zero # AUX -> TEMP
        ## Towers ##
        
        lw s0, 0(sp)		# Pop s0
        addi sp, sp, 4
        
        lw ra, 0(sp)		# Pop ra
        addi sp, sp, 4
    # end recursive call
        
        jalr ra

end: nop
