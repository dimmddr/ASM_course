		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, ASM!',13,10,'$'
l_m1		=	$-m1

start:		mov	ax,0B800h
		mov	es,ax
		mov	di,1000h
		mov	si,offset m1
		cld
		mov	cx,l_m1
		mov	al,1Fh
_c:		movsb
		stosb
		loop	_c

		xor	ah,ah
		int	16h
		ret
		end	_
