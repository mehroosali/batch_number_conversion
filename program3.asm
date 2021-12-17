# File Name: program3.asm
# Author: Mehroos Ali (mehroos.ali@utdallas.edu)
# Modification History
# - This code was first written on 17th November 2021.
# - The Code has been submitted to be reviewed by Dr. Richard Goodrum on 19th November 2021.

# Procedures:
# main: Entry point of the program. Reads the input filename name from user, initializes registers, calls procedures to read the file and iterate through it to perform calculation and output the results.
# readAndOpenFile: this function asks user to input file name and then opens the file.
# intializeSavedRegisters: procedure to initialise saved registers to 0.
# readNextByte: reads the next byte in the file.
# printInputType: procedure for printing input type to the console.
# nextValue: procedure to read and print valid bytes (non-whitespace) from the file.
# getBase: procedure to get the base output type.
# asciiToInt: procedure to convert ascii char value to integer.

        .data
        colonAndSpace: 		.asciiz ": "					# constant for representing a colon with space.
        semiColonAndSpace: 	.asciiz "; "					# constant for representing a semi colon with space.
        newline: 			.asciiz "\n"					# constant for representing a newline.
		outputValue: 		.space 41               		# Buffer to hold the output value.
		buffer:         	.space 1                		# Buffer to hold the output value.
		readLength:     	.word  1                		# number of bytes read from the file.
		filenameLength: 	.word  128						# max length of the filename.
		filename:       	.space 128						# input filename.
		inputPrompt:	    .asciiz  "Enter the filename: " # Input inputPrompt to enter filename.

        .text
# main:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 17th November 2021 by Mehroos Ali.
# Description: Entry point of the program. Reads the input filename name from user, initializes registers, calls procedures to read the file and iterate through it to perform calculation and output the results.
# Arguments: None

main:
		la $a0, inputPrompt                   		# load address of string inputPrompt.
        li $v0, 4                             		# call print_string service.
        syscall                               		# print inputPrompt to the console.
        jal readAndOpenFile                         # jump to procedure readAndOpenFile.
        move $s0, $v0                         		# copy the file descriptor to saved register $s0.
        
Loop:
        jal intializeSavedRegisters			  		# jump to procedure intializeSavedRegisters.

        move $a0, $s0                         		# Set file descriptor in $a0 so that it is passed as input parameter to function in next line.
		
# INPUT SECTION
        jal readNextByte                      		# jump to procedure readNextByte to read the next byte in the file. This will be the input type.
        move $s1, $v1                        		# store the byte read in saved register $s1.
        beq $v0, $0, End                 	 		# jump to procedure end if end of the file is reached.
        
		jal printInputType							# jump to procedure printInputType for printing input type.
        
        move $a0, $s0                         		# copy file descriptor from  $s0 to $a0 to be passed as input parameter to function readNextByte.
        jal readNextByte                      		# jump to procedure readNextByte to read the next byte in the file. This will be a number character.
        subi $s2, $v1, 48                     		# Converting the read byte from ascii character to integer value and storing it in saved register $s2.
        
  
        jal readNextByte                      		# jump to procedure readNextByte to read the next byte in the file. this will be either number character or output type.
        blt $v1, 0x30, saveOutputType        		# If next charaacter is less that symbol 0  then its a output type. jump to saveOutputType procedure to save it.
        bgt $v1, 0x39, saveOutputType        		# If next character is greater that symbol 9  then its a output type. jump to saveOutputType procedure to save it.
        subi $v1, $v1, 48                     		# If next character is a number then convert it into integer.
        mul $s2, $s2, 10                      		# multiply $s2 by 10 to count ReadInputLength as double digits.
        add $s2, $s2, $v1                     		# add the 2nd digit to $s2 to complete reading ReadInputLength.

        jal readNextByte                      		# jump to procedure readNextByte to read the output type.
		
