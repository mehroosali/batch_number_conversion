# Batch Number Conversion

## Problem Statement 
Prompt the user for the file name, then input and open it. <br>
Each request is a single line as follow: <br>
Input type (one character, b: binary, d: decimal, or h: hexadecimal) <br>
Input length (1 to 32) <br>
Output type (one character, B: binary, D: decimal, or H: hexadecimal) <br>
Colon (:) and space <br>
Input value in the appropriate format including optional sign. Whitespace may be used for character grouping. If used, it does not count as part of the input length. <br>
Output the data as follows: <br>
Input type (one character, b: binary, d: decimal, or h: hexadecimal) <br>
Colon (;) and space <br>
Value input <br>
Semicolon (;) and space <br>
Output type (one character, B: binary, D: decimal, or H: hexadecimal) <br>
Colon (;) and space <br>
Output value <br>
Clean up after all input lines have been processed. <br>
Your test file must include all combinations of conversions including implicitly and explicitly signed values. Binary and hexadecimal output should always include thirty-two bits. Decimal output must not include leading zeroes. <br>
Upload code, your test file, and report here. <br>
Bonus points: <br>
5 points for insertion of spaces between every grouping of four characters in binary and hexadecimal outputs. <br>
5 points for insertion of commas between grouping of three characters, for decimal outputs, counting from the right. <br>

Input Type (one character, b: binary, d: decimal, or h: hexadecimal), Input Length (1 to 32), Output Type (one character, b: binary, d: decimal, or h: hexadecimal), Colon (:) and space and value input (signed/unsigned decimal, binary or hexadecimal with optional whitepaces). <br>

Input Type (one character, b: binary, d: decimal, or h: hexadecimal), Colon (;) and space and Output value (covered value). of one character which is a binary (b), decimal (d), or hexadecimal (h)  <br>

		OpenFile 
		
		Loop
		
			# ReadLine
				ReadInputType (Done is established)
				ReadInputLength
				ReadOutputType
				Skip two bytes
				Read for optional sign (ignoring whitespace)
				Read first value character into number (ignoring whitespace)
				Loop over InputLength-1
					number *= base
					read next value (ignoring whitespace)
					number += next
				Read until '\n' is found.
				Apply optional negative sign.
			
			If (Done) break
			
			# Output
				Output input info
				{output	.space 0:40}
				current = address of output[39]
				assume number contains the input value in internal format
				if number is negative, set flag and negate number
				loop (B:32, D:10, H:8)
					decrement current
					div number, base => Q, R
					Place R at current
					set number to Q
					if decimal output type and Q == 0, break
				if negative, place '-' at current-1
							
		End Loop
		
		# CleanUp
		Close File
		Terminate