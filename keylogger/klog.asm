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
	
	push ds
	push ax
	push es
		lds dx, int_9_old
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
	push ax              ; Save registers
	push ds              ;
	sti
	mov ax, cs           ; Make sure DS = CS
	mov ds, ax           ;
	in al, 60h           ; Get scan code
	cmp al,1             ;
	jne	_1               ; Process event
	mov	cs:f9,al
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
		pop	ds
		push cs
		pop	es
		mov	di,offset m0
		cld
		call h2 ;convert to ascii code
		mov	al,m0
		mov	ah,9    ; 9 функция 10 прерывания - печать символа на месте курсора с атрибутами
		mov	bx, 0Fh ; записанными в bx 
		mov	cx,1    ; сколько раз напечатать символ
		int	10h     
		xor	bh,bh
		mov	ah,3    ; 3 функция 10 прерыванияполучить нынешнее положение курсора
		int	10h
		inc	dl      ;в dl номер столбца. Соответственно увеличиваем его
		mov	ah,2    ;2 функция 10 прерывания - переместить курсор
		int	10h
		mov	al,m0+1 ;печатаем второй символ
		mov	ah,9
		mov	bx, 0Fh
		mov	cx,1
		int	10h
		xor	bh,bh   ;сдвигаем курсор в начало строки
		mov	ah,3
		int	10h
		xor	dl, dl
		mov	ah,2
		int	10h

		mov ah, 06h ;6 функция 10 прерывание - window scroll up
		mov al, 1
		mov bh, 0Fh
		xor ch, ch
		xor cl, cl
		mov dh, 25
		mov dl, 85
		int 10h 

		pop	es
		pop	ds
		popa
		ret
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