saveOutputType:
        move $s3,$v1                          		# store the byte read in saved register $s1.
      
        jal readNextByte                      		# jump to procedure readNextByte to skip a byte colon.
        jal readNextByte                      		# jump to procedure readNextByte to skip a byte space.
        
        jal nextValue           			  		# jump to procedure nextValue to get the next valid byte (non whitespace) from the file.
        beq $v1, 0x2b, readFirstValue	      		# If next byte equals to '+' then move to next value.
        beq $v1, 0x2d, setnegetiveSign        		# If next byte equals to '-' then save negative flag.
        j saveFirstValue                     		# Next byte is neither positive or negetive that means it's a digit so we save the value.
		
setnegetiveSign:
        li $s4, 1                             		# Setting negative flag in saved in register $s4.

readFirstValue:
        jal nextValue           					# invoke nextValue function to get the next valid byte (non whitespace) in the file.
		
saveFirstValue:
        move $s5,$v1                          		# Save the first digit in saved register $s5.
        
        move $a1, $s1                         		# copy the input type in register $s1 to register $a1 to pass it as a parameter to procedure getBase.
        jal getBase                           		# jump to procedure getBase to get the base.
        move $s6, $v0                         		# store the base in saved register $s6.
        
        move $a1, $s6                        		# copy the base in register $a1 to pass as a parameter to procedure asciiToInt.
        move $a2, $s5                         		# copy the input value in register $a2 to pass as a parameter procedure asciiToInt.
        jal asciiToInt                             	# jump to procedure asciiToInt to convert string value based on the base.
        move $s5, $v0                         		# Save the converted value back in saved register $s5.
        
        subi $t3, $s2, 1                      		# Set the max counter for valueLoop as digits count - 1 as we have read the first value.
        li $t2, 0                             		# Initialise the loop counter.

valueLoop:
        bge $t2, $t3, valueLoopEnd       			# End the valueLoop if the counter exceeds the digts count.
        mul $s5, $s5, $s6                     		# multiply the value with the base.
        jal nextValue           					# jump to procedure nextValue to get the next valid byte (non whitespace) from the file. This procedure helps in ignoring whitespace which may be used for character grouping.
        
        move $a1, $s6                         		# copy the base in register $s6 to register $a1 to pass it as a parameter to procedure asciiToInt.
        move $a2, $v1                         		# copy the value in register $v1 to register $a2 to pass it as a parameter to procedure asciiToInt.
        jal asciiToInt                             	# jump to procedure asciiToInt to convert ascii value based on the base.
        add $s5, $s5, $v0                     		# Save the converted input value back in saved register $s5.
        
        addi $t2, $t2, 1                      		# Increment the valueLoop counter.
        j valueLoop                      			# iterate forward.
valueLoopEnd:


EndLineLoop:
        jal readNextByte                      		# Jump to procedure readNextByte to read the next byte. We loop till end of the line to check if there are other charaters at the end of the line.
        beq $v1, 0x0a, EndLoop             			# Break the loop if newline character is found.
        beq $v0, $0, EndLoop               			# Break the loop if file descriptor is 0.
        j EndLineLoop                             	# interate the loop.
EndLoop:
        
negation:        
        bne $s4, 1, negationEnd               		# If negetive is not symbol is present, jump to output section.
        sub $s5, $0, $s5                      		# perform negation of input value in $s5 if negative sign is present. 
negationEnd:
        

# OUTPUT SECTION

output:
        la $t2, outputValue                   		# initialise $t2 to address of outputValue variable.
        li $t1, 0                             		# initialise counter $t1 to 0.
		
clearOutputValue:
        beq $t1, 40, clearOutputValueEnd      		# check if loop completed. If so jump to end.
        sb $0, 0($t2)                         		# Put $0 in current address.
        addi $t2, $t2, 1                     		# Increment the address.
        addi $t1, $t1, 1                      		# Increment the loop counter.
        j clearOutputValue                    		# Jump back to start of loop.
		

