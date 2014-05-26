model	tiny
	.code
	.386
	org	100h
_:		
	mov	dx, 0CF8h	;запонимаем адрес confid_address регистра
	mov	ecx, 80000000h	;это в двоичной системе даст нам нулевую шину, нулевое устройство, нулевую функцию. 
_c:		
	mov	eax, ecx	;адрес устройства запоминаем в eax
	add	eax, 0Ch	;добавляем в адрес устройства к битам, отвечающим за регистр, 0Ch. 
	;Теперь мы сможем получить строчку в которой есть поле header type, а в его первом бите увидеть мультифункциональное ли устройство (читаем ссылку в начале)
	out	dx, eax		;отправляем в config_address регистр адрес нужного устройства. Доступ получим к регистру 0Ch 
	add	dx, 4		;переходим к config_data регистру - CFC (CF8+4=CFC)
	in	eax, dx		;читаем из него содержимое регистра 0Ch
	sub	dx, 4		;возвращаемся с config_address регистру
	cmp	ax, -1		;если устройства нет (то есть из CFC вернулась -1) 
	je	end_of_all	;то уходим к коду end_of_all, иначе - печатаем

	xor	ebp, ebp	;ebp будет счетчиком функций, то есть если он дойдет до 8, то мы все остановим.
	shr	eax, 23		;делаем так, чтобы 23 бит был последним (он отвечает за определение мультифукциональное ли устройство)
	and	ax, 0001h	;теперь в ax будет только 23 бит.
	je	non_mult	;если устройство не мультифункционально, то мы прыгнем к коду non_mult

mult:
	;дальше код для мультифункциональных устройств
	mov	eax, ecx	;в eax будет адрес устройства с битами отвечающими за регистр равными 0
	shl	ebp, 8		;хотим перейти к следующей функции. Биты отвечающиие за номер функции - 10-8
	add	eax, ebp	;переходим к следующей функции
	shr	ebp, 8		;возвращаем исходное состояние ebp
	out	dx, eax		;просим доступ к конкретному устройству
	add	dx, 4		;переходим к config_data регистру
	in	eax, dx		;получаем product ID, device ID
	sub	dx, 4		;возвращаемся к config_address регистру
	cmp	ax, -1		;если устройства нет (то есть из CFC вернулась -1) 
	je	end_of_all	;то уходим к коду end_of_all, иначе - печатаем
	call	print_info	;печатаем все что нужно
	inc	bp		;увеличиваем bp (то есть перейдем к следующей фукции)
	cmp	bp, 8		
	jl	mult		;если увеличенное bp<8
	jmp	end_of_all	;если все функции были перечислены, то уходим к end_of_all

non_mult:				
	;дальше код для однофункциональных устройств
	mov	eax, ecx	;в eax будет адрес устройства с битами отвечающими за регистр равными 0
	shl	ebp, 8		;хотим перейти к следующей функции. Биты отвечающиие за номер функции - 10-8
	add	eax, ebp	;переходим к следующей функции
	shr	ebp, 8		;возвращаем исходное состояние ebp
	out	dx, eax		;просим доступ к конкретному устройству
	add	dx, 4		;переходим к config_data регистру
	in	eax, dx		;получаем product ID, device ID
	sub	dx, 4		;возвращаемся к config_address регистру
	cmp	ax, -1		;если устройства нет (то есть из CFC вернулась -1) 
	je	end_of_all	;то уходим к коду end_of_all, иначе - печатаем
	call	print_info	
	inc	bp		;увеличиваем bp
	cmp	bp, 8		
	jl	non_mult	;если увеличенное bp<8

end_of_all:	;Потому что end уже занят ассемблером...
	add	ecx, 0800h	;переходим не к следующей функции, а сразу к следующему устройству.
	test	ecx, 01000000h	;если мы еще не все устройства прошли
	jz	_c		;то повторяем все для следующего устройства
	ret			;иначе возвращаемся. Фокус в том, что 1000000h в двоичной системе имеет единицу только в 24 бите. Когда у нас исчерпаются все устройства, то этот бит станет единицей и мы по нему можем сказать, что пора заканчивать работу.

print_info:				;код для печати всего, что нужно
	push	edi
		push	ds
		pop	es
		
		;печатаем номер шины
		push ecx
			shr	ecx, 10h	;сдвигаем на 16, чтобы получить номер шины
			and	cx, 00FFh	;обнуляем все, кроме номера шины
			call	print_word	;печатаем номер шины
		pop ecx
		
		;печатаем номер устройства
		push ecx
			shr	ecx, 11		;сдвигаем, чтобы в конце получить номер устройства
			and	cl, 00011111b	;обнуляем все, кроме номера устройства
			call	print_word	;печатаем номер устройства
		pop ecx

		mov	edi, ecx		; edi for swap	;
		mov	ecx, ebp		; ebp has function number
		call	print_word		; печатаем номер функции

		mov	ecx, edi
		;печатаем product id, vendor id
		push	ecx
			push	eax
				shr	eax, 10h
				mov	cx, ax
				call	print_word ;конвертирует 16 бит из cx и печатает их
				;lea dx, msg_v
				;call msg_
			pop	eax
			mov	cx, ax
			call	print_word
		pop	ecx
		
		push	dx		; переход на следующую строку
		push	ax
			mov	dx, offset endline
			mov	ah, 09h
			int	21h
		pop	ax
		pop	dx
	pop	edi
print_end:
	ret

print_word:	;конвертирует 16 бит регистра cx в их ascii код и печатает.
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

		mov	ah, 02h
		mov	dl, 20h
		int	21h
	popa
	ret
	
	space		db ' ', 0
	endline		db 13, 10, '$'
	sym_tab		db	"0123456789ABCDEF"
buf:
end _