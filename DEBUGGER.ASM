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

    jc err_

    mov ah, 09h
    lea dx, msg
    int 21h

    mov ah, 03Eh
    int 21h

    jc err_

    ;save vector 01
    ;mov ah, 035h
    ;mov al, 01h
    ;int 21h
    ;mov word ptr old_01, bx
    ;mov word ptr old_01+2, es

    ;save vector 03
    ;mov ah, 035h
    ;mov al, 03h
    ;int 21h
    ;mov word ptr old_03, bx
    ;mov word ptr old_03+2, es

    ;set new vector
    ;pushf
    ;cli
    ;    mov ah, 25h
    ;    mov al, 01h
    ;    mov dx, offset int_01_handler
    ;    push ds
    ;    push cs
    ;    pop ds
    ;    int 21h
    ;    mov al, 03h
    ;    mov dx, offset int_03_handler
    ;    int 21h
    ;    pop ds
    ;sti
    ;popf

    mov ax, psp/16
    push cs
    pop bx
    add ax, bx
    
    mov bx, psp
    mov byte ptr [bx], 0CBh

    mov ds, ax

    push cs
    push offset eod_handler
    push 0
    push ax
    push 100h
    retf

    ret
eod_handler:
    mov ah, 09h
    lea dx, fname
    ;int 21h
    ;lds dx, old_01
    ;mov ah, 25h
    ;mov al, 01h
    ;int 21h
    ;lds dx, old_03
    ;mov al, 03h
    ;mov ah, 25h
    ;int 21h
    ;sti
    ret

err_:
    mov ah, 09h
    lea dx, err_msg
    int 21h
    ret

int_01_handler proc
    iret
int_01_handler endp

int_03_handler proc
    iret
int_03_handler endp

fname db "example.com",0
err_msg db "Error!$"
msg db "File load succesfully!$"
old_01 dd ?
old_03 dd ?

buf:
end _