clearOutputValueEnd:

        move $a1, $s3                         		# Put the output type in $a1 so that it gets passed as a parameter into the function
        jal getBase                           		# Invoke getBase function to get the numerical base of the type
        move $s6, $v0                         		# store the base in saved register $s6
        
        la $t2, outputValue                   		# Load address of outputValue
        addi $t2, $t2, 39                     		# add 39 to address as we are filling the string from back

        move $t1, $s5                         		# Store the input value in temporary variable $t1 so that it can be computed on
        li $t3, 0                             		# initialise $t3(Used for storing remainder of division) to 0
        li $t4, 0                             		# initialise $t4(Used for storing counter based on base) to 0
        li $t5, 0                             		# initialise $t4(Used for storing loop counter) to 0
                 

        bge $t1, $0, binaryCounter            		# If not negetive, jump this segment
        sub $t1, $0, $t1                      		# Subtract the value from 0 so that it becomes positive

        beq $s6, 10, binaryCounter            		# If output is in decimal, we can skip this segment
        subi $t1, $t1, 1                      		# We subtract 1 from the input value which just became positive as it helps to obtain the 2's compliment
        
binaryCounter:
        bne $s6, 2, decimalCounter            		# If Output type is not binary, skip next line
        addi $t4, $t4, 32                     		# For Binary, 32 digits are needed so loop should happen 32 times
decimalCounter:
        bne $s6, 10, hexCounter               		# If Output type is not decimal, skip next line
        addi $t4, $t4, 10                     		# For Decimal, 10 digits are needed as max value is 2ˆ31 = 2147483648
hexCounter:                                
        bne $s6, 16, outputValueloop          		# If Output type is not hex, skip next line
        addi $t4, $t4, 8                      		# For Hex, 8 digits are needed so loop should happen 8 times

outputValueloop:
        bge $t5, $t4, outputValueloopExit     		# Exit loop if counter reaches the required base counter
        bnez $t1, divisionByBase              		# When the input value is fully processed, go to next line else skip it
        beq $s6, 10, outputValueloopExit      		# For decimal, leading 0's are not needed so we can end the loop
        
divisionByBase:
        div $t1, $s6                          		# Divide by base to split into quotient and remainder.
        mfhi $t3                              		# Store remainder in $t3.
        mflo $t1                              		# Store quotient back in $t1.
        
twosComplementConversion:
        bge $s5, $0, hexOutput                		# If the original Input value is positive, this segment is skipped
        beq $s6, 10, hexOutput                		# For decimal, this segment is skipped.

        sub $t3, $s6, $t3                     		# subtract the remained from the base of output type to get the complement.
        subi $t3, $t3, 1                      		# subtract 1 so complete the equation. Now $t3 has the complement.
        
hexOutput:
        bne $s6, 16, Sum                      		# If not hex, skip this segment
        ble $t3, 9, Sum                       		# if less than or equal to nine, same as normal digits so we can skip this segment
        addi $t3, $t3, 0x37                   		# Here the value is from a-f so we are adding 0x37 (9 lower than A in ascii as first 9 values are numerical digits)
        b sumEnd                              		# Conversion to digit symbols can be skipped. Directly store the obtained value

Sum:
         addi $t3, $t3, 0x30                  		# add 0x30 ('0' in ascii) to result
sumEnd:
         
         beqz $t5 storeOutputValue            		# If t5 is 0, the following computaion will work and delimiter will be set at start of value so if 0, we skip the segment
setDelimiterDecimal:
        bne $s6, 10, setDelimiterHexOrBinary  		# If not decimal, skip to binary & Hex delimiter
        li $t8, 3                             		# Delimiter has to be set after every 3 digits
        div $t5, $t8                          		# check if the index is divisible by 3
        mfhi $t7                              		# store the remainder from $hi to $t7
        bne $t7, 0, storeOutputValue          		# if counter is not a multiple of 3 skip this segment
        li $t8, 0x2c                          		# load 0x2c (',' in ascii) into variable $t8
        sb $t8, 0($t2)                        		# store delimiter into current address of output value
        subi $t2, $t2, 1                      		# decrement address counter

