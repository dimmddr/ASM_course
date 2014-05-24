model	tiny
	.code
	.386
	org	100h
psp = ((buf-_+100h) + 15)/16*16
prog = psp+100h
_:		
	mov	dx, 0CF8h	;���������� ����� confid_address ��������
	mov	ecx, 80000000h	;��� � �������� ������� ���� ��� ������� ����, ������� ����������, ������� �������. 
_c:		
	mov	eax, ecx	;����� ���������� ���������� � eax
	add	eax, 0Ch	;��������� � ����� ���������� � �����, ���������� �� �������, 0Ch. 
	;������ �� ������ �������� ������� � ������� ���� ���� header type, � � ��� ������ ���� ������� �������������������� �� ���������� (������ ������ � ������)
	out	dx, eax		;���������� � config_address ������� ����� ������� ����������. ������ ������� � �������� 0Ch 
	add	dx, 4		;��������� � config_data �������� - CFC (CF8+4=CFC)
	in	eax, dx		;������ �� ���� ���������� �������� 0Ch
	sub	dx, 4		;������������ � config_address ��������

	xor	ebp, ebp	;ebp ����� ��������� �������, �� ���� ���� �� ������ �� 8, �� �� ��� ���������.
	shr	eax, 23		;������ ���, ����� 23 ��� ��� ��������� (�� �������� �� ����������� ������������������� �� ����������)
	and	ax, 0001h	;������ � ax ����� ������ 23 ���.
	je	non_mult	;���� ���������� �� �������������������, �� �� ������� � ���� non_mult

mult:
	;������ ��� ��� �������������������� ���������
	mov	eax, ecx	;� eax ����� ����� ���������� � ������ ����������� �� ������� ������� 0
	shl	ebp, 8		;����� ������� � ��������� �������. ���� ����������� �� ����� ������� - 10-8
	add	eax, ebp	;��������� � ��������� �������
	shr	ebp, 8		;���������� �������� ��������� ebp
	out	dx, eax		;������ ������ � ����������� ����������
	add	dx, 4		;��������� � config_data ��������
	in	eax, dx		;�������� product ID, device ID
	sub	dx, 4		;������������ � config_address ��������
	call	print_info	;�������� ��� ��� �����
	inc	bp		;����������� bp (�� ���� �������� � ��������� ������)
	cmp	bp, 8		
	jl	mult		;���� ����������� bp<8
	jmp	end_of_all	;���� ��� ������� ���� �����������, �� ������ � end_of_all

non_mult:				
	;������ ��� ��� ������������������ ���������
	mov	eax, ecx	;� eax ����� ����� ���������� � ������ ����������� �� ������� ������� 0
	shl	ebp, 8		;����� ������� � ��������� �������. ���� ����������� �� ����� ������� - 10-8
	add	eax, ebp	;��������� � ��������� �������
	shr	ebp, 8		;���������� �������� ��������� ebp
	out	dx, eax		;������ ������ � ����������� ����������
	add	dx, 4		;��������� � config_data ��������
	in	eax, dx		;�������� product ID, device ID
	sub	dx, 4		;������������ � config_address ��������
	cmp	ax, -1		;���� ���������� ��� (�� ���� �� CFC ��������� -1) 
	jne	end_of_all	;�� ������ � ���� end_of_all, ����� - ��������
	call	print_info	
	inc	bp		;����������� bp
	cmp	bp, 8		
	jl	non_mult	;���� ����������� bp<8

end_of_all:	;������ ��� end ��� ����� �����������...
	add	ecx, 0800h	;��������� �� � ��������� �������, � ����� � ���������� ����������.
	;�� ���� ������� ����� �����: ���� ���������� ���� � ��� �������������������, �� ������� ������� ���� ��� ������� � ����� ������ ������� � ���������� ����������.
	;���� �� ���������� ���� � ��� ������������������ (�� ���� ������ ��� ����� �� ��� ���������� � �������, ��� ��� ������������������), �� �� �������� ��� � ����� ����� ��������� � ���������� ����������, �� ���� �� ��������� ���� ����� 
	;(���� ����� �� ������, ��� �� �������, ������� �� �������� �� �����. ������ ��������� ��� ���������� ����� �� ������� � ������ ������ ����� ���������).
	;� ����� �� �������� ������ ������������������ ���������� ������ � ������ ���, ����� ��� ������� � ���� � ���������� ����������.
	test	ecx, 01000000h	;���� �� ��� �� ��� ���������� ������
	jz	_c		;�� ��������� ��� ��� ���������� ����������
	ret			;����� ������������. ����� � ���, ��� 1000000h � �������� ������� ����� ������� ������ � 24 ����. ����� � ��� ����������� ��� ����������, �� ���� ��� ������ �������� � �� �� ���� ����� �������, ��� ���� ����������� ������.

