.386
.model flat, stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\wsock32.inc
include \masm32\include\user32.inc 
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
.data
 szSize         db "The string is %d chars long",0
 szString       db "1234567890abcdefghijklmnopqrstuvwxyz",0 
.data?
 buffer        db 1024 dup(?)
.code
start:
    invoke lstrlen,addr szString
    invoke wsprintf,addr buffer,addr szSize,eax
    invoke MessageBox,0,addr szString,addr buffer,0    
       xor bl,bl 
       mov esi,offset szString  ;mov string to esi register
@@:                 
       xchg bl,[esi+5]          ;exchanges  esi+5(src) into bl(dest) 
       invoke MessageBox,0,esi,0,0 ;show whats in esi 
       invoke lstrlen,esi       ;get length of esi
       cmp eax,5                ;compare length to 5
       jne endofloop            ;if not equal jmp to finish
       add esi,5                ;add 5 to esi
       xchg bl,[esi] 
       or bl,bl                 ;compare bl flag
       jne @B                   ;if not equal jmp back to loop
endofloop:
       invoke MessageBox,0,esi,0,0 ;show whats left esi 
    invoke ExitProcess,0
end start