setDelimiterHexOrBinary:
        li $t8, 4                             		# Delimiter has to be set after every 4 digits
        div $t5, $t8                          		# check if the index is divisible by 4
        mfhi $t7                              		# store the remainder from $hi to $t7
        bne $t7, 0, storeOutputValue          		# if counter is not a multiple of 4 skip this segment
        li $t8, 0x20                          		# load 0x20 (' ' in ascii) into variable $t8
        sb $t8, 0($t2)                        		# store delimiter into current address of output value
        subi $t2, $t2, 1                      		# decrement address counter
        
storeOutputValue:
        sb $t3, 0($t2)                        		# store output digit into current address of output value
        subi $t2, $t2, 1                      		# decrement address counter
        addi $t5, $t5, 1                      		# increment loop counter
        j outputValueloop                     		# Jump back to start of loop

outputValueloopExit:

        bne $s6, 10, printOutputValue         		# Only for decimal so if not decimal, skip this segment
        bge $s5, 0, printOutputValue          		# Only for negetive input vlue so if original input value is not negetive, skip this segment
        li $t3, '-'                           		# load '-' into variable $t3
        sb $t3, 0($t2)                        		# store negetive symbol in the current address of output value
        subi $t2, $t2, 1                      		# decrement address counter
        
printOutputValue:
        li $v0, 4                             		# Load constant 4 to $v0 implying we are going to print a string
        la $a0, semiColonAndSpace                	# Load address of constant semiColonAndSpace to $a0 so that it gets printed on the console
        syscall                               		# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its constant semiColonAndSpace).
        li $v0, 11                            		# Load constant 11 to $v0 implying we are going to print a character
        move $a0, $s3                         		# Load output type to $a0 so that it gets printed on the console
        syscall                               		# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its output type).
        li $v0, 4                             		# Load constant 4 to $v0 implying we are going to print a string
        la $a0, colonAndSpace                    	# Load address of constant colonAndSpace to $a0 so that it gets printed on the console
        syscall                               		# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its constant colonAndSpace).
        addi $t2, $t2, 1                      		# increment address of output value so that it points to first charecter
        move $a0, $t2                         		# Load output value to $a0 so that it gets printed on the console
        syscall                               		# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its output value).
        la $a0, newline                       		# Load address of constant newline to $a0 so that it gets printed on the console
        syscall                               		# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its constant newline).
        
        j Loop                        				# Jump back to start of loop
        
End:   

        li   $v0, 16                          		# Load constant 16 to $v0 implying we are going to close a file
        move $a0, $s0                         		# Load the file descriptor in $a0 thereby signalling the closing of the file
        syscall                               		# Execute system call to close file     

        li $v0, 10                            		# Load constant 10 to $vo implying we are going to exit the program
        syscall                               		# Execute system call that looks at $v0(Here its exit) and thus it terminates the program.
        
# readNextByte:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 17th November by Mehroos Ali.
# Description: Procedure for reading a single byte from the file descriptor.
# Arguments: 
# $a0 = I/P int file descriptor
# $v0 = O/P int number of bytes read
# $v1 = O/P char byte read from the descriptor

readNextByte:
        la $a1, buffer                        		# provide a buffer address in memory that will hold the data from the file. 
        la $a2, readLength                    		# set the address of number of bytes to be read.
        lb $a2, 0($a2)                        		# set the value from the address of number of bytes to be read. Here it is 1
        li $v0, 14                            		# Load constant 14 to $v0 implying we are going to read a file
        syscall                               		# Execute system call that reads file and loads it in data buffer

        lbu $v1, 0($a1)                       		# store the read byte in $v1 so that it returns to parent function

        jr $ra                               		# Function is completed. Return to parent

