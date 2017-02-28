;create a file call ad.ini and put your names in it
;<--snip-->
;[install]
;ServicesName=My_Service_Name
;DisplayName=Microsoft Notepad Updater
;Path=c:\windows\n0tepad.exe
;<--snip-->


.386
.model flat, stdcall 
option casemap :none 
include \masm32\include\windows.inc 
include \masm32\include\kernel32.inc  
include \masm32\include\masm32.inc
include \masm32\include\user32.inc
include \masm32\include\advapi32.inc 
includelib \masm32\lib\kernel32.lib 
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\advapi32.lib 
includelib \masm32\lib\user32.lib 
 literal MACRO quoted_text:VARARG
       LOCAL local_text
       .data
         local_text db quoted_text,0
       .code
       EXITM <local_text>
 ENDM
 SADD MACRO quoted_text:VARARG
       EXITM <addr literal(quoted_text)>
 ENDM
LOAD MACRO  dest, src
   mov eax, src
   mov dest, eax
ENDM

InstallIt            PROTO
UnInstallIt          PROTO
ServiceMain          PROTO stdcall  :DWORD, :DWORD
terminate            PROTO stdcall  :DWORD
ServiceCtrlHandler   PROTO stdcall  :DWORD
SendStatusToSCM      PROTO stdcall  :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
StopService          PROTO stdcall  
PauseService         PROTO stdcall
ResumeService        PROTO stdcall
InitService          PROTO stdcall
ErrorHandler         PROTO stdcall  :DWORD
ServiceThread        PROTO stdcall  :DWORD

.data
fPaused       BOOL         FALSE
fRunning      BOOL         FALSE
szBuffer      db           MAX_PATH dup(0)
ERROR_MESSAGE db           "In StartServiceCtrlDispatcher",0
hThread       HANDLE       NULL
evTerminate   HANDLE       NULL
   Theoutput  db   ' _____________________________________________',13,10
              db   '|                 ServiceMe 2.0               |',13,10
              db   '|                 Coded In MASM               |',13,10
              db   '|        by illwill  - xillwillx@yahoo.com    |',13,10
              db   '|_____________________________________________|',13,10,0
   szParams   db   '                   USAGE:',13,10
              db   '               Install: SM.exe i',13,10
              db   '               Remove:  SM.exe r',13,10,13,10,13,10,0
   szStart    db   '                 Service Created.',13,10
              db   '            To tart your service type:',13,10
              db   '                  Net Start %s',13,10,13,10,13,10,0
commandLine   dd 0
inihead       db "install",0
keyS          db "ServicesName",0
keyD          db "DisplayName",0
keyP          db "Path",0
ini           db "\ad.ini",0 


.data?
 szCommand    db 1   dup(?)
 szService    db 64  dup(?)
 szDisplay    db 64  dup(?)
 szPath       db 64  dup(?)
 mebuff       db 256 dup(?)
 Installed    db 256 dup(?)
 CurDir       db 256 dup(?)
 Startbuff    db 256 dup(?)
 hStatus      DWORD ?
 sStatus      SERVICE_STATUS <>
 sTable       SERVICE_TABLE_ENTRY <>


.code
start:
     invoke GetCurrentDirectory, sizeof CurDir, addr CurDir
     invoke lstrcat, addr CurDir, addr ini
     invoke GetPrivateProfileString, addr inihead, addr keyD,0, addr szDisplay, 64, addr CurDir
     invoke GetPrivateProfileString, addr inihead, addr keyP,0, addr szPath,64, addr CurDir  

    
         invoke GetCommandLine
         mov commandLine, eax
         invoke GetCL, 1, addr szCommand
         mov      al, szCommand
         cmp      al, '?'
         je       @F
         cmp      al, 'h'
         je       @F
         cmp      al, 'i'
         je       install
         cmp      al, 'r'
         je       uninstall
         jmp       Run_it
         
@@:              
         invoke StdOut, addr Theoutput
         invoke StdOut, addr szParams
         jmp End_it
install:
         invoke StdOut, addr Theoutput
         invoke InstallIt
         jmp End_it
uninstall:
         invoke StdOut, addr Theoutput
         invoke UnInstallIt
         jmp End_it

