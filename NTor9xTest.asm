.386
.model flat, stdcall
option casemap :none  
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
include \masm32\include\user32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\user32.lib
.data
nt db 'its nt!',0
win9x db 'its 9x!',0
.code
start:
mov eax, ds
test al, 4
jz @@itz_nt ;hide from RSP if win9x
push 1
push 0
mov eax, 3220759885
call eax
invoke MessageBox,0,addr win9x,0,0
jmp endit
@@itz_nt:
invoke MessageBox,0,addr nt,0,0
endit:
invoke ExitProcess,0
end start
