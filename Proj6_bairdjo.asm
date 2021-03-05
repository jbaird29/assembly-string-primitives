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

emptyString MACRO stringAddress:REQ, stringLength:REQ
	PUSH	ECX
	PUSH	EDI
	PUSH	EAX
	MOV		EDI, stringAddress
	MOV		ECX, stringLength
	MOV		AL, 0
	REP		STOSB
	POP		EAX
	POP		EDI
	POP		ECX
ENDM

; (insert constant definitions here)
TEST_COUNT = 5
;MAX_NUM = 2147483647
;MIN_NUM = -2147483648


.data
numArray		SDWORD	TEST_COUNT DUP(?)
readValString	BYTE	20 DUP(0)			; holds user-input (a string of digits, which will be converted into an integer)
bytesRead		DWORD	?					; holds the number of BYTES inputted by the user
readValInt		SDWORD	?					; holds the procedure output (an integer, which was conversion from a string of digits)
writeValString	BYTE	20 DUP(0)			; holds the procedure output (a string of digits, which was converted from an integer)
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


.code
main PROC
	; introduce the program
	mDisplayString OFFSET greeting
	mDisplayString OFFSET instructions

	; perform the test loop - get the numbers
	MOV		ECX, LENGTHOF numArray
	MOV		EDI, OFFSET numArray
_buildArrayLoop:
	; get a number via ReadVal, store into the currrent position of numArray
	PUSH	OFFSET invalidMsg
	PUSH	EDI
	PUSH	OFFSET bytesRead
	PUSH	LENGTHOF readValString
	PUSH	OFFSET readValString
	PUSH	OFFSET prompt
	CALL	ReadVal
	; increment to the next position of numArray, empty the input paramater, and repeat
	ADD		EDI, TYPE numArray
	emptyString OFFSET readValString, LENGTHOF readValString
	LOOP	_buildArrayLoop


	; display the numbers
	mDisplayString OFFSET displayMsg
	MOV		ECX, LENGTHOF numArray
	MOV		ESI, OFFSET numArray
_displayArrayLoop:
	; add the number in the current position of numArray to sum, and display it using WriteVal
	MOV		EBX, [ESI]
	ADD		sum, EBX
	PUSH	OFFSET writeValString
	PUSH	[ESI]
	CALL	WriteVal
	; inrement to the next position of numArray, empty the output paramater, and repeat
	ADD		ESI, TYPE numArray
	emptyString OFFSET writeValString, LENGTHOF writeValString
	; print a comma and space before the next value
	MOV		AL, ","
	CALL	WriteChar
	MOV		AL, " "
	CALL	WriteChar
	LOOP	_displayArrayLoop

	; display the sum
	CALL	CrLf
	mDisplayString OFFSET sumMsg
	emptyString OFFSET writeValString, LENGTHOF writeValString
	PUSH	OFFSET writeValString
	PUSH	sum
	CALL	WriteVal

	; calculate the average
	CALL	CrLf
	MOV		EAX, sum
	MOV		EDX, 0
	MOV		EBX, TEST_COUNT
	DIV		EBX
	MOV		average, EAX
	; display the average
	mDisplayString OFFSET avgMsg
	emptyString OFFSET writeValString, LENGTHOF writeValString
	PUSH	OFFSET writeValString
	PUSH	average
	CALL	WriteVal

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ------------------------------------------------------------------------------------
; Name: ReadVal
; Description: [++++++++++++TBU++++++++++++]
; Preconditions: [++++++++++++TBU++++++++++++]
; Postconditions: [++++++++++++TBU++++++++++++]
; Receives: 
;	[EBP + 8] = address of a prompt to display to the user
;	[EBP + 12] = address of the location to which the integer string will be saved
;	[EBP + 16] = value, the maximum number of BYTES which can be read
;	[EBP + 20] = address of the count of the number of BYTES actually read
;	[EBP + 24] = address of the location to which the integer number will be saved
;	[EBP + 28] = address of the message if the input was invalid.
; Returns:  [++++++++++++TBU++++++++++++]
;
; TODO - refactor with LOCAL variable?
; TODO - this incorrectly reads an overflow for -2147483648
; ------------------------------------------------------------------------------------
ReadVal PROC
	; set up local variables and preserve registers
	LOCAL	Sign:DWORD, MultipliedVal:SDWORD
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI
_getString:
	mGetString [EBP + 8], [EBP + 12], [EBP + 16], [EBP + 20]
	; set up the registers
	MOV		ESI, [EBP + 20]
	MOV		ECX, [ESI]				; length of string as the counter	
	MOV		ESI, [EBP + 12]			; address of the integer string as source
	MOV		EDI, [EBP + 24]			; address of destination (SDWORD)
	MOV		Sign, 0					; set up the sign as 0 (for positive)
	CLD								; iterate forwards through array
	
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
	MOV		Sign, 1
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
	MOV		MultipliedVal, EAX
	; load the integer string digit, subtract by 48 to convert from ASCII to integer number
	MOV		EAX, 0					; empty the upper range of the accumulator
	LODSB
	CMP		AL, 48
	JB		_notValid
	CMP		AL, 57
	JA		_notValid
	SUB		AL, 48
	; if sign is negative, change the value to negative
	CMP		Sign, 0
	JE		_positive
	NEG		EAX	
