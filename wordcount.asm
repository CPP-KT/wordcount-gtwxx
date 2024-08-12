sys_exit:       equ             60

                section         .text
                global          _start

buf_size:       equ             8192
_start:
                xor             rbx, rbx
                mov             r10, 1
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
                cmp             byte [rsi + rcx], 0x09
                je              match
                cmp             byte [rsi + rcx], 0x0a
                je              match
                cmp             byte [rsi + rcx], 0x0b
                je              match
                cmp             byte [rsi + rcx], 0x0c
                je              match
                cmp             byte [rsi + rcx], 0x0d
                je              match
                cmp             byte [rsi + rcx], 0x20
                je              match
                xor             r10, r10
skip:
                inc             rcx
                jmp             check_char
match:
                inc             rbx
                sub             rbx, r10
                mov             r10, 1
                jmp             skip


quit:
                inc             rbx
                sub             rbx, r10
                mov             rax, rbx
                call            print_int

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

                mov             rax, 1
                mov             rdi, 1
                mov             rdx, rsp
                sub             rdx, rsi
                syscall

                ret

read_error:
                mov             eax, 1
                mov             edi, 2
                mov             rsi, read_error_msg
                mov             rdx, read_error_len
                syscall

                mov             rax, sys_exit
                mov             edi, 1
                syscall

                section         .rodata

read_error_msg: db              "read failure", 0x0a
read_error_len: equ             $ - read_error_msg