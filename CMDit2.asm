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
include <\masm32\macros\macros.asm>
 main       PROTO :DWORD, :DWORD
 KillApp    PROTO :DWORD
 KillPid    PROTO :DWORD
 GhostApp   PROTO :DWORD
 ListApp    PROTO 
 ClearLog   PROTO :DWORD
 GetUp      PROTO
 GetIPAddy  PROTO
 GetRam     PROTO
 GetUser    PROTO
 GetCPU     PROTO
 GetOS      PROTO
 DLit       PROTO :DWORD, :DWORD
 Detect     PROTO :DWORD, :DWORD
 convertit  PROTO
 Rebootit   PROTO :DWORD, :DWORD
 
.data
 option0      db "-c",0
 option1      db "-p",0
 option2      db "-n",0
 option3      db "-l",0
 option4      db "-i",0
 option5      db "-i",0
 option6      db "-g",0
 option7      db "-d",0
 option8      db "-r",0
 option9      db "-s",0
 SPkeySize1   DWORD 255
 stinfo       STARTUPINFO <?>
 bWildCard    DWORD  ?
 pEnv         DWORD  ?
 pArgv        DWORD  ?
 nArgc        DWORD  ?
 Theoutput    db   ' __________________________________________________ ',13,10
              db   '|                        CMDit 1.2                 |',13,10
              db   '|                      Coded In MASM               |',13,10
              db   '|             by illwill  - xillwillx@yahoo.com    |',13,10
              db   '|__________________________________________________|',13,10,13,10,0
 Usage        db   ' USAGE: CMDit.exe <option>                          ',13,10
              db   '        -i            = information about Machine   ',13,10
              db   '        -c <LogName>  = Clears Event Log on Machine ',13,10
              db   '                       (Application,Security,System)',13,10
              db   '        -l            =  lists processes            ',13,10
              db   '        -p <pid>      =  kill by PID #              ',13,10
              db   '        -n <name>     =  kill by proc name          ',13,10
              db   '        -g <path2exe> =  start exe hidden           ',13,10
              db   '        -w <url><exe> =  download file from web     ',13,10
              db   '        -r <time>     =  force computer to reboot   ',13,10
              db   '        -s <time>     =  force computer to shutdown ',13,10
              db   '        -d <start><end> = scan ips to detect xp/2k  ',13,10,13,10,0 
 AppHead      db 13,10,"PID: | PROCESS NAME:",13,10,13,10,0
 AppGlue      db "%4d | %s ",13,10,0
 appglue      db "  [%s] has been terminated.",13,10,0
 ghostglue    db "  Hidden process was created with the PID of [ %d ].",13,10,0
 urlglue      db "  %s has downloaded.",13,10
              db "  %s was created.",13,10,0
 failure      db "  Process failed or errored.",13,10,0
 
  req1   db 00h,00h,00h,85h,0FFh,53h,4Dh,42h,72h,00h,00h,00h,00h,18h,53h,0C8h,00h,00h ; 18
         db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0FFh,0FEh,00h,00h,00h,00h,00h,62h ; 20
         db 00h,02h,50h,43h,20h,4Eh,45h,54h,57h,4Fh,52h,4Bh,20h,50h,52h,4Fh,47h,52h,41h,4Dh,20h ; 21
         db 31h,2Eh,30h,00h,02h,4Ch,41h,4Eh,4Dh,41h,4Eh,31h,2Eh,30h,00h,02h,57h ; 17
         db 69h,6Eh,64h,6Fh,77h,73h,20h,66h,6Fh,72h,20h,57h,6Fh,72h,6Bh,67h,72h,6Fh,75h,70h,73h,20h,33h ; 23 
         db 2Eh,31h,61h,00h,02h,4Ch,4Dh,31h,2Eh,32h,58h,30h,30h,32h,00h ; 15
         db 02h,4Ch,41h,4Eh,4Dh,41h,4Eh,32h,2Eh,31h,00h,02h,4Eh,54h,20h,4Ch,4Dh,20h,30h,2Eh,31h,32h,00 ; 23


 req2    db 00h,00h,00h,0A4h,0FFh,53h,4Dh,42h,73h,00h,00h,00h,00h,18h,07h,0C8h,00h,00h,00h,00h,00h
         db 00h,00h,00h,00h,00h,00h,00h,00h,00h,0FFh,0FEh,00h,00h,10h,00h,0Ch,0FFh
         db 00h,0A4h,00h,04h,11h,0Ah,00h,00h,00h,00h,00h,00h,00h,20h,00h,00h,00h,00h,00h,0D4h
         db 00h,00h,80h,69h,00h,4Eh,54h,4Ch,4Dh,53h,53h,50h,00h,01h,00h,00h,00h,97h
         db 82h,08h,0E0h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,57h
         db 00h,69h,00h,6Eh,00h,64h,00h,6Fh,00h,77h,00h,73h,00h,20h,00h,32h,00h
         db 30h,00h,30h,00h,30h,00h,20h,00h,32h,00h,31h,00h,39h,00h,35h
         db 00h,00h,00h,57h,00h,69h,00h,6Eh,00h,64h,00h,6Fh,00h,77h,00h,73h,00h,20h,00h,32h,00h
         db 30h,00h,30h,00h,30h,00h,20h,00h,35h,00h,2Eh,00h,30h,00h,00h,00h,00h,00


 req3    db 00h,00h,00h,0DAh,0FFh,53h,4Dh,42h,73h,00h,00h,00h,00h,18h,07h,0C8h,00h,00h,00h,00h ; 20
         db 00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0FFh,0FEh,00h,08h,20h,00h,0Ch,0FFh ; 18
         db 00h,0DAh,00h,04h,11h,0Ah,00h,00h,00h,00h,00h,00h,00h,57h,00h,00h,00h,00h,00h,0D4h ; 20
         db 00h,00h,80h,9Fh,00h,4Eh,54h,4Ch,4Dh,53h,53h,50h,00h,03h,00h,00h,00h,01h ; 18
         db 00h,01h,00h,46h,00h,00h,00h,00h,00h,00h,00h,47h,00h,00h,00h,00h,00h,00h,00h,40h,00h ; 21
         db 00h,00h,00h,00h,00h,00h,40h,00h,00h,00h,06h,00h,06h,00h,40h,00h,00h ; 17
         db 00h,10h,00h,10h,00h,47h,00h,00h,00h,15h,8Ah,88h,0E0h,48h,00h,4Fh,00h,44h,00h ; 19
         db 00h,81h,19h,6Ah,7Ah,0F2h,0E4h,49h,1Ch,28h,0AFh,30h,25h,74h,10h,67h,53h,57h,00h ; 19
         db 69h,00h,6Eh,00h,64h,00h,6Fh,00h,77h,00h,73h,00h,20h,00h,32h,00h,30h,00h,30h ; 19
         db 00h,30h,00h,20h,00h,32h,00h,31h,00h,39h,00h,35h,00h,00h,00h,57h,00h,69h,00h ; 19
         db 6Eh,00h,64h,00h,6Fh,00h,77h,00h,73h,00h,20h,00h,32h,00h,30h,00h,30h,00h,30h ;19
         db 00h,20h,00h,35h,00h,2Eh,00h,30h,00h,00h,00h,00h,00 ; 13
 STARTme   db "[+] Finding Host %s",0Dh,0Ah,0
 HostYay   db "[+] Connected to %s",0Dh,0Ah,0
 HostErr   db "[-] Cannot connect to %s",0Dh,0Ah,0
 LoginRcv  db "[+] %s",0Dh,0Ah,0
 win2k     db "[?] The box seems to be Windows 2000.",0Dh,0Ah,0
 winxp     db "[?] The box seems to be Windows XP.",0Dh,0Ah,0
 unknown   db "[?] The box seems to be UNKNOWN.",0Dh,0Ah,0
 SendError db "[-] Socket Error When Sending Data.",0Dh,0Ah,0
 RcvError  db "[-] Socket Error When Receiving Data.",0Dh,0Ah,0
 complete  db "[+] Scanning Complete.",0Dh,0Ah,0
 Ipformat  db "%d.%d.%d.%d",0
 foundfmt  db "%d Host(s) found.",0
 counter   dd 0
