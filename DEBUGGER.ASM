    .MODEL TINY
    .386
    .CODE
    ORG 100H
psp = ((buf-_+100h) + 15)/16*16
prog = psp+100h
_:
    mov ah, 03Dh
    xor al, al
    lea dx, fname
    int 21h

    jc err_

    mov bx, ax
    mov ah, 03Fh
    mov cx, 0FFFFh
    mov dx, prog
	int 21h

    jc err_

    mov ah, 09h
    lea dx, msg
    int 21h

    mov ah, 03Eh
    int 21h

    jc err_

    ;save vector 01
    mov ah, 035h
    mov al, 01h
    int 21h
    mov word ptr old_01, bx
    mov word ptr old_01+2, es

    ;save vector 03
    mov ah, 035h
    mov al, 03h
    int 21h
    mov word ptr old_03, bx
    mov word ptr old_03+2, es

    ;set new vector
    pushf
    cli
       mov ah, 25h
       mov al, 01h
       mov dx, offset int_01_handler
       push ds
       push cs
       pop ds
       int 21h
       mov al, 03h
       mov dx, offset int_03_handler
       int 21h
       pop ds
    sti
    popf

    mov ax, psp/16
    push cs
    pop bx
    add ax, bx
    
    mov bx, psp
    mov byte ptr [bx], 0CBh

	mov bx, psp+10h 				;находим место для устанвоки брейкпоинта;
	mov cl, [bx + 0F5h] 			;запоминаем оригинальную команду
	mov [bx], cl
	mov byte ptr [bx + 0F5h], 0CCh 	;устанавливаем брейкпоинт
	
    mov ds, ax

    push cs
    push offset eod_handler
    push 0
    push ax
    push 100h
	
    retf

    ret
eod_handler:
    ;mov ah, 09h
    ;lea dx, fname
    ;int 21h
    ;lds dx, old_01
    ;mov ah, 25h
    ;mov al, 01h
    ;int 21h
    ;lds dx, old_03
    ;mov al, 03h
    ;mov ah, 25h
    ;int 21h
    ret

err_:
    mov ah, 09h
    lea dx, err_msg
    int 21h
    ret

int_01_handler proc
	push bp
    push cx
	push ax
	push dx	
    
		mov bp, sp 
		add bp, 08h
		mov cx, [bp] ;now ip in cx.
		sub bp, 08h
		
		push ds	
			push cs 
			pop ds

			call print_word ;Печатаем cx <=> ip
			push dx
			mov	dx, offset endline ;печатаем перевод строки
			mov	ah, 09h
			int	21h
			pop dx
		
		pop ds 
    pop dx
    pop ax
    pop cx
    pop bp
    iret
int_01_handler endp

int_03_handler proc
	push bp ;save everything
    push cx
	push ax
	push dx	

		mov bp,sp ;memorize cs, ip
		add bp, 8h
		mov cx, [bp]
		add bp, 2h
		mov bx, [bp]
		sub bp, 2h
		sub bp, 8h
		
		push ds

			push cs
			pop ds

			call	print_word

			push es ;надо использовать es, чтобы обращаться к конкретному месту в памяти через регистр
				mov es, bx
				mov cl, [es:10h] ;в прямую запишем jump в исходное место. (Все циферки проверяются в файле HW1.lst или turbo debugger'ом)
				mov [es:105h], cl
			pop es

		pop ds ;восстанавливаем все
    pop dx
    pop ax
    pop cx
    pop bp

	pop cx ;ip то указывает на то место, что идет после брейкпоинта, а не на него самого (поэтому печатается 106, а не 105)
	sub cx, 1h ;поэтому вручную вернем ip на ту команду, что мы зачистили CC'шкой
	push cx
		
	;А дальше выставим флаг трассировки и пойдем по всем инструкциям
	pushf
		mov bp, sp
		or word ptr[bp+0], 0100h
	popf
    iret
int_03_handler endp

print_word:
	pusha
	lea	bx, sym_tab
	mov	ax, cx
	shr	ax, 12
	xlat
	mov	dl, al
	mov	ah, 02
	int	21h
	mov	ax, cx
	shr	ax, 8
	and	al, 0Fh
	xlat
	mov	dl, al
	mov	ah, 02
	int	21h
	mov	ax, cx
	shr	ax, 4
	and	al, 0Fh
	xlat
	mov	dl, al
	mov	ah, 02
	int	21h
	mov	ax, cx
	and	ax, 0Fh
	xlat
	mov	dl, al
	mov	ah, 02
	int	21h
	popa
	ret

sym_tab	db	"0123456789ABCDEF"

fname db "example.com",0
err_msg db "Error!$"
msg db "File load succesfully!", 13, 10, '$'
endline	db	13,10,'$'
old_01 dd ?
old_03 dd ?

buf:
end _
