		model	tiny
		.code
		.386
		org	100h
_:		jmp	start

m1		db	'         ',13,10,'$'

start:		mov	dx,0CF8h
		mov	ecx,80000000h

_c:		mov	eax,ecx
		out	dx,eax
		add	dx,4
		in	eax,dx
		sub	dx,4
		cmp	ax,-1
		je	_0

	;print
;		int	21h

_0:		add	ecx,100h
		test	ecx,1000000h
		jz	_c
		ret

h8:		push	ax
		mov	ax,dx
		call	h4
		inc	di
		pop	ax
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