.data?
 OutBuff      db 256 dup (?)
 buffer       db 256 dup (?)
 szStartIP    db 256 dup (?)
 startip      dd ?
 
.code
start:    
    invoke StdOut, addr  Theoutput                                
    mov [bWildCard], FALSE
    invoke crt___getmainargs,addr nArgc,addr pArgv,addr pEnv,[bWildCard],addr stinfo
    invoke main,[nArgc],[pArgv]
    invoke crt_exit

main PROC USES EDI argc:DWORD, argv:DWORD
	LOCAL	arg2	:DWORD
 .IF ( argc == 3 )
        mov esi, [argv]                ; ESI holds arguement vectors(table)                
        lodsd                          ; argv[0]    skip module name
        lodsd                          ; argv[1] 
        mov edi,eax
        lodsd
        mov ebx,eax                    ; argv[2] / PID or APP
       
     invoke lstrcmpi,addr option0, edi ; -c clear log by name 
     .IF eax==0
      invoke ClearLog, ebx  
     .ENDIF  
       
     invoke lstrcmpi,addr option1, edi ; -p  kill by PID
     .IF eax==0
       invoke KillPid,  ebx 
     .ENDIF
    
     invoke lstrcmpi,addr option2, edi ; -n  kill by Name
     .IF eax==0
       invoke KillApp, ebx
     .ENDIF  
     
     invoke lstrcmpi,addr option6, edi ; -g  open app hidden
     .IF eax==0
       invoke GhostApp, ebx
     .ENDIF
     
      invoke lstrcmpi,addr option8, edi ; -r  reboot
     .IF eax==0
       invoke Rebootit,edi, ebx
     .ENDIF 
     
     invoke lstrcmpi,addr option9, edi ; -s  shutdown
     .IF eax==0
       invoke Rebootit,edi, ebx
     .ENDIF 

 .ELSE  
  .IF ( argc == 2 )                   ; user only listed one parameter or none
        mov esi, [argv]               ; ESI holds arguement vectors(table)                
        lodsd                         ; argv[0]  skip module name
        lodsd                         ; argv[1] 
        mov edi,eax
    
    invoke lstrcmpi,addr option4, edi ; -i get cpu info
     .IF eax==0
       invoke GetIPAddy 
       invoke GetUser
       invoke GetOS
       invoke GetCPU
       invoke GetRam
       invoke GetUp
     .ENDIF  
        
       invoke lstrcmpi,addr option3, edi ; -l  list processes
    .IF eax==0
          invoke ListApp
    .ENDIF 
  .ELSE
         .IF ( argc == 4 )                     ;they wanna webdl
                 mov esi, [argv]               ; ESI holds arguement vectors(table)                
                 lodsd                         ; argv[0]  skip module name
                 lodsd                         ; argv[1] the -g switch
                 mov [arg2],eax
                 lodsd                         ; argv[2] 
                 mov edi,eax
                 lodsd                         ; argv[3] 
                 mov ebx,eax
                 
                 invoke lstrcmpi,addr option7, arg2 ;see if they wanna detect or dl
                     .IF eax==0
                        invoke Detect,edi,ebx
                     .ELSE
                        invoke DLit,edi,ebx
                     .ENDIF 
         .ELSE
                invoke StdOut, addr Usage    ; give the user some options bitch 
         .ENDIF
  .ENDIF 
 .ENDIF
    ret
