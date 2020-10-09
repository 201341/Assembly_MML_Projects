##########################################################################
# Created by:  Lao, Justin
#              jlao3
#              5 May 2020
#
# Assignment:  Lab 3: ASCII-risks (Asterisks)
#              CSE012, Computer Systems and Assembly Language
#              UC Santa Cruz, Spring 2020
# 
# Description: Print variable-sized ASCII diamonds and a sequence of embedded numbers to create a triangle.
#
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################

##########################################################################
# Psuedocode:
#	promt user for input
#		if user input is incorrect jump back to prompt
#		else continue
#	stores user input into register and create data for triangle using it
#	for (i = lineNumber; i < required amount of front numbers; i++)
#		print i;
#	for (x = 0; x < required amount of asterisks x++)
#		print asterisks;
#	for (j = i; j < required amount of back numbers; j++) //working backwards from i to reach back to lineNumber
#		print j;
#	if lineNumber != userInput
#		restart loop and increment lineNumber
#	else exit
##########################################################################

.data
	prompt: .asciiz "Enter the height of the pattern (must be greater than 0):	"
	error: .asciiz  "Invalid Entry!\n"
	tab: .asciiz "	"
	newline: .asciiz "\n"
	
.text
	userInput: #Prompt the user to enter age
		li $v0, 4
		la $a0, prompt
		syscall
	
	#Getting height from user input
	li $v0, 5
	syscall
	
	#Checks if input is greater than 0
	bgtz $v0, startTriangle
	li $v0, 4
	la $a0, error
	syscall
	j userInput
	
	startTriangle:
		move $t0, $v0
		mul  $t1, $t0, 2 	#$t1 = Length of Triangle, userInput * 2
		jal printNewline

	resetCounter1:
		addi $t2, $t2, 	1	#Line of Triangle
		add $t3, $t3, $t2	#$t3 = Number to output	
		beq $t2, 1, counterCont
		subi $t3, $t3, 1
		
	counterCont:
		#Will count how many times an asterisk and tab space needs to be outputted
		sub  $t5, $t1, $t2
		sub  $t5, $t5, $t2
		
		#Number pointer, always becomes 1
		la $t8, 1
		
		#Asterisk pointer, always becomes = 1
		la $t6, 1
		
		#Output Number pointer, always making it starting output number for the line
		la $t7, ($t3)
	
	#Creates starting line of Triangle Numbers
	createTriangleLine:
		jal printNumber
		jal printTab
		
		beq $t8, $t2, printAsterisks
		addi $t8, $t8, 1
		addi $t3, $t3, 1
		j createTriangleLine
	
	#Prints correct amount of asterisks
	printAsterisks:
		beq $t5, $zero, createLastPart
		li $v0, 11
		la $a0, '*'
		syscall
		jal printTab
		
		beq $t6, $t5, createLastPart
		addi $t6, $t6, 1
		j printAsterisks
	
	#Creates last set of numbers for that line
	createLastPart:
		jal printNumber
		beq $t3, $t7, final
		jal printTab
		
		sub $t3, $t3, 1
		j createLastPart
	
	#New line on end
	final:
		beq $t2, $t0, exit
		jal printNewline
		j resetCounter1
	
	#Full triangle completed
	exit:	
		jal printNewline
		li $v0, 10
		syscall
	 
	 printTab:
	 	li $v0, 4
		la $a0, tab
		syscall
		jr $ra
	
	printNumber:
		li $v0, 1
		la $a0, ($t3)
		syscall
		jr $ra
	
	printNewline:
		li $v0, 4
		la $a0, newline
		syscall
		jr $ra
