    .model tiny
    .code
    org 100h
_:
    mov ah, 09h
    lea dx, msg
    jmp nxt
msg db "Hello, world!", 13, 10, '$'
nxt:
    int 21h
    ret
end _
