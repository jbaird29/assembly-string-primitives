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
	MOV		bytesRead, EAX
	PUSH	EAX
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
						"of the integers, their sum, and their average value."


.code
main PROC
	mGetString OFFSET prompt, OFFSET saved, SIZEOF saved, bytesRead
	CALL	CrLf
	mDisplayString OFFSET saved
	CALL	CrLf
	MOV		EAX, bytesRead
	CALL	WriteDec
	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)



END main
