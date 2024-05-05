; Cesar soto
; Assembler Template
.386P
.model flat

extern   _ExitProcess@4: near

.data

.code
division PROC near
    _division:
           pop  edx          ;store return address
           pop  eax          ;stores numerator in eax
           pop  ebx          ;stores denomator in ebx
           push edx         ;restore return address to the stack
           xor  edx,edx      ;Zeros out edx
           idiv ebx         ;Divides ebx and eax
           ret              ;returns with answer in eax and remainder in edx
division ENDP
END
