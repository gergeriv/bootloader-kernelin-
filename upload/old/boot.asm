[org 0x7C00]
[bits 16]

start:
    mov ax, 0x0003
    int 0x10

    mov si, msg_real
    call print_16

    cli
    call enable_a20
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:start_32bit

enable_a20:
    in al, 0x92
    or al, 0x02
    out 0x92, al
    ret

print_16:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_16
.done:
    ret

gdt_start:
    dq 0

gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[bits 32]
start_32bit:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x80000

    mov edi, 0xB8000
    mov ecx, 80*25
    mov ax, 0x0F20
    rep stosw

    mov esi, msg_protected
    mov edi, 0xB8000
    call print_32

    jmp $

print_32:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0F
    mov [edi], ax
    add edi, 2
    jmp print_32
.done:
    ret

msg_real     db "kernelin: now in unprotected 16b", 0
msg_protected db "kernelin: now in protected 32b", 0

times 510-($-$$) db 0
dw 0xAA55
