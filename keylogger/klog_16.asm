    .MODEL TINY
    .386
    .CODE
    ORG 100H
_:
	xor ah, ah
	int 16h
	push ax
		push ax
			push ax
			pop cx
			call print				;print 16h result
			mov dx, offset space	;print space
			mov ah, 09
			int 21h
		pop ax	;print symbol
		mov ah, 0Ah
		mov bh, 0
		mov cx, 1
		int 10h
		
		mov dx, offset endline
		mov ah, 9
		int 21h
	pop ax
	cmp al, 1Bh
	jne _
	ret
print:
	pusha ;This instruction pushes the eight general-purpose registers
	lea	bx,sym_tab
	mov	ax,cx
	shr	ax,12
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	mov	ax,cx
	shr	ax,8
	and	al,0Fh
	xlat
	mov	dl,al
	mov	ah,02
	int	21h

	mov	dx,offset space ;печатаем пробел
	mov	ah,9
	int	21h

	mov	ax,cx
	shr	ax,4
	and	al,0Fh
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	mov	ax,cx
	and	ax,0Fh
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	popa ;Use POPA to pop all the registers again
	ret
err_msg 	db "Error!", 13, 10, '$'
endline		db	13,10,'$'
space		db	' ', '$'
symb		db	' ', '$'
sym_tab		db	"0123456789ABCDEF"
end _
