    .MODEL TINY
    .386
    .CODE
    ORG 100H
_:
	push bx
	push es
		xor bx, bx
		mov es, bx
		mov bx, [es:024h]
		mov word ptr int_9, bx
		xor bx, bx
		mov es, bx
		mov bx, [es:026h]
		mov word ptr int_9 + 2, bx
	pop es
	pop bx
    ret
eod_handler:
    ret

int_handler proc
	push bp
    push cx
	push ax
	push dx	
		
		
    pop dx
    pop ax
    pop cx
    pop bp
    iret
int_handler endp

err_msg db "Error!$"
endline	db	13,10,'$'
int_9	dd	0
end _
