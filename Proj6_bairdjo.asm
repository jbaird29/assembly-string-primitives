TITLE String Primitives and Macros     (Proj6_bairdjo.asm)

; Author: Jon Baird
; Last Modified: 3/4/2021
; OSU email address: bairdjo@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number: 6                Due Date: 3/14/2021
; Description: This program reads 10 signed integers from the user via console input
;              then calculates the sum and average and displays to the user.

INCLUDE Irvine32.inc

; (insert macro definitions here)
mGetString MACRO promptAddress:REQ, outputAddress:REQ, size:REQ, bytesReadAddress:REQ
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX
	MOV		EDX, promptAddress
	CALL	WriteString
	MOV		EDX, outputAddress
	MOV		ECX, size
	CALL	ReadString
	MOV		EDI, bytesReadAddress
	MOV		[EDI], EAX
	POP		EAX
	POP		ECX
	POP		EDX
ENDM

mDisplayString MACRO stringAddress:REQ
	PUSH	EDX
	MOV		EDX, stringAddress
	CALL	WriteString
	POP		EDX
ENDM


; (insert constant definitions here)
TEST_COUNT = 3
;MAX_NUM = 2147483647
;MIN_NUM = -2147483648


.data
numArray		SDWORD	TEST_COUNT DUP(?)
greeting		BYTE	"Project 6: Designing low-level I/O procedures.     By: Jon Baird",13,10,13,10,0
instructions	BYTE	"Please provide 10 signed decimal integers. ",13,10,
						"Each number needs to be small enough to fit inside a 32 bit register. ",13,10,
						"After you have finished inputting the raw numbers I will display a list of the integers, ",13,10,
						"their sum, and their average value.",13,10,13,10,0
prompt			BYTE	"Please enter a signed intger: ",0
invalidMsg		BYTE	"ERROR. You did not enter a signed number or your number was too big.",13,10,0

sum				SDWORD	?
average			SDWORD	?
displayMsg		BYTE	"You entered the following numbers:",13,10,0
sumMsg			BYTE	"The sum of these number is: ",0
avgMsg			BYTE	"The rounded average is: ",0
goodbyeMsg		BYTE	"Thanks for playing! ",13,10,0

; EXTRA CREDIT variables
floatArray		REAL10	TEST_COUNT DUP(?)
digitCountArray	DWORD	TEST_COUNT DUP(?)
floatSum		REAL10	?
floatAvg		REAL10	?
testCount		DWORD	TEST_COUNT
promptFloat		BYTE	"Please enter a floating point number: ",0
invalidMsgFloat	BYTE	"ERROR. You did not enter a valid floating point number or your number was too big.",13,10,0


.code
main PROC
; ----------------------------------------------------------------------------------------------------
; Introduction
;    Display introduction messages
; ----------------------------------------------------------------------------------------------------
	mDisplayString OFFSET greeting
	mDisplayString OFFSET instructions
	


; ----------------------------------------------------------------------------------------------------
; ReadVal
;    Test loop - build an array of numbers
; ----------------------------------------------------------------------------------------------------
	MOV		ECX, LENGTHOF numArray
	MOV		EDI, OFFSET numArray
_buildArrayLoop:
	; get a number via ReadVal, store into the currrent position of numArray
	PUSH	EDI
	PUSH	OFFSET invalidMsg
	PUSH	OFFSET prompt
	CALL	ReadVal
	; increment to the next position of numArray
	ADD		EDI, TYPE numArray
	LOOP	_buildArrayLoop


; ----------------------------------------------------------------------------------------------------
; WriteVal
;    Test loop - display the array of numbers 
; ----------------------------------------------------------------------------------------------------
	mDisplayString OFFSET displayMsg
	MOV		ECX, LENGTHOF numArray
	MOV		ESI, OFFSET numArray
_displayArrayLoop:
	; display the current element of numArray
	PUSH	[ESI]
	CALL	WriteVal
	ADD		ESI, TYPE numArray
	; print a comma and space, unless it is the last element in the array
	CMP		ECX, 1
	JE		_noSeparator
	MOV		AL, ","
	CALL	WriteChar
	MOV		AL, " "
	CALL	WriteChar
	_noSeparator:
	LOOP	_displayArrayLoop
	CALL	CrLf


; ----------------------------------------------------------------------------------------------------
; Integer Sum / Average
;    Calculate and display the sum and average of the integers
; ----------------------------------------------------------------------------------------------------
	MOV		ECX, LENGTHOF numArray
	MOV		ESI, OFFSET numArray
	MOV		EAX, 0
	; calculate the sum
