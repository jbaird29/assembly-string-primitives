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
mGetString MACRO prompt, output, size, bytesRead
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX
	MOV		EDX, prompt
	CALL	WriteString
	MOV		EDX, output
	MOV		ECX, size
	CALL	ReadString
	MOV		EDI, bytesRead
	MOV		[EDI], EAX
	POP		EAX
	POP		ECX
	POP		EDX
ENDM

mDisplayString MACRO string
	PUSH	EDX
	MOV		EDX, string
	CALL	WriteString
	POP		EDX
ENDM

; (insert constant definitions here)
TEST_COUNT = 10
;MAX_NUM = 2147483647
;MIN_NUM = -2147483648


.data
numArray		SDWORD	TEST_COUNT DUP(?)
saved			BYTE	11 DUP(0)
value			SDWORD	?
bytesRead		DWORD	?
greeting		BYTE	"Project 6: Designing low-level I/O procedures.     By: Jon Baird",13,10,13,10,0
instructions	BYTE	"Please provide 10 signed decimal integers. ",13,10,
						"Each number needs to be small enough to fit inside a 32 bit register. ",13,10,
						"After you have finished inputting the raw numbers I will display a list of the integers, ",13,10,
						"their sum, and their average value.",13,10,13,10,0
prompt			BYTE	"Please enter a signed intger: ",0
invalidMsg		BYTE	"ERROR. You did not enter a signed number or your number was too big.",13,10,0

.code
main PROC
	; introduce the program
	MOV		EDX, OFFSET greeting
	CALL	WriteString
	MOV		EDX, OFFSET instructions
	CALL	WriteString

	; get a number
	PUSH	OFFSET invalidMsg
	PUSH	OFFSET value		; PLACEHOLDER - replace with array location
	PUSH	OFFSET bytesRead
	PUSH	SIZEOF saved
	PUSH	OFFSET saved
	PUSH	OFFSET prompt
	CALL	ReadVal
	CALL	CrLf
	MOV		EAX, value
	CALL	WriteInt
	CALL	CrLf
	mDisplayString OFFSET saved
	CALL	CrLf
	MOV		EAX, bytesRead
	CALL	WriteDec
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
;	[EBP + 16] = value of the maximum number of BYTES which can be read
;	[EBP + 20] = address of the count of the number of BYTES actually read
;	[EBP + 24] = address of the location to which the integer number will be saved
;	[EBP + 28] = address of the message if the input was invalid.
; Returns:  [++++++++++++TBU++++++++++++]

; TODO - validatate that there is no overflow
; TODO - read a + and - sign
; ------------------------------------------------------------------------------------
ReadVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	EAX
	PUSH	EBX
_getString:
	mGetString [EBP + 8], [EBP + 12], [EBP + 16], [EBP + 20]
	; set up the registers
	MOV		ESI, [EBP + 20]
	MOV		ECX, [ESI]				; length of string as the counter	
	MOV		ESI, [EBP + 12]			; address of the integer string as source
	MOV		EDI, [EBP + 24]			; address of destination
	MOV		EAX, 0					; empty the accumulator

_charLoop:
	; multiply accumulator by 10 and temporarily store into EBX
	MOV		EBX, 10
	IMUL	EBX
	JO		_notValid
	MOV		EBX, EAX
	; load the integer string, subtract by 48 to convert from ASCII to integer number
	MOV		EAX, 0					; empty the accumulator
	LODSB
	CMP		AL, 48
	JB		_notValid
	CMP		AL, 57
	JA		_notValid
	SUB		AL, 48
	; add the prior accumulator to this number and loop to next digit
	ADD		EAX, EBX
	JO		_notValid
	LOOP	_charLoop
	; store into the output and end the procedure
	MOV		[EDI], EAX
	JMP		_end

_notValid:
	MOV		EDX, [EBP + 28]
	CALL	WriteString
	JMP		_getString

_end:
	POP		EBX
	POP		EAX
	POP		ESI
	POP		EBP
	RET		24
ReadVal ENDP


; ------------------------------------------------------------------------------------
; Name: WriteVal
; Description: [++++++++++++TBU++++++++++++]
; Preconditions: [++++++++++++TBU++++++++++++]
; Postconditions: [++++++++++++TBU++++++++++++]
; Receives: 
;	[EBP + 8] = 
;	[EBP + 12] = 
;	[EBP + 16] = 
;	[EBP + 20] = 
; Returns: none
; ------------------------------------------------------------------------------------
WriteVal PROC
	; TBU

WriteVal ENDP


END main
