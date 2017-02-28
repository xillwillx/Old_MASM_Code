.586
.model flat,stdcall
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc
include \masm32\include\user32.inc
include \masm32\include\advapi32.inc
include \masm32\include\urlmon.inc
include \masm32\include\wsock32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\wsock32.lib
includelib \masm32\lib\urlmon.lib
 ListApp    PROTO
 .data
  AppHead      db 13,10,"PID: | PROCESS NAME:",13,10,13,10,0
 AppGlue      db "%4d | %s ",13,10,0
 .data?
 OutBuff      db 256 dup (?)
 .code
 start:
 invoke ListApp
 invoke ExitProcess,0
ListApp proc  
  LOCAL Process:PROCESSENTRY32
	mov Process.dwSize, sizeof Process
	invoke CreateToolhelp32Snapshot, 2, 0
	 mov esi, eax
	invoke Process32First, esi, addr Process
	invoke StdOut,addr AppHead 
	@@loop:    
      invoke wsprintf,addr OutBuff,addr  AppGlue,Process.th32ProcessID , addr Process.szExeFile 
      invoke StdOut,addr OutBuff 
      invoke Process32Next, esi, addr Process
		test eax, eax
		jz @@done
    jmp @@loop
	@@done:
		invoke CloseHandle, esi
    ret
ListApp endp
end start