main ENDP

Rebootit PROC bReboot:dword,timeo:dword
  LOCAL osv:OSVERSIONINFO 
  LOCAL tp:TOKEN_PRIVILEGES
  LOCAL hToken: HANDLE
  LOCAL CurProc:DWORD 
  LOCAL Counter:DWORD
  jmp @F
  ShutdownPrivilege   db  "SeShutdownPrivilege",0
  Nopriv              db  "Could Not Aquire proper Shutdown Privileges.",0
  ShutDown            db 13,10,"System is Shutting Down.",13,10,0
  Rebooting           db 13,10,"System is Rebooting.",13,10,0
  secsleft            db "%d,",0
  reb                 db  "-r",0
@@:        
                invoke  GetCurrentProcess  
                mov CurProc,eax                                                              
                invoke  OpenProcessToken,CurProc,TOKEN_ADJUST_PRIVILEGES+TOKEN_QUERY,ADDR hToken            
                invoke  LookupPrivilegeValue,NULL,ADDR ShutdownPrivilege, ADDR tp.Privileges[0].Luid    	
                   mov     tp.PrivilegeCount,1                                                             
                   mov     tp.Privileges[0].Attributes,SE_PRIVILEGE_ENABLED                                
                invoke  AdjustTokenPrivileges,hToken,FALSE, ADDR tp, 0, NULL, 0 
                  cmp eax,0
                  jz notoken  
                

                invoke atodw,timeo
                mov [Counter],eax
                inc Counter
                .WHILE Counter != 0
                   dec Counter
                   INVOKE Sleep,1000
                   invoke wsprintf, ADDR buffer , ADDR secsleft, Counter
                   Invoke StdOut,addr buffer
                .ENDW
                invoke lstrcmpi,bReboot, addr reb
                .if eax==0
                  Invoke StdOut,addr Rebooting
                  invoke InitiateSystemShutdown,NULL,NULL,0,FALSE,1
                  invoke  ExitWindowsEx, EWX_FORCE+EWX_REBOOT, NULL
                .else
                  Invoke StdOut,addr ShutDown
                   invoke InitiateSystemShutdown,NULL,NULL,0,FALSE,0
                   ;invoke  ExitWindowsEx, EWX_FORCE+EWX_SHUTDOWN, NULL
                .endif
                invoke CloseHandle,[hToken]
                ret