_positive:
	; add the prior accumulator to this number and loop to next digit
	ADD		EAX, MultipliedVal
	JO		_notValid
	LOOP	_charLoop
	; store final value into the output and end
	MOV		[EDI], EAX
	JMP		_end

_notValid:
	; print an error message to the user and go back to get another string
	MOV		EDX, [EBP + 28]
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
	RET		24
ReadVal ENDP


; ------------------------------------------------------------------------------------
; Name: WriteVal
; Description: [++++++++++++TBU++++++++++++]
; Preconditions: [++++++++++++TBU++++++++++++] [the address of the location is long enough to store the value plus a null terminator (i.e. 12)]
; Postconditions: [++++++++++++TBU++++++++++++]
; Receives: 
;	[EBP + 8] = value of the number to convert to string & display
;	[EBP + 12] = address of the location to which the string representation will be saved
; Returns: [++++++++++++TBU++++++++++++]
; ------------------------------------------------------------------------------------
WriteVal PROC
	; preserve registers
	LOCAL	number:SDWORD, divisor:DWORD
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI
	
	; set up initial registers
	MOV		ESI, [EBP + 8]
	MOV		number, ESI				; move the number into local variable
	MOV		EDI, [EBP + 12]			; address of destination (BYTE string)
	MOV		ECX, 1					; to be set by digitCountLoop (987 will have ECX of 3; 9876 will have ECX of 4)
	MOV		divisor, 1				; to be set by digitCountLoop (987 will have divisor of 100; 9876 will have divisor of 10000)

	; if number is negative, make the first element of the string a '-', then convert number to positive
	CMP		number, 0
	JGE		_digitCountLoop
	MOV		AL, "-"
	STOSB
	NEG		number

	; figure out how many digits are in the number; this loop sets ECX and divisor (as noted above)
_digitCountLoop:
	; divide the number by divisor; if the quotient is a single digit, then the appropriate number of digits has been found
	MOV		EAX, number
	MOV		EDX, 0
	DIV		divisor
	CMP		EAX, 10
	JB		_digitToStringLoop
	; otherwise, multiply the divisor by 10, increment the counter by 1, and repeat
	MOV		EAX, divisor
	MOV		EBX, 10
	MUL		EBX
	MOV		divisor, EAX
	INC		ECX
	JMP		_digitCountLoop

_digitToStringLoop:
	; divide the number by the divisor, store the remainder as the next iteration's starting number
	MOV		EAX, number
	MOV		EDX, 0
	DIV		divisor
	MOV		number, EDX
	; convert the quotient into its ASCII representation and store in the array
	ADD		AL, 48
	STOSB
	; divide the divisor by 10
	MOV		EAX, divisor
	MOV		EDX, 0
	MOV		EBX, 10
	DIV		EBX
	MOV		divisor, EAX
	LOOP	_digitToStringLoop

	mDisplayString [EBP + 12]

_end:
	; restore registers and return
	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		8
WriteVal ENDP


END main
