		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, KBD!',13,10,'$'

i16:
		db	0EAh
v16		dd	0

start:		mov	ax,3516h
		int	21h
		mov	word ptr v16,bx
		mov	word ptr v16+2,es
		mov	ax,2516h
		mov	dx,offset i16
		int	21h

		mov	dx,offset m1
		mov	ah,9
		int	21h

		mov	ax,3100h
		mov	dx,(start-_+100h+15)/16
		int	21h
		end	_
