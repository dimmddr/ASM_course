org 7C3Eh
%define space 20h
%define color0 7Fh
%define color1 78h
%define arrowup 48h
%define arrowdown 50h
%define pageup 49h
%define pagedown 51h
%define esc 01h
%define minadd 0
%define maxadd 0FE6Fh
%define arrow_shift 16
%define page_shift 400

start:
push   cs
pop    ds

; mov bl, color0
; mov al, 0FAh
; call print_byte
mov ax, 0003h
int 10h
mov ax, 0100h
mov cx, 2607h
int 10h

xor si, si
; mov si, 7C00h
call print_monitor
while1:
xor ax, ax
int 16h
cmp ah, esc
je esc_key
cmp ah, arrowup
je arrowup_key
cmp ah, arrowdown
je arrowdown_key
cmp ah, pageup
je pageup_key
cmp ah, pagedown
je pagedown_key
jmp while1
ret

esc_key:
    int 19h

arrowup_key:
    cmp si, minadd
    jbe while1
    sub si, arrow_shift
    call print_monitor
    jmp while1

arrowdown_key:
    cmp si, maxadd
    jae while1
    add si, arrow_shift
    call print_monitor
    jmp while1

pageup_key:
    cmp si, minadd
    jbe while1
    sub si, page_shift
    call print_monitor
    jmp while1

pagedown_key:
    cmp si, maxadd
    jae while1
    add si, page_shift
    call print_monitor
    jmp while1

;input si - address
print_monitor:
    pusha
    call cursor_up_to
    call cursor_left_to
    xor di, di
    for:
        call print_line
        add si, 16
        inc di
        cmp di, 25
        jne for
    popa
    ret    

print_sector:
    pusha
    mov bl, color0
    mov al, [si]
    call print_byte
    call print_space
    mov al, [si+1]
    call print_byte
    call print_space
    mov al, [si+2]
    call print_byte
    call print_space
    mov al, [si+3]
    call print_byte
    popa
    ret

print_sep:
    pusha
    mov bl, color0
    call print_space
    mov al, 12h
    call print_num
    call print_space
    popa
    ret

;input si - address
print_address:
    pusha
    mov bl, color1
    mov ax, si
    shr ax, 8
    call print_byte
    mov ax, si
    call print_byte
    mov ax, 10h
    call print_num
    popa
    ret

;input si - address
print_line:
    pusha
    mov bl, color0
    call cursor_left_to
    call print_address
    call print_space
    call print_space
    call print_sector
    call print_sep
    add si, 4
    call print_sector
    call print_sep
    add si, 4
    call print_sector
    call print_sep
    add si, 4
    call print_sector
    add si, 4
    xor di, di
    for_space:
        call print_space
        inc di
        cmp di, 20
        jne for_space
    call cursor_down
    popa
    ret

;input bl - color, al - byte
print_byte:
    push ax
    mov cl, al
    shr al, 4
    call print_num
    mov al, cl
    and al, 0Fh
    call print_num
    pop ax
    ret

;input bl - color, al - num
print_num:
    pusha
    push bx
    lea bx, [sym_tab]
    xlat
    pop bx
    mov ah, 09h
    xor bh, bh
    mov cx, 1
    int 10h
    call cursor_right
    popa
    ret

;input bl - color
print_space:
    pusha
    mov al, 11h
    call print_num
    popa
    ret

cursor_right:
    pusha
    mov ah, 03h
    xor bh, bh
    int 10h
    inc dl
    mov ah, 02h
    int 10h
    popa
    ret

cursor_down:
    pusha
    mov ah, 03h
    xor bh, bh
    int 10h
    inc dh
    mov ah, 02h
    int 10h
    popa
    ret

cursor_left_to:
    pusha
    mov ah, 03h
    xor bh, bh
    int 10h
    xor dl, dl
    mov ah, 02h
    int 10h
    popa
    ret

cursor_up_to:
    pusha
    mov ah, 03h
    xor bh, bh
    int 10h
    xor dh, dh
    mov ah, 02h
    int 10h
    popa
    ret

sym_tab db "0123456789ABCDEF: ", 0b3h