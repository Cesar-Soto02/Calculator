; Cesar soto
; Calculator Program
; Gets the two numbers from the user, then lets them select what operation 
;they want to preform, then loops until the user chooses to exit.

; EAX - Set with lower 32-bits of 64-bit dividend, after idiv holds the quotient
; EDX - Set with upper 32-bits of 64-bit dividend, after idiv holds the remainder
; EBX - used as divisor, safest to set each time before divide
; ECX - Last available general register. Used as index into buffer to be written.

.386P
.model flat

extern   _GetStdHandle@4:near
extern   _WriteConsoleA@20:near
extern   _ReadConsoleA@20:near
extern   _ExitProcess@4: near

extern addition:near
extern subtraction:near
extern multiplication:near
extern division:near

.data

promptOne	    byte  10, "Please enter the first number. (0 - 65000)", 0 ; Prompts user to enter numbers for the calculation
promptTwo		byte  10, "Please enter the second number. (0 - 65000)", 10

menu			byte  10, "What type of calculation would you like to do?", 10, "1) Addition", 10, "2) Subtraction" , 10, "3) Multiplication", 10, "4) Division", 10, "5) Exit", 10 ;106
result          byte  10, "The answer to your calculation is: "
showRemainder   byte  10, "Remainder of: "
promptMenu      byte  10, "Enter 5 to exit, or any other number to go to again.", 10, 10

inputOne        dword ?     ;stores the first user input for calculation
inputTwo        dword ?     ;stores the second user input for calculation
menuSelection   dword ?     ;stores what menu the user selects

answer          dword ?     ;stores answer to the calculation.
remainder       dword ?     ;stores remaind when division is used.

outputHandle    dword ?     ;Holds handle for output
inputHandle     dword ?     ;Holds handle for input

count           dword 0     ;counter for program
countDown       dword ?     ;couter for program

written         dword ?     
wBindex         dword ?

numCharsToRead  dword 1024
numCharsRead    dword ?

writeBuffer     byte  1024 DUP(00h)
readBuffer      byte  1024 DUP(00h)

.code
main PROC near
_main:
    ;Get the handles for reading and writing
    push -11                                ;write handle
    call _GetStdHandle@4
    mov outputHandle, eax

    push -10 ;read handle
    call _GetStdHandle@4
    mov  inputHandle, eax

_GetUserPrompts:
    mov remainder, 0                ;sets remainder to 0
    
    ;Prompts user for first input.
    push 0
    push offset written
    push 45
    push offset promptOne
    push outputHandle
    call _WriteConsoleA@20                      

    ;Gets first input.
    call readline
    push offset readBuffer
    call stringToInt
    mov inputOne, eax                           ;Stores user input in inputOne

    ;Prompts user for their second input.
    push 0
    push offset written
    push 45
    push offset promptTwo
    push outputHandle
    call _WriteConsoleA@20

    ;Gets second input.
    call readline
    push offset readBuffer
    call stringToInt
    mov inputTwo, eax                           ;stores user input in inputTwo
    
    ;Creates menu for user to select a mathmatical operation
_menu:
    push 0
    push offset written
    push 114
    push offset menu
    push outputHandle
    call _WriteConsoleA@20

    call readline
    push offset readBuffer
    call stringToInt
    mov  menuSelection, eax                     ;stores what menu user selected
    

    push inputTwo                               ;pushes second input for selected operation
    push inputOne                               ;pushes first input for selected operation

    ;if menuSelection = 1, adds user inputs
    cmp menuSelection, 1
    je _add
    ;if menuSelection = 2, subtracts user inputs
    cmp menuSelection, 2
    je _sub
    ;if menuSelection = 3, multiplies user inputs
    cmp menuSelection, 3
    je _mult
    ;if menuSelection = 4, divides user inputs
    cmp menuSelection, 4
    je _div
    jmp _exit   ;jumps to _exit if input is not 1-4
    ;Adds user input then stores in answer
_add:
    call addition
    mov answer, eax
    jmp _display
    ;Subtracts user input then stores in answer
_sub:
    call subtraction
    mov answer, eax
    jmp _display
    ;Multiplies user input then stores in answer
_mult:
    call multiplication
    mov answer, eax
    jmp _display
    ;Divides user input then stores in answer
_div:
    call division
    mov answer, eax
    mov remainder, edx
    
;Displays the result of the operation
_display:
    push 0
    push offset written
    push 35
    push offset result
    push outputHandle
    call _WriteConsoleA@20

    push answer    
    call writeInt

    cmp remainder, 0
    jg _remainder

    jmp _promptForLoop
