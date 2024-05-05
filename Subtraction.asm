; Cesar soto
; Assembler Template
.386P
.model flat

extern   _ExitProcess@4: near

.data

.code
subtraction PROC near
    _subtraction:
	         pop edx                    ; Save the return address
             pop eax                    ; Save second number in register EAX
             pop ebx                    ; Save first number in EBX
             push edx                   ; Restore return address
             sub eax, ebx               ; Subtract them and store in EAX
             ret                        ; And return with result in EAX
subtraction ENDP

END