print_info:				;��� ��� ������ �����, ��� �����
	push	edi
		push	ds
		pop	es
		
		;�������� ����� ����
		push ecx
			shr	ecx, 10h	;�������� �� 16, ����� �������� ����� ����
			and	cx, 00FFh	;�������� ���, ����� ������ ����
			call	print_word	;�������� ����� ����
		pop ecx
		
		;�������� ����� ����������
		push ecx
			shr	ecx, 11		;��������, ����� � ����� �������� ����� ����������
			and	cl, 00011111b	;�������� ���, ����� ������ ����������
			call	print_word	;�������� ����� ����������
		pop ecx

		mov	edi, ecx		; edi for swap	;
		mov	ecx, ebp		; ebp has function number
		call	print_word		; �������� ����� �������

		mov	ecx, edi
		;�������� product id, vendor id
		push	ecx
			push	eax
				shr	eax, 10h
				mov	cx, ax
				call	print_word ;������������ 16 ��� �� cx � �������� ��
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
		
		call	print_string		; from eax ;�������� �������� ����������
		push	dx		; ������� �� ��������� ������
		push	ax
			mov	dx, offset endline
			mov	ah, 09h
			int	21h
		pop	ax
		pop	dx
	pop	edi
	ret
print_string:
	cmp eax, 11063269h		;��������� ������ ������� �����
	ja smth2
	lea dx, file_name1
	push eax	;��������� ����
		xor eax, eax
		mov ax, 3Dh
		int 21h
		
		jc err_
		
		mov bx, ax
		xor ax, ax
		mov ah, 3Fh
		mov cx, 0C350h	;����� ������ �������	~50��
		mov dx, prog
		int 21h
		
		jc err_
		
		mov ah, 03Eh	;��������� ����
		int 21h
		
		jc err_
		
	pop eax
	mov esi, edx	;������ ��� ������ ������������ edx ��� ���������
	
	mov ecx, [esi]
	call	print_word
	shr ecx, 10h
	call	print_word
	push	dx		; ������� �� ��������� ������
	push	ax
		mov	dx, offset space
		mov	ah, 09h
		int	21h
	pop	ax
	pop	dx
	
	mov ecx, 1842   ;3685 / 2 - ����� ������� �����
	mov edx, ecx
	jmp search
smth2:
	lea dx, file_name2
	push eax	;��������� ����
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
		mov cx, 0C350h	;����� ������ �������	~50��
		mov dx, prog
		int 21h
		
		jc err_
		
		mov ah, 03Eh	;��������� ����
		int 21h
		
		jc err_
		
	pop eax
	mov esi, edx	;������ ��� ������ ������������ edx ��� ���������
	
	; push eax
		; lea dx, msg_p
		; call msg_
	; pop eax
	
	mov ecx, [esi]
	call	print_word
	shr ecx, 10h
	call	print_word
	push	dx		; ������� �� ��������� ������
	push	ax
		mov	dx, offset space
		mov	ah, 09h
		int	21h
	pop	ax
	pop	dx
	
	mov ecx, 1794   ;����� ������� �����
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
	je end_of_find	;��� ���������� � ���� ��������� �������
	shr edx, 1
	ja above
	sub ecx, edx
	jmp search
above:
	add ecx, edx
	jmp search
		
end_of_find:
	add edi, 8
	mov cx, [edi]	;��������� ������ ����� ������
	lea dx, names
	xor eax, eax
	mov ax, 3Dh
	int 21h
		
	jc err_
		
	mov bx, ax		;��������� handler
	mov eax, ecx	;��������� ��������
	mov edx, 130	;130 - ����� ������ � ���������
	mul edx
	mov dx, ax		;��������� �������� ��������
	shr eax, 10h	
	mov cx, ax
	mov ah, 42h		
	mov al, 0
	int 21h			;�������� ��������� � �����
		
	jc err_
		
	mov ah, 3Fh
	mov cx, 130
	lea dx, string
	int 21h
		
	jc err_
		
	mov ah, 03Eh	;��������� ����
	int 21h
		
	jc err_
		
	ret
print_word:	;������������ 16 ��� �������� cx � �� ascii ��� � ��������.
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