_calculateSumLoop:
	ADD		EAX, [ESI]
	ADD		ESI, TYPE numArray
	LOOP	_calculateSumLoop
	MOV		sum, EAX
	; display the sum
	mDisplayString OFFSET sumMsg
	PUSH	sum
	CALL	WriteVal
	CALL	CrLf
	; calculate the average
	MOV		EAX, sum
	CDQ
	MOV		EBX, TEST_COUNT
	IDIV	EBX
	MOV		average, EAX
	; display the average
	mDisplayString OFFSET avgMsg
	PUSH	average
	CALL	WriteVal
	CALL	CrLf
	CALL	CrLf


; ----------------------------------------------------------------------------------------------------
; ReadFloatVal
;    Test loop - build an array of floating point numbers
; ----------------------------------------------------------------------------------------------------
	MOV		ECX, LENGTHOF floatArray
	MOV		EDI, OFFSET floatArray
	MOV		EDX, OFFSET digitCountArray
_buildFloatArrayLoop:
	; get a number via ReadFloatVal, store into the currrent position of floatArray
	PUSH	EDX
	PUSH	EDI
	PUSH	OFFSET invalidMsgFloat
	PUSH	OFFSET promptFloat
	CALL	ReadFloatVal
	; increment to the next position of numArray and digitCountArray
	ADD		EDI, TYPE floatArray
	ADD		EDX, TYPE digitCountArray
	LOOP	_buildFloatArrayLoop


; ----------------------------------------------------------------------------------------------------
; WriteFloatVal
;    Test loop - display the array of float numbers
; ----------------------------------------------------------------------------------------------------
	mDisplayString OFFSET displayMsg
	MOV		ECX, LENGTHOF floatArray
	MOV		ESI, OFFSET floatArray
	MOV		EDX, OFFSET digitCountArray
_displayFloatArrayLoop:
	; display the float in the current position of floatArray
	FINIT
	FLD		REAL10 PTR [ESI]
	PUSH	DWORD PTR [EDX]
	CALL	WriteFloatVal
	; inrement to the next position of numArray
	ADD		ESI, TYPE floatArray
	ADD		EDX, TYPE digitCountArray
	; print a comma and space before the next value
	CMP		ECX, 1
	JE		_skipSeparator
	MOV		AL, ","
	CALL	WriteChar
	MOV		AL, " "
	CALL	WriteChar
	_skipSeparator:
	LOOP	_displayFloatArrayLoop
	CALL	CrLf


; ----------------------------------------------------------------------------------------------------
; Floats Sum / Aveage
;    Calculate and display the sum and average of the numbers in the array
; ----------------------------------------------------------------------------------------------------
	; calculate the average of the floatArray elemenets
	MOV		ECX, LENGTHOF floatArray
	MOV		ESI, OFFSET floatArray
	FINIT
	FLDZ										; initialize FPU stack and set ST(0) to zero
_calcFloatSumLoop:
	; create a running of of floatArray elements stored at ST(0)
	FLD		REAL10 PTR [ESI]
	FADD
	ADD		ESI, TYPE floatArray
	LOOP	_calcFloatSumLoop
	; store the sum into memory; divide by count and store the average into memory
	FSTP	floatSum
	FLD		floatSum
	FILD	testCount
	FDIV
	FSTP	floatAvg

	; calculate the maximum number of digits to display; store into EAX
	MOV		ECX, LENGTHOF digitCountArray
	MOV		ESI, OFFSET digitCountArray
	MOV		EAX, 0
_calcMaxDigitsLoop:
	CMP		[ESI], EAX
	JB		_notMax
	MOV		EAX, [ESI]
	_notMax:
	ADD		ESI, TYPE digitCountArray
	LOOP	_calcMaxDigitsLoop

	; display the sum
	mDisplayString OFFSET sumMsg
	FINIT
	FLD		floatSum
	PUSH	EAX									; push the 'max digits' calculated above
	CALL	WriteFloatVal
	CALL	CrLf
	; display the average
	mDisplayString OFFSET avgMsg
	FINIT
	FLD		floatAvg
	PUSH	EAX									; push the 'max digits' calculated above
	CALL	WriteFloatVal
	CALL	CrLf
	CALL	CrLf


