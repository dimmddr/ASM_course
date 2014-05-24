model	tiny
	.code
	.386
	org	100h
psp = ((buf-_+100h) + 15)/16*16
prog = psp+100h
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
	jne	end_of_all	;то уходим к коду end_of_all, иначе - печатаем
	call	print_info	
	inc	bp		;увеличиваем bp
	cmp	bp, 8		
	jl	non_mult	;если увеличенное bp<8

end_of_all:	;Потому что end уже занят ассемблером...
	add	ecx, 0800h	;переходим не к следующей функции, а сразу к следующему устройству.
	;То есть процесс будет такой: Если устройство есть и оно мультифункционально, то пройдет перебор всех его функций и потом только переход к следующему устройству.
	;Если же устройство есть и оно однофункциональное (то есть первый раз когда мы его обнаружили и увидели, что оно однофункциональное), то мы печатаем его и после сразу переходим к следующему устройству, то есть мы пропустим весь мусор 
	;(хотя никто не сказал, что та функция, которую мы печатали не мусор. Вообще непонятно как определить какая из функций в наборе мусора будет настоящей).
	;В общем мы печатаем просто однофункциональное устройство просто в первый раз, когда его увидели и идем к следующему устройству.
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
			; push eax
				; lea dx, msg_p
				; call msg_
			; pop eax
		pop	ecx
		
		call	print_string		; from eax ;печатаем название устройства
		push	dx		; переход на следующую строку
		push	ax
			mov	dx, offset endline
			mov	ah, 09h
			int	21h
		pop	ax
		pop	dx
	pop	edi
	ret
print_string:
	cmp eax, 11063269h		;Последняя запись первого файла
	ja smth2
	lea dx, file_name1
	push eax	;открываем файл
		xor eax, eax
		mov ax, 3Dh
		int 21h
		
		jc err_
		
		mov bx, ax
		xor ax, ax
		mov ah, 3Fh
		mov cx, 0C350h	;Этого должно хватить	~50Кб
		mov dx, prog
		int 21h
		
		jc err_
		
		mov ah, 03Eh	;Закрываем файл
		int 21h
		
		jc err_
		
	pop eax
	mov esi, edx	;Потому что нельзя использовать edx как указатель
	
	mov ecx, [esi]
	call	print_word
	shr ecx, 10h
	call	print_word
	push	dx		; переход на следующую строку
	push	ax
		mov	dx, offset space
		mov	ah, 09h
		int	21h
	pop	ax
	pop	dx
	
	mov ecx, 1842   ;3685 / 2 - центр первого файла
	mov edx, ecx
	jmp search
smth2:
	lea dx, file_name2
	push eax	;открываем файл
		mov ax, 3Dh
		xor al, al
		int 21h
	push eax
		call err_
	pop eax
		
		jc err_
		
		mov bx, ax
		xor ax, ax
		mov ah, 3Fh
		mov cx, 0C350h	;Этого должно хватить	~50Кб
		mov dx, prog
		int 21h
		
		jc err_
		
		mov ah, 03Eh	;Закрываем файл
		int 21h
		
		jc err_
		
	pop eax
	mov esi, edx	;Потому что нельзя использовать edx как указатель
	
	; push eax
		; lea dx, msg_p
		; call msg_
	; pop eax
	
	mov ecx, [esi]
	call	print_word
	shr ecx, 10h
	call	print_word
	push	dx		; переход на следующую строку
	push	ax
		mov	dx, offset space
		mov	ah, 09h
		int	21h
	pop	ax
	pop	dx
	
	mov ecx, 1794   ;центр второго файла
	mov edx, ecx
search:
	cmp edx, 0
	je end_of_find
	push eax
        mov eax, ecx
		mov edi, 12
        mul edi
		mov edi, eax
	pop eax
	add edi, esi
	mov ebx, [edi]
	cmp ebx, eax
	je end_of_find	;Мне захотелось с этой проверкой сделать
	shr edx, 1
	ja above
	sub ecx, edx
	jmp search
above:
	add ecx, edx
	jmp search
		
end_of_find:
	add edi, 8
	mov cx, [edi]	;Считываем нужный номер строки
	lea dx, names
	xor eax, eax
	mov ax, 3Dh
	int 21h
		
	jc err_
		
	mov bx, ax		;Запомнили handler
	mov eax, ecx	;Готовимся умножать
	mov edx, 130	;130 - длина строки с названием
	mul edx
	mov dx, ax		;сохраняем значение смещения
	shr eax, 10h	
	mov cx, ax
	mov ah, 42h		
	mov al, 0
	int 21h			;сдвигаем указатель в файле
		
	jc err_
		
	mov ah, 3Fh
	mov cx, 130
	lea dx, string
	int 21h
		
	jc err_
		
	mov ah, 03Eh	;Закрываем файл
	int 21h
		
	jc err_
		
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
msg_:
    mov ah, 09h
    int 21h
    ret
err_:
	pusha
    mov ah, 09h
    lea dx, err_msg
    int 21h
	popa
    ret
	
	file_name1	db "smth", 0
	file_name2	db "smth2", 0
	names		db "names.txt", 0
	space		db ' ', 0
	endline		db 13, 10, '$'
	string		db '                                                                                                                                  ', 0
	msg_v		db	"Vendor Id: ", '$'
	msg_p		db	"Product Id: ", '$'
	err_msg 	db "Error!$"
	sym_tab		db	"0123456789ABCDEF"
buf:
end _