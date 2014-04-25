	.model tiny
	.386
	.code
	org	100h
psp = ((buf-_+100h) + 15)/16*16
prog	= psp+100h
_:
	mov	ah,03Dh
	xor	al,al
	lea	dx,fname
	int	21h

	jc	err_

	mov	bx,ax
	mov	ah,03Fh
	mov	cx,0FFFFh
	mov	dx,prog
	int 21h

	jc	err_
	
	mov	ah,09h
	lea	dx,msg
	int	21h	

	mov	ah,03Eh
	int	21h

	jc	err_

		
	mov	ax,psp/16
	push	cs
	pop	bx
	add	ax,bx

	mov	bx, psp
	mov	byte ptr [bx], 0CBh ;фигачим в psp в начало retf (CBh)

	mov	ds, ax
	
	push	cs
	push	offset eod_handler	
	push	0		;когда загруженная программа делает свой ret, то прыгнет на это значение. 0 это начало psp, а его первый байт - команда, которая завершается. 
	;Тут прога видит CBh который есть retf и снова достает из стека значения куда прыгать. А там уже лежит наш eod_handler
	push	ax		;cs загруженной программы
	push	100h	;ip ее же
	retf	;
	
	;0CCh код команды int 03
	
	ret
eod_handler:
	
	ret
err_:
	mov	ah,09h
	lea	dx,err_msg
	int	21h

	ret

fname	db	"hw1.com",0
err_msg	db	"Error!$"
msg	db	"File load successfully!$"

print_word:
	pusha
	lea	bx,sym_tab
	mov	ax,cx
	shr	ax,12
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	mov	ax,cx
	shr	ax,8
	and	al,0Fh
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	mov	ax,cx
	shr	ax,4
	and	al,0Fh
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	mov	ax,cx
	and	ax,0Fh
	xlat
	mov	dl,al
	mov	ah,02
	int	21h
	popa
	ret

sym_tab	db	"0123456789ABCDEF"

buf:
end	_