; ----------------------------------------------------------------------------------------------------
; Goodbye
;    Display goodbye message
; ----------------------------------------------------------------------------------------------------
	mDisplayString OFFSET goodbyeMsg

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ------------------------------------------------------------------------------------
; Name: ReadVal
; Description: [++++++++++++TBU++++++++++++]
; Preconditions: [++++++++++++TBU++++++++++++]
; Postconditions: [++++++++++++TBU++++++++++++]
; Receives: 
;	[EBP + 8] = address of a prompt to display to the user
;	[EBP + 12] = address of the message if the input was invalid.
;	[EBP + 16] = address of the location to which the integer number will be saved
; Returns:  [++++++++++++TBU++++++++++++]
;
; ------------------------------------------------------------------------------------
ReadVal PROC
	; set up local variables and preserve registers
	LOCAL	sign:DWORD, priorAccumulator:SDWORD, maxBytes:DWORD, bytesInputted:DWORD, stringNumber[20]:BYTE
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI
_getString:
	LEA		ESI, stringNumber
	LEA		EDI, bytesInputted
	MOV		maxBytes, LENGTHOF stringNumber
	mGetString [EBP + 8], ESI, maxBytes, EDI
	; set up the registers
	MOV		ECX, bytesInputted			; length of string as the counter	
	LEA		ESI, stringNumber			; address of the integer string as source
	MOV		EDI, [EBP + 16]				; address of destination (SDWORD)
	MOV		sign, 0						; set up the sign as 0 (for positive)
	CLD									; iterate forwards through array
	
	; see if the first digit is a '+' or a '-'
	LODSB
	CMP		AL, 43
	JE		_plusSymbol
	CMP		AL, 45
	JE		_minusSymbol
	; if no symbol, decrement ESI in order to re-evaluate that digit again; empty accumulator to set up the loop
	DEC		ESI
	MOV		EAX, 0
	JMP		_charLoop

_minusSymbol:
	; if first digit is a '-' change the sign to 1 (for negative)
	MOV		sign, 1
_plusSymbol:
	; for either symbol, decrement the char count; empty accumulator to set up the loop
	DEC		ECX
	MOV		EAX, 0
	JMP		_charLoop

_charLoop:
	; multiply accumulator by 10 and temporarily store into local variable
	MOV		EBX, 10
	IMUL	EBX
	JO		_notValid
	MOV		priorAccumulator, EAX
	; load the integer string digit, subtract by 48 to convert from ASCII to integer number
	MOV		EAX, 0					; empty the upper range of the accumulator
	LODSB
	CMP		AL, 48
	JB		_notValid
	CMP		AL, 57
	JA		_notValid
	SUB		AL, 48
	; if sign is negative, change the value to negative
	CMP		sign, 0
	JE		_positive
	NEG		EAX	
_positive:
	; add the prior accumulator to this number and loop to next digit
	ADD		EAX, priorAccumulator
	JO		_notValid
	LOOP	_charLoop
	; store final value into the output and end
	MOV		[EDI], EAX
	JMP		_end

_notValid:
	; print an error message to the user and go back to get another string
	MOV		EDX, [EBP + 12]
	CALL	WriteString
	JMP		_getString

_end:
	; restore registers and return
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		12
ReadVal ENDP


; ------------------------------------------------------------------------------------
; Name: WriteVal
; Description: [++++++++++++TBU++++++++++++]
; Preconditions: [++++++++++++TBU++++++++++++] [the address of the location is long enough to store the value plus a null terminator (i.e. 12)]
; Postconditions: [++++++++++++TBU++++++++++++]
; Receives: 
;	[EBP + 8] = value of the number to convert to string & display
; Returns: [++++++++++++TBU++++++++++++]
; ------------------------------------------------------------------------------------
WriteVal PROC
	; preserve registers
	LOCAL	number:SDWORD, sign:DWORD, stringNumber[20]:BYTE
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI
	
	; set up initial registers
	MOV		ESI, [EBP + 8]
	MOV		number, ESI					; move the number into local variable
	MOV		sign, 0						; set up the sign as 0 (for positive)
	MOV		ECX, LENGTHOF stringNumber	; length of destination in BYTES
	LEA		EDI, stringNumber			; address of destination (BYTE string)
	ADD		EDI, ECX
	DEC		EDI						; starting address + length - 1 = last element in string
	STD								; set the direction flag (to increment backwards)

	; put a null-terminator as the last element in destination string
	MOV		AL, 0
	STOSB

	; if number is negative, make the first element of the string a '-', then convert number to positive
	CMP		number, 0
	JGE		_digitToStringLoop
	MOV		sign, 1
	NEG		number

_digitToStringLoop:
	; divide the number by 10, store the quotient as the next iteration's starting number
	MOV		EAX, number
	MOV		EDX, 0
	MOV		EBX, 10
	DIV		EBX
	MOV		number, EAX
	; convert the remainder into its ASCII representation and store in the array
	MOV		EAX, EDX
	ADD		AL, 48
	STOSB
	; if the quotient is zero, the last digit has been reached
	CMP		number, 0
	JNE		_digitToStringLoop

	; if the sign was negative, prepend a '-' symbol
	CMP		sign, 1
	JNE		_displayString
	MOV		AL, "-"
	STOSB