notoken:
     Invoke StdOut,addr Nopriv
     ret
Rebootit ENDP


GhostApp	proc szPath:dword
  LOCAL processInfo:PROCESS_INFORMATION 
        mov [stinfo.cb], sizeof STARTUPINFO
        mov [stinfo.dwFlags],STARTF_USESHOWWINDOW 
        mov [stinfo.wShowWindow], SW_HIDE
        invoke CreateProcess,NULL,szPath,NULL,NULL,FALSE,\
                                              NORMAL_PRIORITY_CLASS,\
                                              NULL,NULL,ADDR stinfo,\
                                              ADDR processInfo
        test eax,eax
        jz @F  ;if CreateProcess returns 0 then something fucked
        invoke wsprintf,addr buffer,addr ghostglue, processInfo.dwProcessId
        invoke StdOut,addr buffer                                     
        invoke CloseHandle,processInfo.hThread
        ret
     @@: 
        invoke StdOut,addr failure
        ret  
GhostApp endp

DLit	proc szUrl:dword,szFile:dword
	invoke URLDownloadToFile,0,szUrl,szFile,0,0
	cmp eax,S_OK
	jz @F
	  invoke StdOut,addr failure  
	  ret
	@@:
  invoke wsprintf,addr OutBuff,addr urlglue,szUrl,szFile
  invoke StdOut,addr OutBuff  
	ret
DLit endp

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

KillApp proc szFile:dword
  LOCAL Process:PROCESSENTRY32

	mov Process.dwSize, sizeof Process
	invoke CreateToolhelp32Snapshot, 2, 0
	 mov esi, eax
	invoke Process32First, esi, addr Process
	@@loop:    
    invoke lstrcmpiA,szFile, addr Process.szExeFile
		test eax, eax
		jnz @@continue
      invoke OpenProcess, 0001h, 0, Process.th32ProcessID
      invoke TerminateProcess, eax, 0
       mov edi,eax
      	cmp edi,0
	      jnz killed
	       invoke StdOut,addr failure  
	       ret
  killed:
      invoke wsprintf,addr OutBuff,addr appglue,addr Process.szExeFile
      invoke StdOut,addr OutBuff 
	@@continue:
      invoke Process32Next, esi, addr Process
		test eax, eax
		jz @@done
      jmp @@loop
	@@done:
		invoke CloseHandle, esi
		ret
KillApp endp

KillPid proc szPID:dword
  LOCAL Process:PROCESSENTRY32
  LOCAL PID:DWORD
      invoke atodw,szPID
        mov PID,eax
      invoke OpenProcess,PROCESS_TERMINATE,FALSE,PID
      invoke TerminateProcess,eax,0
         cmp eax,0
	       jnz @F
	       invoke StdOut,addr failure  
	       ret
  @@:
      invoke wsprintf,addr OutBuff,addr appglue,szPID
      invoke StdOut,addr OutBuff 
		ret
KillPid endp

ClearLog PROC TheLog:DWORD
   local hLog:DWORD
   jmp @F
   LOGfmt db '%s log has been cleared.',0
@@:
   invoke OpenEventLog,NULL,TheLog   ;open the eventlog
   .IF eax!=NULL                     ;if success 
      mov hLog,eax                   ;save to pointer
      invoke ClearEventLog,hLog,NULL ;clear it
         cmp eax,0
	       jnz @F
	       invoke StdOut,addr failure  
	       ret
    @@:
      invoke CloseEventLog,hLog      ;close log
   .ENDIF
       invoke wsprintf, addr OutBuff, addr LOGfmt,TheLog ;make a pretty output      
       invoke StdOut, addr OutBuff                       ;print to console
       invoke ExitProcess,0                              ;we're done
