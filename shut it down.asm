 .386                    
.model flat,stdcall 
option casemap:none 
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\advapi32.lib
include \masm32\include\advapi32.inc

FORCEIT PROTO
.data
       ShutdownPrivilege   db  "SeShutdownPrivilege",0 
       
.data?
    hToken              HANDLE      ?
    osv                 OSVERSIONINFO <>  
.code
   start:
   invoke FORCEIT
   invoke ExitProcess,0
   
   FORCEIT PROC
   LOCAL   tp:TOKEN_PRIVILEGES
   
            .IF osv.dwPlatformId==VER_PLATFORM_WIN32_NT            
                invoke  GetCurrentProcess                                                                
                invoke  OpenProcessToken,eax,TOKEN_ADJUST_PRIVILEGES+TOKEN_QUERY,ADDR hToken            
                invoke  LookupPrivilegeValue,NULL,ADDR ShutdownPrivilege, ADDR tp.Privileges[0].Luid    	
	          mov     tp.PrivilegeCount,1                                                             
		    mov     tp.Privileges[0].Attributes,SE_PRIVILEGE_ENABLED                                
	          invoke  AdjustTokenPrivileges,hToken,FALSE, ADDR tp, 0, NULL, 0                         
            .ENDIF                         
            invoke  ExitWindowsEx, EWX_FORCE+EWX_REBOOT, NULL
               .IF eax==TRUE
                     jmp endit
               .ELSEIF eax==FALSE
                     jmp start
               .ENDIF
   endit:
   ret
   FORCEIT endp
end start