# readAndOpenFile:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 17th November by Mehroos Ali.
# Description: Procedure for taking user input as filename then opening remove linefeed and opening the file.
# Arguments: 
# $v0 O/P int File Descriptor
        
readAndOpenFile:
        li $v0, 8                             		# Call read_string service.
        la $a0, filename                      		# load address of directive fileName to store the input filename into it.
        la $a0, filename                      		# specify the filename length argument in register $a1.
        la $a1, filenameLength                		# a length of 128 bytes of size for the file name is allowed.
        lw $a1, 0($a1)                        		# a length of 128 bytes of size for the file name is allowed.
        syscall                               		# take the filename input from the user.

        add $a1, $a0, $a1                     		# Set end of the loop as address of file name plus filenameLength.
modifyFileNameLoop:
        beq $a0, $a1, openFile            			# break the loop after iterating the filelength length.
        lbu $t0, 0($a0)                       		# load character of the file name.
        beq $t0, '\n', cleanNewlineCharacter   		# if newline char then jump to procedure cleanNewlineCharacter.
        addi $a0, $a0, 1                      		# increment modifyFileNameLoop counter.
        j modifyFileNameLoop                        # iterate forward.

cleanNewlineCharacter:
        sb $0, 0($a0)                         		# If line feed found, replace it will null character.

openFile:

        la $a0, filename                      		# load address of input filename.
        li $a1, 0                             		# set the flag for reading.
        li $a2, 0                             		# set the file mode.
        li $v0, 13                            		# system call for opening the file.
        syscall                               		# Execute system call that opens the file in read mode.

        jr $ra                                		# return to procedure main.

# getBase:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 17th November by Mehroos Ali.
# Description: procedure to get the base output type.
# Arguments: 
# $a1 I/P char output type. b or B for binary, d or D for decimal, h or H for hexadecimal.
# $v0 O/P int  Base of the type. 2 for binary, 10 for decimal, 16 for hexadecimal.

getBase:
        beq $a1, 0x62, binaryBase             		# If the byte read is 'b' then jump to procedure binaryBase.
        beq $a1, 0x42, binaryBase             		# If the byte read is 'B' then jump to procedure binaryBase.
        beq $a1, 0x64, decimalBase            		# If the byte read is 'd' then jump to procedure decimalBase.
        beq $a1, 0x44, decimalBase            		# If the byte read is 'D' then jump to procedure decimalBase.
        beq $a1, 0x68, hexBase                		# If the byte read is 'h' then jump to procedure hexadecimalBase.
        beq $a1, 0x48, hexBase                		# If the byte read is 'H' then jump to procedure hexadecimalBase.
        
binaryBase:
        li $v0, 2                             		# load in 2 as return value for binary base.
        j getBaseEnd                          		# jump to procedure getBaseEnd.
        
decimalBase:
        li $v0, 10                            		# load in 10 as return value for decimal base.
        j getBaseEnd                          		# jump to procedure getBaseEnd.
        
hexBase:
        li $v0, 16                            		# load in 16 as return value for hexadecimal base.
        
getBaseEnd:
        jr $ra                                		# return to procedure saveFirstValue.
        
# nextValue:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 17th November by Mehroos Ali.
# Description: procedure to read and print valid bytes (non-whitespace) from the file.
# Arguments: 
# $a0 	I/P int file dsescriptor
# $v0	O/P int Number of bytes read
# $v1	O/P char byte read

nextValue:
        addi $sp $sp -4                       		# making space in the stack for next value.
        sw   $ra  -4($sp)                     		# Store $ra in the stack.
        
