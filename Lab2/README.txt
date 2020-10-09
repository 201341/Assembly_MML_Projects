Justin Lao
jlao3
Spring 2020
Lab 2: Simple Data Path

----------
DESCRIPTION

Building a sequential logic circuit and introduction to data paths. Building a register file that contains four, 
4-bit registers. Each of the four registers has an address (0b00 -> 0b11) and stores a 4-bit value.
The value saved to a destination register (write register) will be chosen from one of two sources, the 
keypad user input, or the output of the ALU. The ALU in this system is a 4-bit bitwise right 
rotation (right circular shift) circuit that takes two of the register values as inputs (read registers).



----------
FILES

-
Lab2.lgi

This file includes the main objective of the lab in an MML-type file. 
Contains a system of circuits comprised of D-Latch FlipFlops, MUXs, and self-created ALUs
to create 4 registers that store a 4-bit value. This is stored through the use of 
4 D-Latch FlipsFlops that store keypad-user input or by the output of the ALU, which uses both
MUXs and ALUs to obtain desired value.

-
README.txt

Describes purpose of Lab2 along with what files will be submitted.
Gives description on how to run lab.

----------
INSTRUCTIONS

This program is intended to be run using the MML program. Press simulate
and use the input switches/keypad to observe how the progrm runs.