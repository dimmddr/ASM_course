		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, ASM!',13,10,'$'

start:		mov	dx,offset m1
		mov	ah,9
		int	21h
		ret
		end	_