_displayString:
	INC		EDI
	mDisplayString EDI

_end:
	; restore registers and return
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		4
WriteVal ENDP


; ------------------------------------------------------------------------------------
; Name: ReadFloatVal
; Description: [++++++++++++TBU++++++++++++]
; Preconditions: [++++++++++++TBU++++++++++++]
; Postconditions: [++++++++++++TBU++++++++++++]
; Receives: 
;	[EBP + 8] = address of a prompt to display to the user
;	[EBP + 12] = address of the message if the input was invalid.
;	[EBP + 16] = address of the location to which the flot number will be saved
;	[EBP + 20] = address of the location to which the number of digits inputted will be saved
; Returns:  [++++++++++++TBU++++++++++++]
; ------------------------------------------------------------------------------------
ReadFloatVal PROC
	; set up local variables and preserve registers
	LOCAL	sign:SDWORD, noLeadingZero:DWORD, ten:DWORD, digit:DWORD, maxBytes:DWORD, bytesInputted:DWORD, stringNumber[20]:BYTE
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI
_getString:
	LEA		ESI, stringNumber
	LEA		EDI, bytesInputted
	MOV		maxBytes, LENGTHOF stringNumber
	mGetString [EBP + 8], ESI, maxBytes, EDI
	; set up the registers
	MOV		EDX, [EBP + 20]
	MOV		DWORD PTR [EDX], 0			; holds a count of the number of digits inputted (needed for WriteFloatVal)
	MOV		ECX, bytesInputted			; length of string as the counter	
	LEA		ESI, stringNumber			; address of the integer string as source
	MOV		EDI, [EBP + 16]				; address of destination (REAL10)
	MOV		sign, 1						; set up the sign as 1 (for positive)
	MOV		ten, 10						; put the value ten into a memory variable for FPU calcs
	MOV		noLeadingZero, 0			; will be used to test for leading 0's in the string (i.e.  -00908.875)
	FINIT								; initialize the FPU
	CLD									; iterate forwards through array
	
	; see if the first digit is a '+' or a '-'
	LODSB
	CMP		AL, 43
	JE		_plusSymbol
	CMP		AL, 45
	JE		_minusSymbol
	; if no symbol, decrement ESI in order to re-evaluate that digit again; set ST(0) as zero
	DEC		ESI
	FLDZ
	JMP		_intLoop

_minusSymbol:
	; if first digit is a '-' change the sign to 1 (for negative)
	MOV		sign, -1
_plusSymbol:
	; for either symbol, decrement the char count; set ST(0) as zero
	DEC		ECX
	FLDZ
	JMP		_intLoop


_intLoop:
	; get the next digit in the string; validate & convert from ASCII to integer number
	MOV		EAX, 0
	LODSB
	CMP		AL, 46
	JE		_decimalPoint
	CMP		AL, 48
	JB		_notValid
	CMP		AL, 57
	JA		_notValid
	SUB		AL, 48
	; if the digit is not a zero, increment the digit count
	CMP		AL, 0
	JNE		_incrementDigitCount
	; if the digit is not a leading digit, increment the digit count
	CMP		noLeadingZero, 0
	JNE		_incrementDigitCount
	JMP		_skipIncrementDigitCount
	_incrementDigitCount:
	; increment the count of digits inputted
	MOV		noLeadingZero, 1
	MOV		EDX, [EBP + 20]
	INC		DWORD PTR [EDX]
	_skipIncrementDigitCount:
	; multiply the prior value on the stack by 10
	FILD	ten
	FMUL
	; load the digit onto the FPU stack
	MOV		digit, EAX
	FILD	digit
	; multiply the value by the sign (either 1 or -1)
	FILD	sign
	FMUL
	; add this value to the prior value on the stack and loop to next digit
	FADD
	LOOP	_intLoop

	; if all digits are read and no decimal point was reached, store final value into the output and end
	FSTP	REAL10 PTR [EDI]
	JMP		_end


_decimalPoint:
	; start building the fractional part of the number
	DEC		ECX					; decrement ECX to account for the decimal point character
	LEA		ESI, stringNumber	; change the address to the end of the string
	ADD		ESI, bytesInputted
	DEC		ESI
	STD							; set the direction flag to increment backwards
	FLDZ						; ST(1) holds the 'integer part'; initialize 'fractional part' at ST(0) as the value zero

