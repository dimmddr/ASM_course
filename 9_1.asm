		model	tiny
		.code
		.386
		org	100h
_:		jmp	start

m0		db	'  ',13,10,'$'
m1		db	'KBD bye!',13,10,'$'

i9:		push	ax
		in	al,60h
		cmp	al,1
		jne	_1
		mov	cs:f9,al
_1:		call	prn
		pop	ax
		db	0EAh
v9		dd	0
f9		db	0

prn:		pusha
		push	ds
		push	es
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	di,offset m0
		cld
		call	h2
		mov	dx,offset m0
		mov	ah,9
		int	21h
		pop	es
		pop	ds
		popa
		ret

start:		mov	ax,3509h
		int	21h
		mov	word ptr v9,bx
		mov	word ptr v9+2,es

		mov	dx,offset i9
		mov	ax,2509h
		int	21h

_c:		cmp	f9,1
		jne	_c

		push	ds
		lds	dx,v9
		mov	ax,2509h
		int	21h
		pop	ds

		mov	dx,offset m1
		mov	ah,9
		int	21h
		ret

h2:		push	ax
		shr	al,4
		call	h1
		pop	ax
h1:		push	ax
		and	al,0Fh
		cmp	al,10
		sbb	al,69h
		das
		stosb
		pop	ax
		ret

		end	_
