    .MODEL TINY
    .386
    .CODE
    ORG 100H
_:
	push bx
	push es
		;save old interrupt handler
		xor bx, bx
		mov es, bx
		mov bx, [es:024h]
		mov word ptr int_9_old, bx
		xor bx, bx
		mov es, bx
		mov bx, [es:026h]
		mov word ptr int_9_old + 2, bx
	pop es
	pop bx
	
	;set our interrupt handler
	push ax
	push es
		xor ax, ax
		mov es, ax
		cli
		mov word ptr es:[024H], offset int_9
		mov word ptr es:[026h], cs
		sti
	pop es
	pop ax
_c:
	cmp f9, 1
	jne _c
	
	mov ah, 09h
    lea dx, err_msg
    int 21h
	
	push ds
	push ax
	push es
		push ds
			lds dx, int_9_old
		pop ds
		push dx
			mov ah, 09h
			lea dx, err_msg
			int 21h
		pop dx
		;pop ds
		xor ax, ax
		mov es, ax
		cli
		mov word ptr es:[024h], dx
		mov word ptr es:[026h], ds
		sti
	pop es
	pop ax
	pop ds
    ret
	
int_9:
	push ax
	push ds
	sti
	mov ax, cs
	mov ds, ax
	in al, 60h	;get scan code
	cmp al, 1
	jne _1
	mov cs:f9, al
_1:
	call print
	in al, 061h			;Send acknowledgment without modifying the other bits.
    or al, 10000000b
	out 061h, al
	and al, 01111111b
	out 061h, al
	mov al, 020h
	out 20h, al
	pop ds
	pop ax
	iret
eod_handler:
    ret

print:
	pusha
	push ds
	push es
		push cs
		pop ds
		push cs
		pop es
		mov di, offset m0
		cld
		call h2
		mov al, m0
		mov ah, 0Eh
		int 10h
		mov al, m0 + 1
		mov ah, 0Eh
		int 10h
		mov al, 13
		mov ah, 0Eh
		int 10h
		mov al, 10
		mov ah, 0Eh
		int 10h
	pop es
	pop ds
	popa
h2:		
	push	ax
		shr	al, 4
		call	h1
	pop	ax
h1:		
	push	ax
		and	al, 0Fh
		cmp	al, 10
		sbb	al, 69h
		das
		stosb
	pop	ax
	ret
err_msg 	db "Error!", 13, 10, '$'
endline		db	13,10,'$'
int_9_old	dd	0, 0
f9			db	0
m0			db	'  '
end _