ClearLog ENDP

GetIPAddy PROC
 local wsa:WSADATA
             jmp @F
   IPfmt      db   'IP:     %s',10,13,0
   HOSTfmt    db   'HOST:   %s',10,13,0
 @@: 
             invoke WSAStartup,101h,addr wsa
             invoke gethostname,offset buffer,sizeof buffer
             invoke wsprintf,addr OutBuff, addr HOSTfmt,addr buffer    ; the host is buffer
             invoke StdOut, addr OutBuff
             invoke gethostbyname,addr buffer
                 mov eax,[eax+12]                                        
                 mov eax,[eax]
                 mov eax,[eax]
             invoke inet_ntoa,eax
  	          mov edx, eax
             invoke wsprintf,addr OutBuff, addr IPfmt, edx   ; the ip is edx
             invoke StdOut, addr OutBuff
             invoke WSACleanup
            ret
GetIPAddy ENDP

GetRam PROC 
local memstat:MEMORYSTATUS
   jmp @F
   RamMB      db   '%lu MB',0
   RAMfmt     db   'Ram:    %s',10,13,0
@@:    
    invoke GlobalMemoryStatus, addr memstat
    Mov  eax, [memstat.dwTotalPhys] 
    shr eax, 10
    shr eax, 10
    invoke wsprintf,addr buffer,addr RamMB,eax
    invoke wsprintf,addr OutBuff,addr RAMfmt,addr buffer
    invoke StdOut, addr OutBuff
    ret
GetRam ENDP

GetUser PROC
 local  NameLen:DWORD
jmp @F
 USERfmt    db   'User:   %s',10,13,0
@@: 
      mov    NameLen, SIZEOF buffer
      invoke GetUserName, addr buffer, addr NameLen
      invoke wsprintf, addr OutBuff,addr USERfmt,addr buffer
      invoke StdOut, addr OutBuff
      ret
GetUser ENDP 

GetUp PROC
   jmp @F
   UPfmt      db   'Uptime: %s',10,13,0        
   szTime     db   "%lud %luhr %-2.2lum %-2.2lus",0
@@:
    call    GetTickCount
    mov     ecx, 1000
    sub     edx, edx
    div     ecx

    mov     ecx, 60
    sub     edx, edx
    div     ecx
    push    edx ; seconds

    sub     edx, edx
    div     ecx
    push    edx ; minutes

    mov     ecx, 24
    sub     edx, edx
    div     ecx
    push    edx ; hours

    push    eax ; days

    push    offset szTime
    push    offset buffer
    call    wsprintf
    add esp, 24
    invoke  wsprintf,addr OutBuff,addr UPfmt, addr buffer
    invoke StdOut, addr OutBuff
    ret
GetUp ENDP


Detect	proc szStart:dword,szEndIP:dword
  LOCAL sin:sockaddr_in
  LOCAL wsadata:WSADATA
  LOCAL endip:DWORD
  LOCAL sock:DWORD
  LOCAL buff_sock[1600]:BYTE
  invoke inet_addr,szStart       ;convert start ip to long
         mov [startip],eax
  invoke inet_addr,szEndIP   ;convert end ip to long
         mov [endip],eax   
		dec byte ptr [startip+3]                  ;mov start ip back one
	  inc byte ptr [endip+3]                    ;mov end ip forward one 

	invoke WSAStartup, 101h,addr wsadata
	test eax, eax
	jnz @@err
@@incrementIP: 
	invoke socket, AF_INET, SOCK_STREAM, 0
	mov sock, eax
	mov sin.sin_family, AF_INET
	invoke htons, 445
	mov sin.sin_port, ax
;----------------------------------------------------------------------	
      inc byte ptr [startip+3]                                    ;increment the last octet of the ip by 1
      mov eax,endip                                               ;mov end ip into eax
      cmp eax,startip                                             ;compare it to see if they equal
      jz scandone                                                 ;if equal we're all done :)
	mov eax,startip
	mov sin.sin_addr, eax      
  invoke convertit                                                ;convert the long ip back to regular
	invoke wsprintf, addr buffer, addr STARTme, addr szStartIP      ;string together output to console
	invoke StdOut, addr buffer                                      ;output to show user progress 
	invoke connect, sock, addr sin, sizeof sin                      ;connect
	cmp eax, SOCKET_ERROR                                           ;see if cant connect
	jz @@connect_err                                                ;if error jump to connect_err
	invoke wsprintf,addr buffer,addr HostYay,addr szStartIP         ;if no error then let user know
	invoke StdOut, addr buffer                                      ;output the shit
