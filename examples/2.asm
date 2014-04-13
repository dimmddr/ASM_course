		model	tiny
		.code
		org	100h
_:		jmp	start

m2		db	'Hello, I',27h,'m TSR!',13,10,'$'

start:		mov	dx,offset m2
		mov	ah,9
		int	21h

		mov	dx,12h
		mov	ax,3100h
		int	21h
		end	_
