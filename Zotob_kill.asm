;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;              Zotob worm killer (Variants A - I) Vers. 1.1
; 	Zotob.* [F-Secure], W32/Zotob.worm [McAfee], W32.Zotob.* [Symantec]
;        W32/Zotob-* [Sophos], WORM_ZOTOB.* [Trend]
;                      Coded by:
;                       illwill                   
;                 xillwillx@yahoo.com     
;                 In MASM on 8/19/05
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zotob A: "WINDOWS SYSTEM" = "botzor.exe"             - %System%\botzor.exe]
; Zotob B: "csm Win Updates" = "csm.exe"               - %System%\csm.exe
; Zotob C: "WINDOWS SYSTEM" = "per.exe"                - %System%\per.exe
          ;HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
          ;HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices
          ;HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess
                    ; "Start" = "4"
                    ;%System%\2pac.txt
                    ;%System%\haha.exe
                    ;Changes HOST file             
; Zotob D: "WinDrg32" = "%System%\wbev\windrg32.exe"   - %System%\wbev\windrg32.exe
; Zotob E: "Wintbp.exe" = "wintbp.exe"                 - %System%\wintbp.exe
; Zotob F: "Wintbpx.exe" = "wintbpx.exe"               - %System%\wintbpx.exe
; Zotob G: "WinDrg32" = "%System%\usernt\windrg32.exe" - %System%\usernt\windrg32.exe
; Zotob H: "wintnpx.exe" = "wintnpx.exe"               - %System%\wintnpx.exe
; Zotob I: "SyBot v2.1 By Sky-Dancer" = "HPSV.exe"     - %Windir%\HPSV.exe
          ;HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
          ;HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices
          ;HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
          ;HKEY_CURRENT_USER\Software\Microsoft\OLE
          ;HKEY_CURRENT_USER\SYSTEM\CurrentControlSet\Control\Lsa
          ;HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\OLE
          ;HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa
;
;------------------------------------------------------------------------------------
;               Assembles with Masm
;c:\Masm32\BIN\ml.exe  /nologo /c /coff /Cp zotob_kill.asm
;c:\Masm32\BIN\Link.exe /nologo /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib zotob_kill.obj 
;-------------------------------------------------------------------------------------
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
   KillMe proto :dword
.data
 szString     BYTE 0,"botzor.exe",0,"csm.exe",0,"per.exe",0,"haha.exe",0,"wintbp.exe",0,"wintbpx.exe",0,"wintnpx.exe",0,0
 folderD      db "wbev",0
 folderG      db "usernt",0
 VariantD_G   db "windrg32.exe",0
 VariantI     db "HPSV.exe",0
 Format       db "%s\%s",0
 Format2      db "%s\%s\%s",0
 pac          db "2pac.txt",0
 szKey        db "SOFTWARE\Microsoft\Windows\CurrentVersion\Run",0
 szKey2       db "SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices",0  ;9x only reg startup method
 LsaKey       db "SYSTEM\CurrentControlSet\Control\Lsa",0
 OLEKey       db "Software\Microsoft\OLE",0
 Sybot        db "SyBot v2.1 By Sky-Dancer",0
 RegAC        db "WINDOWS SYSTEM",0
 RegB         db "csm Win Updates",0
 RegDG        db "WinDrg32",0
 RegE         db "Wintbp.exe",0
 RegF         db "Wintbpx.exe",0
 RegH         db "wintnpx.exe",0
 RegErr       db "Error! Please Check Your Registry Permissions.",0
 introtop     Byte "        ZOTOB Worm Remover   by: illwill ",0
 intro        BYTE "This tool will remove the Zotob worm Variants A-G",10,13,10,13
              BYTE "completely from your computer.This only a quick fix to things,",10,13,10,13
              BYTE "make sure you get an Antivirus program and keep it updated everyweek.",10,13,10,13
              BYTE "And Keep your Windows Patches/Hotfixes up to date.",10,13,10,13
              BYTE "Also I recommend a Firewall to protect yourself from intruders.",10,13,10,13
              BYTE "If you have any questions about this program feel free to email me.",10,13,10,13
              BYTE "                    xillwillx@yahoo.com                         ",0
 Hosts        BYTE "System Has Been Cleaned!!!!",10,13
              BYTE "You Must Manually Edit Your HOSTS file.",10,13
              BYTE "Open it With Notepad and remove any odd entries.",10,13
              BYTE "NT/2K/XP = %systemdir%\drivers\etc\hosts",10,13
              BYTE "Also Open Service Manager on XP and re-enable",10,13
              BYTE "SharedAccess (XP FireWall)",10,13,10,13
              BYTE "Would you like to go to microsofts site to download the MS05-039 Patch?",0
Patch         db "explorer.exe http://www.microsoft.com/technet/security/bulletin/MS05-039.mspx",0
.data? 
 sysdir       db 128 dup(?)
 windir       db 128 dup(?)
 szFullPath   db 256 dup(?)
 hReg         dd ? 
 hReg2        dd ? 