invoke RtlZeroMemory, addr buff_sock, sizeof buff_sock
	invoke send, sock, addr req1, 137, 0                            ;then send the first data string
	invoke RtlZeroMemory, addr buff_sock, sizeof buff_sock
	invoke recv, sock, addr buff_sock, sizeof buff_sock, 0
	test eax, eax
	jle @@recv_err
	invoke send, sock, addr req2, 168, 0                            ;then send the second data string
	invoke RtlZeroMemory, addr buff_sock, sizeof buff_sock
	invoke recv, sock, addr buff_sock, sizeof buff_sock, 0
	test eax, eax
	jle @@recv_err
	invoke send, sock, addr req3, 222, 0                            ;then send the third data string
	invoke RtlZeroMemory, addr buff_sock, sizeof buff_sock
	invoke recv, sock, addr buff_sock, sizeof buff_sock, 0          ;recieve the data
	test eax, eax
	jle @@recv_err   
	 movzx eax, byte ptr [buff_sock + 68]                            ;compare the 68th byte to '0'
	cmp eax, '0'
	jne @@xp                                                       ; if its equal then its win2k
	invoke StdOut, addr win2k                                      ; if not its xp
	inc counter
  invoke closesocket, sock
	jmp @@incrementIP
	
@@xp:
	invoke StdOut, addr winxp
	inc counter
  invoke closesocket, sock
	jmp @@incrementIP

@@recv_err:
	invoke StdOut, addr RcvError
  invoke closesocket, sock
  jmp @@incrementIP

@@send_err:
	invoke StdOut, addr SendError
  invoke closesocket, sock
  jmp @@incrementIP

@@connect_err:
  invoke convertit
	invoke wsprintf,addr buffer,addr HostErr,addr szStartIP
	invoke	StdOut,addr buffer
  invoke closesocket, sock
  jmp @@incrementIP
scandone: 
  invoke StdOut, addr complete
  invoke wsprintf,addr buffer,addr foundfmt,counter
  invoke StdOut, addr buffer
@@err:
	invoke closesocket, sock
	invoke WSACleanup
  ret
Detect endp
	
convertit proc      ;b0r0's uber leet bswap endian conversion
  LOCAL Temp1:DWORD
  LOCAL Temp2:DWORD
  LOCAL Temp3:DWORD
  LOCAL Temp4:DWORD
    mov eax,startip 
    mov edx, eax
      bswap edx
      movzx edx, dl
      mov Temp4, edx
    mov edx, eax
      bswap edx
      movzx edx, dh
      mov Temp3, edx
    mov edx, eax
      movzx edx, dh
      mov Temp2, edx
    mov edx, eax
      movzx edx, dl
      mov Temp1, edx
    invoke wsprintf, addr szStartIP, addr Ipformat, Temp1, Temp2, Temp3, Temp4
    ret
convertit endp





GetCPU PROC
 local  TheReturn:DWORD
 local  keySize:DWORD
 local  RegData[64]:BYTE
 local  MHZkeySize:DWORD
 local  MHZData:DWORD
   jmp @F
   SubKey     db 'HARDWARE\DESCRIPTION\System\CentralProcessor\0\',0
   szCPUName  db 'VendorIdentifier',0
   CPUMHZ     db '%lu MHz',0
   CPUfmt     db 'CPU:    %s',10,13,0
   SPDfmt     db 'SPD:    %s',10,13,0 
   MHZkey     db '~MHz',0
@@:
    invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr SubKey,0,KEY_READ,addr TheReturn
    invoke RegQueryValueEx,TheReturn,addr szCPUName,0,0,addr RegData, addr keySize ;the cpu vendor is in RegData
    invoke wsprintf,addr buffer,addr CPUfmt,addr RegData
    invoke StdOut, addr buffer
    invoke RegCloseKey , TheReturn
