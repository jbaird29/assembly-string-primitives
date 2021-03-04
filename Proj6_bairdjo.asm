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

.data
numArray		SDWORD	TEST_COUNT DUP(?)
saved			BYTE	10 DUP(0)
bytesRead		DWORD	?
greeting		BYTE	"Project 6: Designing low-level I/O procedures.     By: Jon Baird"
prompt			BYTE	"Please provide 10 signed decimal integers. ",13,10,
						"Each number needs to be small enough to fit inside a 32 bit register. ",
						"After you have finished inputting the raw numbers I will display a list ",
						"of the integers, their sum, and their average value.",13,10,13,10


.code
main PROC
	PUSH	OFFSET bytesRead
	PUSH	SIZEOF saved
	PUSH	OFFSET saved
	PUSH	OFFSET prompt
	CALL	ReadVal
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
;	[EBP + 12] = address of the location to which the string is saved
;	[EBP + 16] = maximum number of BYTES which can be read
;	[EBP + 20] = count of the number of BYTES actually read
; Returns: none
; ------------------------------------------------------------------------------------
ReadVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	mGetString [EBP + 8], [EBP + 12], [EBP + 16], [EBP + 20]
	POP		EBP
	RET		16
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
