; Cesar soto
; Assembler Template
.386P
.model flat

extern   _ExitProcess@4: near

.data

.code
multiplication PROC near
	_multiplication:
      pop  edx                    ; Save the return address
      pop  eax                    ; Save second number in register EAX
      pop  ebx                    ; Save first number in EBX
      push edx                    ; Restore return address
      imul ebx                    ; Multiply them and store result in EAX
      ret                         ; And return with result in EAX
multiplication ENDP

END
