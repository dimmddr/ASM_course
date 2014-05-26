model	tiny
	.code
	.386
	org	100h
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
	cmp	ax, -1		;���� ���������� ��� (�� ���� �� CFC ��������� -1) 
	je	end_of_all	;�� ������ � ���� end_of_all, ����� - ��������

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
	cmp	ax, -1		;���� ���������� ��� (�� ���� �� CFC ��������� -1) 
	je	end_of_all	;�� ������ � ���� end_of_all, ����� - ��������
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
	je	end_of_all	;�� ������ � ���� end_of_all, ����� - ��������
	call	print_info	
	inc	bp		;����������� bp
	cmp	bp, 8		
	jl	non_mult	;���� ����������� bp<8

end_of_all:	;������ ��� end ��� ����� �����������...
	add	ecx, 0800h	;��������� �� � ��������� �������, � ����� � ���������� ����������.
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
		pop	ecx
		
		push	dx		; ������� �� ��������� ������
		push	ax
			mov	dx, offset endline
			mov	ah, 09h
			int	21h
		pop	ax
		pop	dx
	pop	edi
print_end:
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
	
	space		db ' ', 0
	endline		db 13, 10, '$'
	sym_tab		db	"0123456789ABCDEF"
buf:
end _