readnextvalidByteLoop:
        jal readNextByte                      		# invoke readNextByte function to get the next byte in the file.
        
        move $t0, $a0                         		# store $a0 in temp variable
        move $t1, $v0                         		# store $v0 in temp variable
        
        move $a0, $v1                         		# Load value read to $a0 so that it gets printed on the console
        li $v0, 11                            		# Load constant 11 to $v0 implying we are going to print a character
        syscall                               		# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its value read).
        
        move $a0, $t0                         		# put back the value of $a0 from temp variable
        move $v0, $t1                         		# put back the value of $v0 from temp variable
        
        beq $v1, 0x20, readnextvalidByteLoop  		# if space, branch to start of function and repeat the process. 0x20 = space in ascii
        beq $v1, 0x09, readnextvalidByteLoop  		# if tab, branch to start of function and repeat the process. 0x09 = tab in ascii
        beq $v1, 0x0a, readnextvalidByteLoop  		# if new line, branch to start of function and repeat the process. 0x0a = new line in ascii
        beq $v1, 0x0b, readnextvalidByteLoop  		# if vertical tab, branch to start of function and repeat the process. 0x0b = vertical tab in ascii
        beq $v1, 0x0c, readnextvalidByteLoop  		# if form feed, branch to start of function and repeat the process. 0x0c = form feed in ascii
        beq $v1, 0x0d, readnextvalidByteLoop  		# if carriage return, branch to start of function and repeat the process. 0x0d = carriage return in ascii
        
        lw $ra  -4($sp)                       		# load $ra from the stack
        addi $sp $sp 4                        		# Add space back in the stack pointer
        
        jr $ra                                		# Function is completed. Return to parent

# asciiToInt:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 17th November 2021 by Mehroos Ali.
# Description: procedure to convert ascii char value to integer.
# Arguments:
# $a1 	I/P base value
# $a2	I/P Ascii char value
# $v0	O/P decimal value

asciiToInt:
        bne $a1, 16, digitsToInt              		# If not a hexadecimal base handle as digits base.
        ble $a2, '9', digitsToInt          	  		# if value less than '9' handle as digits base.
        
lowercaseHexadecimal:
        blt $a2, 'a', uppercaseHexadecimal    		# If value is less than  'a' handle capital values.
        sub $v0, $a2, 'a'                     		# Convert from string to integer by subtracting the value of 'a'.
        addi $v0, $v0, 10                     		# Add 10 to account for the digit symbols in hex.
        j stringToIntEnd                      		# Jump to procedure stringToIntEnd.
        
uppercaseHexadecimal:
        sub $v0, $a2, 'A'                     		# Convert from string to integer by subtracting the value of 'A'.
        addi $v0, $v0, 10                     		# Add 10 to account for the digit symbols in hex.
        j stringToIntEnd                      		# Jump to procedure stringToIntEnd.
        
digitsToInt:
        sub $v0, $a2, '0'                     		# Convert from digit symbol to integer by subtracting the value of '0'.

stringToIntEnd:
        jr $ra                                		# Return to procedure saveFirstValue.

# intializeSavedRegisters:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 17th November 2021 by Mehroos Ali.
# Description: procedure to initialise saved registers to 0.
# Arguments: None
		
intializeSavedRegisters:
		li $s1, 0                             		# initialise register $s1 to 0
        li $s2, 0                             		# initialise register $s2 to 0
        li $s3, 0                             		# initialise register $s3 to 0
        li $s4, 0                             		# initialise register $s4 to 0
        li $s5, 0                             		# initialise register $s5 to 0
		jr $ra								  		# return to procedure Loop

# printInputType:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 17th November 2021 by Mehroos Ali.
# Description: procedure for printing input type to the console.
# Arguments: 
# $a0 	I/P char input type.
# $v0	O/P char input type, string colonAndSpace.

printInputType:
        li $v0, 11                            		# call print_character service.
        move $a0, $s1                         		# Move input type ($s1) to $a0 for printing to the console.
        syscall                               		# Print input type to the console.
		
        li $v0, 4                             		# call print_string service.
        la $a0, colonAndSpace                 		# Load address of string colonAndSpace to $a0 for printing to the console.
        syscall                               		# print colonAndSpace to the console.
		
		jr $ra								  		# return to procedure Loop.