;now get the farking speed
;this is gonna be a little trick.. most of the time the cpu speed is held in the registry
;under HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0\ under the key ~MHZ
    invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr SubKey,0,KEY_READ,addr TheReturn
          mov     MHZkeySize, 4
    invoke RegQueryValueEx,TheReturn,addr MHZkey,0,0,addr MHZData, addr MHZkeySize ;the mhz is in mhzdata
      .IF eax==ERROR_SUCCESS ;yay the key is there
         invoke wsprintf, addr buffer,addr CPUMHZ,MHZData
         invoke wsprintf, addr OutBuff, addr SPDfmt,addr buffer
          invoke StdOut, addr OutBuff
         invoke RegCloseKey , TheReturn
         jmp mhzdone
      .ENDIF
    ;if there is no registry entry  then we be fucked and have to do some shitty coding  
     xor eax, eax ; make eax = 0
     db 0fh, 31h ;rdtsc
     mov ebx, eax ; move eax into ebx
     invoke Sleep, 1000 ; sleep for a second
     db 0fh, 31h ;rdtsc
     sub eax, ebx ; subtract the difference
     sub eax, 8 ; subtract 8 from eax
     xor edx, edx ; make edx = 0
     mov ecx, 1000000 ; move 1000000 into ecx
     div ecx ; divide ecx
     invoke wsprintf, addr buffer,addr CPUMHZ, eax
     invoke wsprintf, addr OutBuff, addr SPDfmt,addr buffer
     invoke StdOut, addr OutBuff
 mhzdone:
     ret
GetCPU ENDP

GetOS PROC
local sOSInfo:OSVERSIONINFO
local ospt:dword
local TheReturn2:DWORD
local SPData[64]:BYTE
jmp @F
   szWin0     db   'WinNT', 0
   szWin1     db   'Win95', 0
   szWin2     db   'Win98', 0
   szWin3     db   'WinME', 0
   szWin4     db   'Win2K', 0
   szWin5     db   'WinXP', 0
   szWin6     db   'Win2K3', 0
   sz9xkey    db   'SOFTWARE\Microsoft\Windows\CurrentVersion\',0
   NTkey      db   'SOFTWARE\Microsoft\Windows NT\CurrentVersion\',0
   szSPkey    db   'CSDVersion',0
   OSfmt      db   'OS:     %s',10,13,0
   SPfmt      db   'SP:     %s',10,13,0
@@:
  mov sOSInfo.dwOSVersionInfoSize, sizeof OSVERSIONINFO
  invoke GetVersionEx, addr sOSInfo
 .if sOSInfo.dwMajorVersion == 3 ; nt based
    mov ospt, offset szWin0      ;its NT
  .elseif sOSInfo.dwMajorVersion == 4 ;9x based
    .if sOSInfo.dwMinorVersion == 10
      mov ospt, offset szWin2   ;its 98
  .elseif sOSInfo.dwMinorVersion == 90
      mov ospt, offset szWin3   ;its ME
  .elseif sOSInfo.dwPlatformId == 2
      mov ospt, offset szWin0
   .else
      mov ospt, offset szWin1 ;its 95
 .endif
 
  .elseif sOSInfo.dwMajorVersion == 5
    .if sOSInfo.dwMinorVersion == 0
      mov ospt, offset szWin4 ;2k = major5,minor0
    .else
      mov ospt, offset szWin5 ;xp = major5,minor1
    .endif
  .else
    mov ospt, offset szWin6  ;2k3 = major6
.endif
      invoke wsprintf, addr OutBuff,addr OSfmt,ospt
      invoke StdOut, addr  OutBuff
      
;--sp info
     invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr NTkey,0,KEY_READ,addr TheReturn2
           .IF eax==ERROR_SUCCESS ;if success its nt
              invoke RegQueryValueEx,TheReturn2,addr szSPkey,0,0,addr SPData,addr SPkeySize1 ;the sp is in SPData
              .IF eax==ERROR_SUCCESS ;if success its nt
                   invoke wsprintf, addr OutBuff,addr SPfmt,addr SPData
                   invoke StdOut, addr  OutBuff
              .ENDIF
           .ELSE  ; its 9x
           invoke StdOut, addr  szSPkey
             invoke RegOpenKeyEx, HKEY_LOCAL_MACHINE,addr sz9xkey,0,KEY_READ,addr TheReturn2
             invoke RegQueryValueEx,TheReturn2,addr szSPkey,0,0,addr SPData,addr SPkeySize1 ;the sp is in SPData
             invoke wsprintf, addr OutBuff,addr SPfmt,addr SPData
             invoke StdOut, addr  OutBuff
          .ENDIF 
invoke RegCloseKey , TheReturn2      
      ret
GetOS ENDP
end start
