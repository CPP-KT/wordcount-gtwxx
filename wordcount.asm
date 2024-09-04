sys_exit:       equ             60
ONE:            equ             1

                section         .text
                global          _start

buf_size:       equ             8192
_start:
                xor             rbx, rbx
                mov             r10, ONE
                sub             rsp, buf_size
                mov             rsi, rsp

read_again:
                xor             eax, eax
                xor             edi, edi
                mov             rdx, buf_size
                syscall

                test            rax, rax
                jz              quit
                js              read_error

                xor             ecx, ecx

check_char:
                cmp             rcx, rax
                je              read_again
                mov             dl, byte [rsi + rcx]
                cmp             dl, 0x09
                jl              skip
                cmp             dl, 0x20
                je              match
                cmp             dl, 0x0d
                jle             match

; don't add 1 to counter (rbx) and jumps to next char
skip:
                xor             r10, r10
                inc             rcx
                jmp             check_char

; add 1 to counter (rbx) and jumps to next char
match:
                inc             rbx
                sub             rbx, r10
                mov             r10, ONE
                inc             rcx
                jmp             check_char

quit:
                inc             rbx
                sub             rbx, r10
                mov             rax, rbx
                call            print_int

                add             rsp, buf_size
                mov             rax, sys_exit
                xor             rdi, rdi
                syscall

; rax -- number to print
print_int:
                mov             rsi, rsp
                mov             rbx, 10

                dec             rsi
                mov             byte [rsi], 0x0a

next_char:
                xor             rdx, rdx
                div             rbx
                add             dl, '0'
                dec             rsi
                mov             [rsi], dl
                test            rax, rax
                jnz             next_char

                mov             rax, ONE
                mov             rdi, ONE
                mov             rdx, rsp
                sub             rdx, rsi
                syscall

                ret

read_error:
                mov             eax, ONE
                mov             edi, 2
                mov             rsi, read_error_msg
                mov             rdx, read_error_len
                syscall

                mov             rax, sys_exit
                mov             edi, ONE
                syscall

                section         .rodata

read_error_msg: db              "read failure", 0x0a
read_error_len: equ             $ - read_error_msg