_floatLoop:
	; divide the prior value on the FPU stack by 10
	FILD	ten
	FDIV
	; get the next digit in the string; validate & convert from ASCII to integer number
	MOV		EAX, 0
	LODSB
	CMP		AL, 48
	JB		_notValid
	CMP		AL, 57
	JA		_notValid
	SUB		AL, 48
	; increment the count of digits inputted
	MOV		EDX, [EBP + 20]
	INC		DWORD PTR [EDX]
	; load the value onto the FPU stack and divide it by 10
	MOV		digit, EAX
	FILD	digit
	FILD	ten
	FDIV
	; multiply the value by the sign (either 1 or -1)
	FILD	sign
	FMUL
	; add this value to the prior value on the stack and loop to next digit
	FADD
	LOOP	_floatLoop

	; upon completion of all the 'fractional part' digits, add the integer part at ST(1) to the fractional part at ST(0)
	FADD
	FSTP	REAL10 PTR [EDI]
	JMP		_end


_notValid:
	; print an error message to the user and go back to get another string
	MOV		EDX, [EBP + 12]
	CALL	WriteString
	JMP		_getString


_end:
	; restore registers and return
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		16
ReadFloatVal ENDP


; ------------------------------------------------------------------------------------
; Name: WriteFloatVal
; Description: [++++++++++++TBU++++++++++++]
; Preconditions: [++++++++++++TBU++++++++++++]
; Postconditions: [++++++++++++TBU++++++++++++]
; Receives: 
;	ST(0)	  = the float number to write
;	[EBP + 8] = the number digits in the number (e.g. 987.1259 has 7 digits)
; Returns:  [++++++++++++TBU++++++++++++]
; ------------------------------------------------------------------------------------
WriteFloatVal PROC
	LOCAL ten:DWORD, roundNormal:WORD, roundDown: WORD, exponent:DWORD, digit:DWORD, stringNumber[20]:BYTE
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI


	; set up the initial register and local variable values
	MOV		ten, 10							; variable 10 used for FPU arithmetic
	MOV		exponent, 0						; will hold the number of digits the dec point is shifted
	MOV		digit, 0						; will hold the current digit in the string
	LEA		EDI, stringNumber				; EDI holds the address of the string representation
	CLD										; iterate forwards through array
	MOV		ECX, [EBP + 8]					; counter holds the number of digits in the number
	MOV		EAX, 0							; clear the accumulator
	MOV		roundDown, 0000011101111111b	; default control word
	MOV		roundNormal, 0000001101111111b	; control word setting RC to round down
	FLDCW	roundDown						; set control word RC to roundDown


	; if ST(0) is negative, add a '-' as the first character in the string and convert to positive
	FTST									; instruction for: CMP ST(0), 0.0
	FNSTSW	AX
	SAHF									; copy status word into EFLAGS
	JAE		_SciNotationLoop
	MOV		AL, "-"
	STOSB
	FABS									; change float to absolute value	


	; this code block transforms '978.875' into '9.78875' while tracking the # of decimal point moves (into 'exponent' variable)
_SciNotationLoop:
	; check if the float is truncated to one digit
	FIST	digit
	CMP		digit, 10
	JB		_toStringLoop
	; othwerwise divide the float by 10 and increment count of decimal point moves
	FILD	ten
	FDIV
	INC		exponent
	JMP		_SciNotationLoop


	; at this point, the float is at ST(0) and looks like '9.78875' and exponent holds '2'
	; this code block dumps the float into a string representation digit by digit; ECX has the number of digits (e.g. 6 for above example)
_toStringLoop:
	; if this is the NOT the final digit round down; if it is the final digit, round it (change control WORD to default)
	CMP		ECX, 1
	JNE		_roundDown
	FLDCW	roundNormal
	_roundDown:
	FIST	digit
	; add the digit to the string
	MOV		EAX, digit
	ADD		EAX, 48
	STOSB
	; subtract the digit from the float (e.g. 9.78875 - 9 = 0.78875)
	FILD	digit
	FSUB
	; multiply that value by 10 to move the decimal point (e.g. 0.78875 * 10 = 7.8875)
	FILD	ten
	FMUL
	; if the exponent counter == 0, add a decimal point to the string output
	CMP		exponent, 0
	JNE		_skipDecimal
	MOV		AL, "."
	STOSB
	_skipDecimal:	
	DEC		exponent
	LOOP	_toStringLoop
	

	; add a null-terminator as the final string character
	MOV		EAX, 0
	STOSB
	; display the string
	LEA		ESI, stringNumber
	mDisplayString ESI


	; restore registers and return
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		4
WriteFloatVal ENDP



END main
