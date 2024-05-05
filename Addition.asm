; Cesar soto
; Assembler Template
.386P
.model flat

extern   _ExitProcess@4: near

.data

.code
addition PROC near
    _addition:
	     pop  edx                    ; Save the return address
         pop  eax                    ; Save second number in register EAX
         pop  ebx                    ; Save first number in EBX
         push edx                   ; Restore return address
         add  eax, ebx               ; Add them together and store in EAX
         ret                        ; And return with result in EAX
addition ENDP

END
