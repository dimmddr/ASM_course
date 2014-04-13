		model	tiny
		.code
		org	100h
_:		jmp	start

m0		db	'Begin',13,10,'$'
m1		db	'End',13,10,'$'

start:		mov	dx,offset m0
		mov	ah,9
		int	21h

		mov	al,0B4h
		out	43h,al
		mov	dx,12h
		mov	ax,34DDh
		mov	cx,100
		div	cx
		out	42h,al
		mov	al,ah
		out	42h,al

		mov	cx,1000
_c0:		push	cx
		mov	bx,-1

_c1:		mov	al,80h
		out	43h,al
		in	al,42h
		mov	ah,al
		in	al,42h
		xchg	ah,al

		cmp	bx,ax
		mov	bx,ax
		ja	_c1

		pop	cx
		loop	_c0

		mov	dx,offset m1
		mov	ah,9
		int	21h
		ret
		end	_
