		model	tiny
		.code
		org	100h
_:		jmp	start

m1		db	'Hello, INT!',13,10,'$'
f0		db	'(func 0)',13,10,'$'
f1		db	'(func 1)',13,10,'$'
fer		db	'(error)',13,10,'$'
v_f1		dd	0

i_f1:		or 	ah,ah
		jnz	f1_1
		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	dx,offset f0
		mov	ah,9
		int	21h
		iret
f1_1:		test	ah,0FEh
		jnz	f1_err
		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	dx,offset f1
		mov	ah,9
		int	21h
		iret
f1_err:		mov	dx,offset m1
		mov	ah,9
		int	21h
		mov	dx,offset fer
		mov	ah,9
		int	21h
		iret

start:		mov	ax,35F1h
		int	21h
		mov	word ptr v_f1,bx
		mov	word ptr v_f1+2,es

		mov	dx,offset i_f1
		mov	ax,25F1h
		int	21h

		xor	ah,ah
		int	0F1h

		mov	ah,1
		int	0F1h

		mov	ah,2
		int	0F1h

		lds	dx,v_f1
		mov	ax,25F1h
		int	21h
		ret
		end	_
