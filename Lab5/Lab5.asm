#Spring20 Lab5 Template File
##########################################################################
# Created by: Lao, Justin
# jlao3
# 5 June 2020
#
# Assignment: Lab 5: Functions and Graphics
# CSE 12, Computer Systems and Assembly Language
# UC Santa Cruz, Spring 2020
#
# Description: Implement functions that perform some primitive graphics 
#		operations on a small simulated display. These functions
#		will clear the entire display to a color, display a filled 
#		colored circle and display an unfilled colored circle using 
#		a memory-mapped bitmap graphics display in MARS.
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################

# Macro that stores the value in %reg on the stack 
#  and moves the stack pointer.
##########################################################################
# Psuedocode:
#	move stack pointer down
#	store %reg into stack
##########################################################################
.macro push(%reg)
	subi	$sp, $sp, 4
	sw	%reg, ($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
##########################################################################
# Psuedocode:
#	load value pointed by stack to %reg
#	move stack pointer up
##########################################################################
.macro pop(%reg)
	lw	%reg, ($sp)
	addi	$sp, $sp, 4
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
##########################################################################
# Psuedocode:
#	shiftRightLogical 0x00XX00YY
#		16 bit shift since HEX is 4 bytes each, thus %x = 0x000000XX
#	andi mask operation
#		use 0x000000FF to mask with 0x00XX00YY thus %y = 0x000000YY
##########################################################################
.macro getCoordinates(%input %x %y)
	srl	%x, %input, 16		#Each hex is 4 bits, thus shift by 4X4, which is 16
	andi	%y, %input, 0xFF		#Masking with AND operations, eliminates every hex except Y coordinate
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
##########################################################################
# Psuedocode:
#	shiftLeftLogical of 0x000000XX which is %0x00XX0000 to %output
#	or mask operation, opposite of andi, thus 0x00XX0000 OR 0x000000YY = 0x00XX00YY to %output
##########################################################################
.macro formatCoordinates(%output %x %y)
	sll	%output, %x, 16
	or	%output, %y, %output
.end_macro 


.data
originAddress: .word 0xFFFF0000

.text
j done
    
    done: nop
    li $v0 10 
    syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
#Clear_bitmap: Given a color, will fill the bitmap display with that color.
#   Inputs:
#    $a0 = Color in format (0x00RRGGBB) 
#   Outputs:
#    No register outputs
#    Side-Effects: 
#    Colors the Bitmap display all the same color
#*****************************************************
##########################################################################
# Psuedocode:
#	load origin address
#	load final address
#	loop until and on  final address
#		make current address into color
#		increment address
##########################################################################
clear_bitmap: nop
	push($ra)
	push($a0)
	lw $t1, originAddress		#$t1 is pointer to originAddress
	li $t2, 0xFFFFFFFC
	loop:
		sw $a0, ($t1)
		la $t1, 4($t1)
		ble $t1, $t2, loop
	jr $ra
	
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*****************************************************
##########################################################################
# Psuedocode:
#	obtain coordinates
#		algorithm to get desired address value
#		add with originAddress
#		store color into desired address
##########################################################################
draw_pixel: nop								#USES REGISTERS $t0 - $t5, $a0 - $a1
	getCoordinates($a0, $t0, $t1)					#isolate coordinates into two separate entities
	mul 	$t1, $t1, 128						#multiply y coordinate by 128 (width)
	mflo 	$t2							#load result into arbitrary register
	add 	$t2, $t2, $t0						#add x coordinate from y*width to get address
	add	$t2, $t2, $zero						#load index into arbitrary reg
	mul	$t2, $t2, 4						#multiply arbitrary reg by element_size
	add	$t2, $t2, $zero						#load result back into same reg
	lw 	$t4, originAddress					#load origin address into arbitrary register
	add	$t5, $t4, $t2						#add base to (idx * element_size)
	sw	$a1, ($t5)						#store color at the calculated location
									
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
# get_	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#   Outputs:
#    Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
##########################################################################
# Psuedocode:
#	obtain coordinates
#		algorithm to get desired address value
#		add with originAddress
#		store color into $v0 and return
##########################################################################
get_pixel: nop								#USES REGISTERS $t0 - $t5, $a0 - $a1
	getCoordinates($a0, $t0, $t1)					#isolate coordinates into two separate entities
	mul 	$t1, $t1, 128						#multiply y coordinate by 128 (width)
	mflo 	$t2							#load result into arbitrary register
	add 	$t2, $t2, $t0						#add x coordinate from y*width to get address
	add	$t2, $t2, $zero						#load index into arbitrary reg
	mul	$t2, $t2, 4						#multiply arbitrary reg by element_size
	add	$t2, $t2, $zero						#load result back into same reg
	lw 	$t4, originAddress					#load origin address into arbitrary register
	add	$t5, $t4, $t2						#add base to (idx * element_size)
	lw	$v0, ($t5)						#Returns pixel color in $v0 in format (0x00RRGGBB)
	
	jr $ra

#***********************************************
# draw_solid_circle:
#  Considering a square arround the circle to be drawn  
#  iterate through the square points and if the point 
#  lies inside the circle (x - xc)^2 + (y - yc)^2 = r^2
#  then plot it.
#-----------------------------------------------------
# draw_solid_circle(int xc, int yc, int r) 
#    xmin = xc-r
#    xmax = xc+r
#    ymin = yc-r
#    ymax = yc+r
#    for (i = xmin; i <= xmax; i++) 
#        for (j = ymin; j <= ymax; j++) 
#            a = (i - xc)*(i - xc) + (j - yc)*(j - yc)	 
#            if (a < r*r ) 
#                draw_pixel(x,y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_solid_circle: nop
	push($ra)
	getCoordinates($a0, $t0, $t1)			#$t0 is xc, $t1 is yc
	sub 	$t2, $t0, $a1				#$t2 is xmin
	add 	$t3, $t0, $a1				#$t3 is xmax
	sub 	$t4, $t1, $a1				#$t4 is ymin
	move 	$a3, $t4				#arbitrary register
	add 	$t5, $t1, $a1				#$t5 is ymax
	mul 	$a1, $a1, $a1				#$a1 becomes r*r
	OuterLoop:
		InnerLoop:
			sub $t6, $t2, $t0		#$t6 = (i - xc)
			mul $t6, $t6, $t6		#(i - xc)*(i - xc)
			sub $t7, $t4, $t1		#$t7 = (j - yc)
			mul $t7, $t7, $t7		#(j - yc)*(j - yc)
			add $t8, $t6, $t7		#$t8 = a
			bge $t8, $a1, counter
				formatCoordinates($a0, $t2, $t4)
				push($t0)
				push($t1)
				push($t2)
				push($t3)
				push($t4)
				push($t5)
				push($a1)
				move $a1, $a2
				jal draw_pixel
				pop($a1)
				pop($t5)
				pop($t4)
				pop($t3)
				pop($t2)
				pop($t1)
				pop($t0)
	counter:
		addi	$t4, $t4, 1
		ble	$t4, $t5, InnerLoop
		move	$t4, $a3
		addi	$t2, $t2, 1
		ble	$t2, $t3, OuterLoop
	pop($ra)
	jr $ra
		
#***********************************************
# draw_circle:
#  Given the coordinates of the center of the circle
#  plot the circle using the Bresenham's circle 
#  drawing algorithm 	
#-----------------------------------------------------
# draw_circle(xc, yc, r) 
#    x = 0 
#    y = r 
#    d = 3 - 2 * r 
#    draw_circle_pixels(xc, yc, x, y) 
#    while (y >= x) 
#        x=x+1 
#        if (d > 0) 
#            y=y-1  
#            d = d + 4 * (x - y) + 10 
#        else
#            d = d + 4 * x + 6 
#        draw_circle_pixels(xc, yc, x, y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of the circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color of line in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_circle: nop					#USES REGISTERS $t0 - $t6 $a0 - $a2
	push($ra)
	
	li	$t2, 0					#x = 0, $t2	IMPORTANT
	move	$t3, $a1				#y = r, $t3	IMPORTANT
	li	$t4, 2
	mult	$t4, $a1				#2 * r, $t4
	mflo	$t4
	li	$t5, 3
	sub	$t4, $t5, $t4				#3 - (2 * r) = $t4 (IN OTHER WORDS: $t4 = d) IMPORTANT
	
	move	$a1, $a2				#$a1 = color
	move	$a2, $t2				#$a2 = x
	move	$a3, $t3				#$a3 = y
	push($t2)
	push($t3)
	push($t4)
	jal	draw_circle_pixels			#draw_circle_pixels is CHANGING: $t0 - $t5, $t7 - $t8, $a0 - $a1 ($a2, $a3 are not affected)
	pop($t4)
	pop($t3)
	pop($t2)
	
	loop1:						#IMPORTANT REGISTERS: $t2 = x, $t3 = y, $t4 = d
		bgt	$t2, $t3, exit
		addi	$t2, $t2, 1			#x=x+1
		blez	$t4, else
			subi	$t3, $t3, 1		#y=y-1  
			sub	$t5, $t2, $t3		#(x-y) = $t5
			li	$t6, 4			
			mult	$t6, $t5		#4 * (x-y) = $t5
			mflo	$t5
			add	$t4, $t4, $t5		#d + (4 * (x-y)) = $t4
			addi	$t4, $t4, 10		#(d + 4 * (x - y)) + 10 = $t4
			b	draw
		else:					#d = d + 4 * x + 6 
			li	$t5, 4
			mult	$t5, $t2		#4 * x = $t5
			mflo	$t5
			add	$t4, $t4, $t5		#d + (4 * x) = $t4
			addi	$t4, $t4, 6		#(d + (4 * x)) + 6 = $t4 = d
			b	draw
		draw:
			move	$a2, $t2
			move	$a3, $t3
			push($t2)
			push($t3)
			push($t4)
			jal	draw_circle_pixels			#draw_circle_pixels is CHANGING: $t0 - $t5, $t7 - $t8, $a0 - $a1 ($a2, $a3 are not affected)
			pop($t4)
			pop($t3)
			pop($t2)
			b	loop1
	exit:		
	pop($ra)
	jr $ra
	
#*****************************************************
# draw_circle_pixels:
#  Function to draw the circle pixels 
#  using the octans' symmetry
#-----------------------------------------------------
# draw_circle_pixels(xc, yc, x, y)  
#    draw_pixel(xc+x, yc+y) 
#    draw_pixel(xc-x, yc+y)
#    draw_pixel(xc+x, yc-y)
#    draw_pixel(xc-x, yc-y)
#    draw_pixel(xc+y, yc+x)
#    draw_pixel(xc-y, yc+x)
#    draw_pixel(xc+y, yc-x)
#    draw_pixel(xc-y, yc-x)
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#    $a2 = current x value from the Bresenham's circle algorithm
#    $a3 = current y value from the Bresenham's circle algorithm
#   Outputs:
#    No register outputs	
#*****************************************************
draw_circle_pixels: nop					#USES REGISTERS $t0, $t1, $t7, $t8 $a0 - $a3, draw_pixel is using $t0 - $t5, $a0 - $a1
	push($ra)
	getCoordinates($a0, $t0, $t1)			#$t0 = xc, $t1 = yc	IMPORTANT
							#formatCoordinates changes $a0, thus must SAVE $a0
	#    draw_pixel(xc+x, yc+y) 
		add	$t7, $t0, $a2
		add	$t8, $t1, $a3
		push($t0)
		push($t1)
		push($a0)
		formatCoordinates($a0, $t7, $t8)
		jal	draw_pixel
		pop($a0)
		pop($t1)
		pop($t0)
		
	#    draw_pixel(xc-x, yc+y)
		sub	$t7, $t0, $a2
		add	$t8, $t1, $a3
		push($t0)
		push($t1)
		push($a0)
		formatCoordinates($a0, $t7, $t8)
		jal	draw_pixel
		pop($a0)
		pop($t1)
		pop($t0)
		
	#    draw_pixel(xc+x, yc-y)
		add	$t7, $t0, $a2
		sub	$t8, $t1, $a3
		push($t0)
		push($t1)
		push($a0)
		formatCoordinates($a0, $t7, $t8)
		jal	draw_pixel
		pop($a0)
		pop($t1)
		pop($t0)
		
	#    draw_pixel(xc-x, yc-y)
		sub	$t7, $t0, $a2
		sub	$t8, $t1, $a3	
		push($t0)
		push($t1)
		push($a0)
		formatCoordinates($a0, $t7, $t8)
		jal	draw_pixel
		pop($a0)
		pop($t1)
		pop($t0)
		
	#    draw_pixel(xc+y, yc+x)
		add	$t7, $t0, $a3
		add	$t8, $t1, $a2
		push($t0)
		push($t1)
		push($a0)
		formatCoordinates($a0, $t7, $t8)
		jal	draw_pixel
		pop($a0)
		pop($t1)
		pop($t0)
		
	#    draw_pixel(xc-y, yc+x)
		sub	$t7, $t0, $a3
		add	$t8, $t1, $a2
		push($t0)
		push($t1)
		push($a0)
		formatCoordinates($a0, $t7, $t8)
		jal	draw_pixel
		pop($a0)
		pop($t1)
		pop($t0)
		
	#    draw_pixel(xc+y, yc-x)
		add	$t7, $t0, $a3
		sub	$t8, $t1, $a2
		push($t0)
		push($t1)
		push($a0)
		formatCoordinates($a0, $t7, $t8)
		jal	draw_pixel
		pop($a0)
		pop($t1)
		pop($t0)
		
	#    draw_pixel(xc-y, yc-x)
		sub	$t7, $t0, $a3
		sub	$t8, $t1, $a2
		push($t0)
		push($t1)
		push($a0)
		formatCoordinates($a0, $t7, $t8)
		jal	draw_pixel
		pop($a0)
		pop($t1)
		pop($t0)
	
	pop($ra)
	jr $ra