;exits the program
_exit:
    push	0
    call	_ExitProcess@4

;out puts the remainder if division was used.
_remainder:
    push 0
    push offset written
    push 15
    push offset showRemainder
    push outputHandle
    call _WriteConsoleA@20

    push remainder    
    call writeInt
;checks to see if the user wants to run again.
_promptForLoop:
    push 0
    push offset written
    push 55
    push offset promptMenu
    push outputHandle
    call _WriteConsoleA@20

    call readline
    push offset readBuffer
    call stringToInt
    mov  menuSelection, eax

    cmp menuSelection, 5
    je  _exit

    jmp _GetUserPrompts
main ENDP


readline PROC near
_readline:  
    push 0                                          ; Pushes null/0
    push offset numCharsRead                        ; pushes adress of numChars to read
    push numCharsToRead                             ; pushes 
    push offset readBuffer                          ; pushes address of read buffer
    push inputHandle                                ; pushes input handle
    call _ReadConsoleA@20                           ; Gets input from user
    ret
readline ENDP

writeline PROC near
_writeline:
        pop		eax									; Saving the stack pointer to eax.
        pop		edx									; popping the pointer to the output
        pop		ecx									; saving the num of characters
        push	eax									; Push content of EAX onto the top of the stack.

        ; WriteConsole(handle, &msg[0], numCharsToWrite, &written, 0)
        push    0                                   ; push 0 onto the top of the stack
        push    offset written						; pushes the address of written to the stack
        push    ecx									; return ecx to the stack for the call to _WriteConsoleA@20 (20 is how many bits are in the call stack)
        push    edx                                 ; return edx to the stack for WriteConsole
        push    outputHandle						; pushes outputHandle onto the stack for WriteConsole
        call    _WriteConsoleA@20					; Calls WriteConsole function
        ret											; returns to line writeline was called at.
writeline ENDP

writeInt PROC near
    _writeInt:
            pop ebx                                 ; Save the return address
            pop eax                                 ; Save first number to convert in register EAX
            push ebx                                ; Restore return address, this frees up EBX for use here.
            mov count, 0                            ; Reset count to 0
    _convertLoop:
            ; Find the remainder and put on stack
            ; The choices are div for 8-bit division and idiv for 64-bit division. To use full registers, I had to use 64-bit division
            mov  edx, 0                             ; idiv starts with a 64-bit number in registers edx:eax, therefore I zero out edx.
            mov  ebx, 10                            ; Divide by 10.
            idiv ebx
            add  edx,'0'                            ; Make remainder into a character by adding it to a character/ASCII 0.
            push edx                                ; Put in on the stack for printing this digit
            inc  count
            cmp  eax, 0
            jg   _convertLoop                       ; Go back if there are more characters
            mov  wBIndex, offset writeBuffer
            mov     ebx, wBIndex
            mov  byte ptr [ebx], ' '                ; Add starting blank space
            inc  ebx                                ; Go to next byte location
            mov     ecx, count                      ; EBX is being reloading each divide, so I can use it here to
            mov     countDown, ecx                  ; transfer value to set up counter to go through all numbers
    _fillString:
            pop     eax                             ; Remove the first stacked digit
            mov  [ebx], al                          ; Write it in the array
            dec     countDown
            inc  ebx                                ; Go to next byte location
            cmp     countDown, 0
            jg   _fillString
            mov  byte ptr[ebx], 0                   ;Add end zero
            inc  count                              ; Take into account extra space
            push count                              ; How many characters to print
            push offset writeBuffer                 ; And the buffer itself
            call writeline

            ret                                     ; And return
writeInt ENDP

stringToInt PROC
_stringToInt:
    ; Save the need information
    pop  edx                     ; Save the current stack pointer
    pop  ecx                     ; Save the address of the buffer with the number string
    push edx                    ; Restore stack pointer to the top of the stack.

    ; Take what was read and convert to a number
    mov  eax, 0                ; Initialize the number
    mov  ebx, 0                ; Make sure upper bits are all zero.
    
_findNumberLoop:
    mov   bl, [ecx]      ; Load the low byte of the EBX reg with the next ASCII character.
    cmp   bl, '9'               ; Make sure it is not too high
    jg   _endNumberLoop
    sub   bl, '0'               
    cmp   bl, 0                 ; or too low
    jl    _endNumberLoop
    mov   edx, 10              ; save multiplier for later need
    mul   edx
    add   eax, ebx
    inc   ecx                   ; Go to next location in number
    jmp   _findNumberLoop

 _endNumberLoop:
    ret                         ; EAX has the new integer when the code completes. And ) if no digits found.
stringToInt ENDP
END