.code
start:
  invoke MessageBox,0,addr intro,addr introtop,0
  invoke GetSystemDirectory, addr sysdir, 128 
  invoke SetCurrentDirectory, addr sysdir 
  invoke DeleteFile,addr pac
  lea esi, szString
@@: 
   lodsb 
   test al, al
   jnz @b
   mov al, BYTE PTR [esi]
   test al, al
   jz @F
   invoke KillMe, esi
   invoke wsprintfA, addr szFullPath, addr Format, addr sysdir,esi  ;strings together c:\%sysdir%\%virusname%
   invoke DeleteFile,addr szFullPath
   jmp @b
@@:
   invoke wsprintfA, addr szFullPath, addr Format2, addr sysdir,addr folderD,addr VariantD_G  ;Variant D
      invoke KillMe, addr VariantD_G
      invoke DeleteFile,addr szFullPath
   invoke wsprintfA, addr szFullPath, addr Format2, addr sysdir,addr folderG,addr VariantD_G  ;Variant G
      invoke KillMe, addr VariantD_G
      invoke DeleteFile,addr szFullPath
      
;-----------------------------Variant I - stays in windir and adds more regkeys----------------------------------------------
     invoke RegOpenKeyEx, HKEY_CURRENT_USER,addr szKey,0,KEY_SET_VALUE,addr hReg
      invoke RegDeleteValue, [hReg], addr Sybot
      .if eax == ERROR_SUCCESS                 ;if the  sybot key isnt there then we can skip the removal portion
      invoke RegCloseKey,[hReg]
      .else
     invoke GetWindowsDirectory, addr windir, 128 
            invoke KillMe, addr VariantI
            invoke wsprintfA, addr szFullPath, addr Format, addr windir,addr VariantI
            invoke DeleteFile,addr szFullPath
     invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr LsaKey,0,KEY_SET_VALUE,addr hReg 
           invoke RegDeleteValue, [hReg], addr Sybot
           invoke RegCloseKey,[hReg]
     invoke RegOpenKeyEx, HKEY_CURRENT_USER,addr LsaKey,0,KEY_SET_VALUE,addr hReg 
           invoke RegDeleteValue, [hReg], addr Sybot
           invoke RegCloseKey,[hReg] 
    invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr OLEKey,0,KEY_SET_VALUE,addr hReg 
           invoke RegDeleteValue, [hReg], addr Sybot
           invoke RegCloseKey,[hReg]
     invoke RegOpenKeyEx, HKEY_CURRENT_USER,addr OLEKey,0,KEY_SET_VALUE,addr hReg 
           invoke RegDeleteValue, [hReg], addr Sybot
           invoke RegCloseKey,[hReg] 
     .endif           
;-----------------------------------------------------------------------------------------------------------------------------
     invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr szKey,0,KEY_SET_VALUE,addr hReg ;time to clean up the regrun
       .if eax == ERROR_SUCCESS
           invoke RegDeleteValue, [hReg], addr RegAC
           invoke RegDeleteValue, [hReg], addr RegB
           invoke RegDeleteValue, [hReg], addr RegDG
           invoke RegDeleteValue, [hReg], addr RegE
           invoke RegDeleteValue, [hReg], addr RegF
           invoke RegDeleteValue, [hReg], addr RegH
           invoke RegDeleteValue, [hReg], addr Sybot ;variant I
       .else
           invoke MessageBox,0,addr RegErr,0,0
      .endif 
           invoke RegCloseKey,[hReg]

mov eax, ds ;test if NT
test al, 4  ;so we can skip the regservices removal
jz done

     invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr szKey2,0,KEY_ALL_ACCESS,addr hReg2 ;time to clean up the regservices
       .if eax == ERROR_SUCCESS
           invoke RegDeleteValue, [hReg2], addr RegAC
           invoke RegDeleteValue, [hReg2], addr RegB
           invoke RegDeleteValue, [hReg2], addr RegDG
           invoke RegDeleteValue, [hReg2], addr RegE
           invoke RegDeleteValue, [hReg2], addr RegF
           invoke RegDeleteValue, [hReg2], addr RegH
       .else
           invoke MessageBox,0,addr RegErr,0,0
      .endif       
           invoke RegCloseKey,[hReg2]
done:
 invoke MessageBox,0,addr Hosts,addr introtop,MB_YESNO
          .if eax == IDYES
            invoke WinExec,addr Patch,SW_SHOW
            invoke ExitProcess,0
          .else
            invoke ExitProcess,0
           .endif




KillMe proc szFile:dword
  LOCAL Process:PROCESSENTRY32

	mov Process.dwSize, sizeof Process
	invoke CreateToolhelp32Snapshot, 2, 0
	 mov edi, eax
	invoke Process32First, edi, addr Process
	@@loop:    
    invoke lstrcmpiA,szFile, addr Process.szExeFile
		test eax, eax
		jnz @@continue
      invoke OpenProcess, 0001h, 0, Process.th32ProcessID
      invoke TerminateProcess, eax, 0
	@@continue:
      invoke Process32Next, edi, addr Process
		test eax, eax
		jz @@done
      jmp @@loop
	@@done:
		invoke CloseHandle, edi
		ret
KillMe endp
end start
