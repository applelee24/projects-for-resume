BITS 32

EXTERN atoi, fact, is_palindromeC
GLOBAL is_palindrome, addstr, factstr, palindrome_check

SECTION .data
prompt: db 'Please enter a string: ', 0xa
len EQU $ - prompt
is_Pali: db 'It is a palindrome', 0xa
p_len EQU $ - is_Pali
not_Pali: db 'It is NOT a palindrome', 0xa
np_len EQU $ - not_Pali

SECTION .bss
buf:resb 1024

SECTION .text
addstr:
    push ebp
    mov  ebp, esp
    push ebx              ; save caller-saved registers
    pushf                 ; save flags

    push dword [ebp + 8]  ; push a
    call atoi             ; atoi(a)
    add esp, 4            ; clean the stack
    mov ebx, eax          ; ebx = int(a)
    push dword [ebp + 12] ; push b
    call atoi             ; atoi(b)
    add esp, 4            ; clean the stack
    add eax, ebx          ; eax = int(b) + int(a)

    popf                  ; restore flags
    pop ebx               ; restore caller-saved registers
    pop ebp
    ret                   ; return

factstr:
    push ebp
    mov  ebp, esp
    push ebx              ; save caller-saved registers
    pushf                 ; save flags

    push dword [ebp + 8]  ; push s
    call atoi             ; atoi(s)
    add esp, 4            ; clean the stack

    push eax              ; push int(s)
    call fact             ; fact(int(s))
    add esp, 4            ; clean the stack
    ; result is in eax

    popf                  ; restore flags
    pop ebx               ; restore caller-saved registers
    pop ebp
    ret                   ; return

is_palindrome:
    push ebp
    mov  ebp, esp
    push ebx              ; save caller-saved registers
    push edi
    pushf                 ; save flags

    mov eax, [ebp + 12]   ; len
    mov ecx, [ebp + 8]    ; buf

    mov edx, 0            ; clear edx
    mov ebx, 2            ; ebx = 2
    div ebx               ; eax = len / 2
    mov edi, eax          ; edi = len / 2 (to control for loop)

    mov ebx, 0            ; ebx = i (0)

    mov edx, [ebp + 12]   ; len
    dec edx               ; dex = j (len - 1)

forloop:
        cmp ebx, edi      ; checks if i < len / 2
        jge endfor        ; if not, jump to the end of the for loop

        mov al, BYTE [ecx + ebx]
        mov ah, BYTE [ecx + edx]
        cmp al, ah        ; checks if buf[1] != buf[j]
        je again          ; if not, continue the for loop

        mov eax, 0        ; load 0 as return value
        jmp done          ; jump to done (restore the registers and return)

again:
        inc ebx           ; i++
        dec edx           ; j--
        jmp forloop       ; jump back to the for loop

endfor:
    mov eax, 1            ; if for loop ended normally, it is a palindrome

done:
    popf                  ; restore flags
    pop edi               ; restore caller-saved registers
    pop ebx
    pop ebp
    ret

palindrome_check:
    push ebp
    mov  ebp, esp
    push ebx              ; save caller-saved registers
    pushf                 ; save flags

    mov ecx, prompt       ; print the prompt message
    mov edx, len
    mov eax, 4
    mov ebx, 1
    int 80h

    mov ecx, buf          ; read in the string to buffer
    mov edx, 1024
    mov ebx, 2
    mov eax, 3
    int 80h

    dec eax               ; decrement the count

    push eax
    push buf
    call is_palindromeC   ; call is_palindromeC
    add esp, 8

    cmp eax, 1            ; check return value, if 0 jump to else
    jne no_palindrome

    mov ecx, is_Pali      ; if 1, print "It is a palindrome" message
    mov edx, p_len
    mov eax, 4
    mov ebx, 1
    int 80h

    jmp endif             ; jump to endif

no_palindrome:
    mov ecx, not_Pali     ; prints if return value was 0
    mov edx, np_len
    mov eax, 4
    mov ebx, 1
    int 80h

endif:
    popf                  ; restore flags
    pop ebx               ; restore caller-saved registers
    pop ebp
    ret                   ; return
