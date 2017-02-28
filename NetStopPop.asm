.386
.model  flat,stdcall
option  casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\shell32.inc
include c:\masm32\include\advapi32.inc
include c:\masm32\include\masm32.inc
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\shell32.lib
includelib c:\masm32\lib\advapi32.lib
includelib c:\masm32\lib\masm32.lib

.data
 SysKey       db "SYSTEM\CurrentControlSet\Services\Messenger\",0
 KeyValue     db "Start",0
 KeySize      DWORD 255
 FormatStr    db "%d",0
.data?
 WinKeyData   db 255 dup (?)
 TheReturn    DWORD ?
 DwordVal     db 20 dup (?) 
 NTStop       db 'NET STOP MESSENGER',0
 NTStart      db 'NET START MESSENGER',0
.code
start:
;
;make a form with 2 buttons with start or stop on it 

;;##########   get the Messenger Regkey Value (2 = automatic, 3 = enabled, 4 = disabled) and display it   #######
       invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr SysKey,0,KEY_READ,addr TheReturn ;open the registry path to the System key
       invoke RegQueryValueEx,TheReturn,addr KeyValue,0,0,addr WinKeyData, addr KeySize ; push the Value Name to get the Value Data (winkeydata buffer)
          invoke wsprintf, ADDR DwordVal, ADDR FormatStr,WinKeyData  ;change the dword into 2,3,4 etc..
       invoke MessageBox,0,addr DwordVal,addr DwordVal,0
       
;###################   Check to See What Button was pressed Start or Stop   #################################       
     ;net stop the messenger service
       invoke WinExec,addr NTStop, SW_HIDE
     ;net start the messenger service
       invoke WinExec,addr NTStart, SW_HIDE
       
       invoke RegCloseKey , TheReturn 
       invoke  ExitProcess, eax
end start