Run_it:
     mov  sTable.lpServiceProc, offset ServiceMain
     LOAD sTable.lpServiceName, offset szService
     invoke StartServiceCtrlDispatcher, addr sTable
     .IF eax == 0
      invoke ErrorHandler, addr ERROR_MESSAGE
     .ENDIF
      
End_it:
invoke ExitProcess, eax


InstallIt PROC
local hSCManager:HANDLE 
local hService:HANDLE 
  invoke GetModuleFileNameA, 0, addr mebuff, 255
  invoke GetShortPathNameA, addr mebuff, addr mebuff, 255
  invoke GetPrivateProfileString, addr inihead, addr keyS,0, addr szService, 64, addr CurDir
  invoke wsprintf,addr Startbuff,addr szStart,addr szService
  invoke OpenSCManager, NULL, NULL, SC_MANAGER_CREATE_SERVICE 
 .if eax != NULL
   mov hSCManager, eax 
   invoke CreateService, hSCManager, addr szService, \
                                     addr szDisplay, \ 
                                     SERVICE_ALL_ACCESS, \
                                     SERVICE_WIN32_OWN_PROCESS, \
                                     SERVICE_AUTO_START, \ 
                                     SERVICE_ERROR_IGNORE,\
                                     addr mebuff, 0,0,0,0,0
                                  
  .if eax != NULL
    invoke StdOut, addr Startbuff
    mov hService, eax 
    invoke CloseServiceHandle, hService 
  .else
   invoke StdOut, SADD("Can't Create Service.",10,13)
  .endif

   .IF eax == 0
      invoke ErrorHandler, addr ERROR_MESSAGE
   .ENDIF
   invoke CloseServiceHandle, hSCManager 
 .else
   invoke StdOut, SADD("Can't Open Service Control Manager.",10,13) 
 .endif

ret
InstallIt ENDP

UnInstallIt PROC
local hSCManager:HANDLE 
local hService:HANDLE 
local @stStatus:SERVICE_STATUS
invoke GetPrivateProfileString, addr inihead, addr keyS,0, addr szService, 64, addr CurDir
invoke OpenSCManager, NULL, NULL, SC_MANAGER_CREATE_SERVICE 
.if eax != NULL
  mov hSCManager, eax 
  invoke OpenService,hSCManager,addr szService,SERVICE_ALL_ACCESS
 .if eax
     mov hService,eax
     invoke QueryServiceStatus,hService,addr @stStatus
       .if eax != NULL  
         invoke StdOut, SADD(" Service Running...",10,13, " Stopping Service...",10,13)        
         invoke ControlService,hService,SERVICE_CONTROL_STOP,addr @stStatus
       .else
         invoke StdOut, SADD("Service Not Currently Running.")
       .endif
     invoke DeleteService, hService
       .if eax != NULL
         invoke StdOut, SADD(" Service Deleted.",10,13)        
       .else
         invoke StdOut, SADD("Error Deleting Service.")
       .endif
 .else
   invoke StdOut, SADD("Error Opening Service.")
 .endif
   invoke CloseServiceHandle,hService
   invoke CloseServiceHandle, hSCManager 
.else
   invoke StdOut, SADD("Can't Open Service Control Manager.") 
.endif
ret
UnInstallIt ENDP

Thread proc param:DWORD
 invoke WinExec,addr szPath, SW_SHOW
    ret
Thread endp
 
Init proc
   LOCAL id:DWORD
   invoke CreateThread, 0, 0, Thread, 0, 0, addr id
   mov  hThread, eax
   .IF eax != 0
      mov  fRunning, 1
      mov  eax, 1
   .ENDIF
   ret
Init endp


Resume proc
   mov  fPaused, FALSE
   invoke ResumeThread, hThread
   ret
Resume endp


Pause proc
   mov fPaused, TRUE
   invoke SuspendThread, hThread
   ret
Pause endp

Stop proc
   mov fRunning, FALSE
   invoke SetEvent, evTerminate
   ret
Stop endp



ErrorHandler proc err:DWORD
   invoke StdOut, addr szBuffer
   invoke ExitProcess, err
   ret
ErrorHandler endp



