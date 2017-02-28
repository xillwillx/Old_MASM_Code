include \masm32\include\masm32rt.inc
include \masm32\include\advapi32.inc
includelib \masm32\lib\advapi32.lib
ClearLog   PROTO :DWORD
.data  
   commandLine  dd 0
   Banner       db   ' _____________________________________________________________ ',13,10
                db   '*                    ClearlogsCL 1.1                          *',13,10
                db   '*            by illwill  - xillwillx@yahoo.com                *',13,10
                db   '*_____________________________________________________________*',13,10,13,10,0     
   Help         db   '            USAGE: cl [Log#]',13,10
                db   '                  1 = Application Log',13,10
                db   '                  2 = Security Log',13,10
                db   '                  3 = System Log',13,10
                db   '                  4 = All Logs',13,10,13,10
                db   '          EXAMPLE: cl 1',13,10,13,10,0
   App          db   'Application',0
   Sec          db   'Security',0
   Syst         db   'System',0
.data?
   szLog          db 2 dup (?)
.code
 start:
      invoke GetCommandLine
         mov commandLine, eax
      invoke GetCL, 1, addr szLog
         mov al, szLog
      invoke   StdOut, addr Banner
       .if al == '1'
         invoke ClearLog,addr App
       .elseif al == '2'
         invoke ClearLog,addr Sec
       .elseif al == '3'
         invoke ClearLog,addr Syst
       .elseif al == '4'
         invoke ClearLog,addr App
         invoke ClearLog,addr Sec
         invoke ClearLog,addr Syst
       .else
         invoke   StdOut, addr Help
       .endif
         invoke  ExitProcess, eax
    
ClearLog PROC TheLog:DWORD
   local hLog:DWORD
    local  OutBuff[128]:BYTE
 .data
   fmt   db '               %s log has been cleared.',13,10,0
   fmt2  db ' Error clearing %s log! Check your access security level.',0
 .code
   invoke OpenEventLog,NULL,TheLog                         ;open the eventlog
   .IF eax!=NULL                                           ; if openlog is a success 
      mov hLog,eax                                         ;   save to pointer to open handle 
      invoke ClearEventLog,hLog,NULL                       ;   clear the log chosen
        .if eax!=NULL                                      ;   check to see if that worked
           invoke CloseEventLog,hLog                       ;   close log
           invoke wsprintf, addr OutBuff, addr fmt,TheLog  ;   output the success banner
           invoke StdOut, addr OutBuff
        .else                                              ; else the clear failed 
           invoke wsprintf, addr OutBuff, addr fmt2,TheLog ;  show the fail banner 
           invoke StdOut, addr OutBuff                      
        .endif
   .ELSE                                                   ;opening the log failed
        invoke wsprintf, addr OutBuff, addr fmt2,TheLog    ; let the user know
        invoke StdOut, addr OutBuff
   .ENDIF
       ret                                                 ;we're done
ClearLog ENDP
end start
