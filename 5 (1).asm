		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'    $'

start:		push	cs
		pop	ax
		push	cs
		pop	es
		mov	di,offset m1
		cld
		call	h4

		mov	dx,offset m1
		mov	ah,9
		int	21h
		ret

h4:		push	ax
		mov	al,ah
		call	h2
		pop	ax
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