SendStatus proc dwCurrentState:DWORD, dwWin32ExitCode:DWORD, dwServiceSpecificExitCode:DWORD, dwCheckPoint:DWORD, dwWaitHint:DWORD
   LOCAL success:BOOL

   mov sStatus.dwServiceType, SERVICE_WIN32_OWN_PROCESS
   LOAD sStatus.dwCurrentState, dwCurrentState
   .IF dwCurrentState == SERVICE_START_PENDING
      mov sStatus.dwControlsAccepted, 0
   .ELSE
      mov sStatus.dwControlsAccepted, \
                        SERVICE_ACCEPT_STOP or \
                        SERVICE_ACCEPT_PAUSE_CONTINUE or \
                        SERVICE_ACCEPT_SHUTDOWN
   .ENDIF
   .IF dwServiceSpecificExitCode == 0
      LOAD sStatus.dwWin32ExitCode, dwWin32ExitCode
   .ELSE
      mov sStatus.dwWin32ExitCode, \
         ERROR_SERVICE_SPECIFIC_ERROR
   .ENDIF

   LOAD sStatus.dwServiceSpecificExitCode, dwServiceSpecificExitCode
   LOAD sStatus.dwCheckPoint, dwCheckPoint
   LOAD sStatus.dwWaitHint, dwWaitHint

   invoke SetServiceStatus, hStatus, addr sStatus
   mov eax, 1
   ret
SendStatus endp


;Dispatches events received from the service
;control manager
CtrlHandler proc controlCode:DWORD
   LOCAL currentState:DWORD
   LOCAL success:BOOL

   mov   currentState,      0
   mov   eax, controlCode

   .IF eax == SERVICE_CONTROL_STOP
      LOAD currentState, SERVICE_STOP_PENDING
      invoke SendStatus, SERVICE_STOP_PENDING, NO_ERROR, 0, 1, 5000
      call Stop
      ret


   .ELSEIF eax == SERVICE_CONTROL_PAUSE
      .IF fRunning != 0 && fPaused == 0
         ;Tell the SCM what's happening
         invoke SendStatus, SERVICE_PAUSE_PENDING, NO_ERROR, 0, 1, 1000
         call Pause
         mov  currentState, SERVICE_PAUSED;
         jmp SCHandler
      .ENDIF

   .ELSEIF eax == SERVICE_CONTROL_CONTINUE
       .IF fRunning != 0 && fPaused == 0
          invoke SendStatus, SERVICE_CONTINUE_PENDING, NO_ERROR, 0, 1, 1000
          call Resume
          mov currentState, SERVICE_RUNNING
          jmp SCHandler
       .ENDIF

  .ELSEIF eax == SERVICE_CONTROL_INTERROGATE

  .ELSEIF eax == SERVICE_CONTROL_SHUTDOWN
      ret

  .ENDIF

 SCHandler:
     invoke SendStatus, currentState, NO_ERROR, 0, 0, 0
     ret
CtrlHandler endp

terminate proc error:DWORD

   ;if evTerminate has been created, close it.
   .IF evTerminate != 0
      push evTerminate
      call CloseHandle
   .ENDIF

   .IF hStatus != 0
       invoke SendStatus, SERVICE_STOPPED, error, 0, 0, 0
   .ENDIF

    .IF hThread != 0
      push hThread
      call CloseHandle
   .ENDIF
terminate endp


ServiceMain proc argc:DWORD, argv:DWORD
   LOCAL success:BOOL
   LOCAL temp:DWORD

   invoke RegisterServiceCtrlHandler, addr szService,  CtrlHandler
   mov  hStatus, eax

   .IF eax == 0
      call GetLastError
      push eax
      call terminate
      ret
   .ENDIF

   invoke SendStatus, SERVICE_START_PENDING, NO_ERROR, 0, 1, 5000

   invoke CreateEvent, 0, TRUE, FALSE, 0
   mov evTerminate, eax

   .IF eax == 0
      call GetLastError
      push eax
      call terminate
      ret
   .ENDIF

   invoke SendStatus, SERVICE_START_PENDING, NO_ERROR, 0, 2, 1000

   invoke SendStatus, SERVICE_START_PENDING, NO_ERROR, 0, 3, 5000

   ;Start the service itself
   call Init
   mov success, eax
   .IF eax == 0
      call GetLastError
      push eax
      call terminate
      ret
   .ENDIF

   invoke SendStatus, SERVICE_RUNNING, NO_ERROR, 0, 0, 0

   invoke WaitForSingleObject, evTerminate, INFINITE
   push 0
   call terminate
   ret

ServiceMain endp

end start


