.386
.model flat, stdcall
option casemap :none
;|      Headers:
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\wsock32.inc
include \masm32\include\shell32.inc
include \masm32\include\advapi32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\wsock32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\masm32.lib
ClearLog   PROTO :DWORD
GetUp      PROTO
GetIPAddy  PROTO
GetRam     PROTO
GetUser    PROTO
GetCPU     PROTO
GetOS      PROTO
.data
   Theoutput  db   ' __________________________________________________',13,10
              db   '|                        CMDit 1.1                 |',13,10
              db   '|                      Coded In MASM               |',13,10
              db   '|             by illwill  - xillwillx@yahoo.com    |',13,10
              db   '|__________________________________________________|',13,10,13,10,0
   Usage      db   ' USAGE: CMDit.exe <option>                          ',13,10
              db   '        -i           = information about Machine    ',13,10
              db   '        -c <LogName> = Clears Event Log on Machine  ',13,10
              db   '           (ex. Application,Security,System)        ',13,10
              db   '        -l        = lists processes                 ',13,10
              db   '        -p <pid>  =  kill by PID #                  ',13,10
              db   '        -n <name> =  kill by proc name              ',13,10
              db   '                                                    ',13,10,13,10,0 
option1       db "-i",0
option2       db "-c",0
option3       db "-l",0
option4       db "-p",0
option5       db "-n",0
   SPkeySize1          DWORD 255
;--------------------uninitialized data
.data?
arg1          db 2   dup (?)
arg2          db 256 dup (?)
buffer        db 256 dup (?)
OutBuff       db 256 dup (?)
    ;SPData              db 64 dup (?)
   ; TheReturn2          DWORD ?

.code
start:
invoke GetCL,1,addr arg1                     ;get first argument
         invoke lstrlen,addr arg1            ;get the length of the first argument
              .IF eax>2                      ; make sure the dummies dont try to overflow us
                invoke ExitProcess,1         ;if they did then we exit with error code 1
              .ELSEIF eax==0                 ;shows usage if they dont know the params
                invoke StdOut,addr Theoutput ; post attentionwhore info
                invoke StdOut,addr Usage     ;post usage info to console
                invoke ExitProcess,0
              .ENDIF
invoke lstrcmp,addr arg1,addr option1
.IF eax==0                          ;they picked information
     invoke StdOut,addr Theoutput   ; post attentionwhore info
     invoke GetIPAddy 
     invoke GetUser
     invoke GetOS
     invoke GetCPU
     invoke GetRam
     invoke GetUp      
.ENDIF

invoke lstrcmp,addr arg1,addr option2
.IF eax==0                          ;they picked clearlogs
  invoke GetCL,2,addr arg2
  invoke lstrlen,addr arg2
    test eax,eax                    
    je dummy   ; they forgot the second argument
    invoke ClearLog,addr arg2     
.ENDIF

invoke lstrcmp,addr arg1,addr option3
.IF eax==0                          
  ;do code for first option3     
.ENDIF
 invoke ExitProcess,0
dummy:
 invoke StdOut,addr Theoutput ; post attentionwhore info
 invoke StdOut,addr Usage     ;post usage info to console
 invoke ExitProcess,0
;--------------------all the procs go here---------------------------
ClearLog PROC TheLog:DWORD
   local hLog:DWORD
   jmp @F
   LOGfmt db '%s log has been cleared.',0
@@:
   invoke OpenEventLog,NULL,TheLog   ;open the eventlog
   .IF eax!=NULL                     ;if success 
      mov hLog,eax                   ;save to pointer
      invoke ClearEventLog,hLog,NULL ;clear it
      invoke CloseEventLog,hLog      ;close log
   .ENDIF
       invoke wsprintf, addr OutBuff, addr LOGfmt,TheLog ;make a pretty output
       invoke StdOut,addr Theoutput                      ;post attentionwhore info       
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
            invoke wsprintf,addr OutBuff, addr HOSTfmt,addr buffer   ; the host is buffer
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

