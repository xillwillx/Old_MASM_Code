;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         DCOM worm killer (W32.Blaster.Worm) a,b,c variants
;
;                      Coded by:
;                       illwill                   
;                 xillwillx@yahoo.com     
;                   www.illmob.org        
;  
;                        8/15/03
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;------------------------------------------------------------------------------------
;               Assembles with Masm
;c:\Masm32\BIN\ml.exe  /nologo /c /coff /Cp DCOM2.asm
;c:\Masm32\BIN\Link.exe /nologo /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib DCOM2.obj 
;-------------------------------------------------------------------------------------
;       ::: Source Available Here ::: 
.386
.model flat, stdcall
option casemap:none

include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\windows.inc
include \masm32\include\shell32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\shell32.lib
include \masm32\include\advapi32.inc
includelib \masm32\lib\advapi32.lib

NukeEm  PROTO :DWORD
.data
   introtop   Byte '        DCOM Worm Remover 2.0  by: illwill ',0
   intro      BYTE "This tool will remove the 3 variants of the DCOM worm",10,13,10,13
              BYTE "completely from your computer.This only a quick fix to things,",10,13,10,13
              BYTE "make sure you get an Antivirus program and keep it updated everyweek.",10,13,10,13
              BYTE "Also I recomend a Firewall to protect yourself from intruders.",10,13,10,13
              BYTE "If you have any questions about this program feel free to email me.",10,13,10,13
              BYTE "                    xillwillx@yahoo.com                         ",0
   Found      BYTE "        The worm %s has been eliminated!        ",0
   Foundtop   BYTE "        DCOM worm variant was found!        ",0
   Value2del  db  "Microsoft Inet Xp..",0
   value2del  db  "windows auto update",0
   szKey      db   "SOFTWARE\Microsoft\Windows\CurrentVersion\Run",0 
   w0Rmz      BYTE 0
              BYTE "penis32.exe",0,"msblast.exe",0,"root32.exe",0,"index.exe",0,"teekids.exe",0,0,0
                 hSnapshot  DWORD 0
.data?
    hOpenKey     HANDLE ?
    sysdir       db 128 dup(?)
    FoundBuff    db 256 dup(?)

.code
Start:
  invoke MessageBox,0,addr intro,addr introtop,0
  invoke RegOpenKeyEx,HKEY_LOCAL_MACHINE,ADDR szKey,0,KEY_ALL_ACCESS,addr hOpenKey
  invoke RegDeleteValue,hOpenKey,addr value2del
  invoke RegDeleteValue,hOpenKey,addr Value2del
  invoke RegCloseKey,hOpenKey
    invoke GetSystemDirectory, addr sysdir, 128
    invoke SetCurrentDirectory, addr sysdir 
     lea esi,w0Rmz
@@:  
     lodsb
      test al, al
     jnz @b
      mov al, BYTE PTR [esi]
      test al, al
     jz ListDone
      invoke NukeEm, esi
     jmp @b
ListDone:

NukeEm proc szApp:DWORD
   LOCAL Process:PROCESSENTRY32
   LOCAL szFilename[MAX_PATH]:BYTE
	
   mov Process.dwSize, SIZEOF Process
   invoke CreateToolhelp32Snapshot, TH32CS_SNAPPROCESS, 0
   mov hSnapshot, eax                    
   mov edi, szApp
   invoke Process32First, hSnapshot, ADDR Process

MurderLoop:
      invoke lstrcmpiA, edi, ADDR Process.szExeFile
      test eax, eax
      jnz Continue
        invoke wsprintfA,addr FoundBuff,addr Found,edi
        invoke MessageBox,0,addr FoundBuff,addr Foundtop,0
	   invoke OpenProcess, PROCESS_TERMINATE, 0, Process.th32ProcessID 
	   invoke TerminateProcess, eax, 0
	      Invoke DeleteFile,edi
	   invoke Sleep, 100
Continue:
	   invoke Process32Next, hSnapshot, ADDR Process
	   test eax, eax
	   jz AllDone
	   jmp MurderLoop
AllDone:
   invoke CloseHandle, [hSnapshot]
	ret
NukeEm endp

end Start
