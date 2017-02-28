.586
.model flat,stdcall
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\netapi32.inc
include \masm32\include\msvcrt.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\netapi32.lib
includelib \masm32\lib\msvcrt.lib

include <\masm32\macros\macros.asm>

main 		PROTO :DWORD, :DWORD

.data
 usage      db  "                                    ",13,10,\
                "[*]------------------------------[*]",13,10,\
                "[*]           GhostUser          [*]",13,10,\
                "[*]          by: illwill         [*]",13,10,\
                "[*]------------------------------[*]",13,10,13,10,0
usage2      db  'Usage: GU.exe <user> <pass> <description>',13,10,\
                'Example: GU SecureMS letmein "Built-in Account for owning."',13,10,0
yay         db  "User Sucessfully added.",0
nay         db  "User Not added.",0
stinfo			STARTUPINFO	<?>
bWildCard	  DWORD		?
pEnv				DWORD		?
pArgv				DWORD		?
nArgc				DWORD		?
.data?
 hOutput         dd ?
consoleInfo CONSOLE_SCREEN_BUFFER_INFO <>
.code
start:
    push EDI
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov hOutput, eax
	  invoke GetConsoleScreenBufferInfo, hOutput, ADDR consoleInfo
         movzx EDI,consoleInfo.wAttributes
    invoke SetConsoleTextAttribute, hOutput, FOREGROUND_GREEN  or \
                                             FOREGROUND_INTENSITY 
                                             
	mov	[bWildCard], FALSE
	invoke crt___wgetmainargs,addr nArgc,addr pArgv,addr pEnv,[bWildCard],addr stinfo

	invoke main,[nArgc],[pArgv]

  invoke SetConsoleTextAttribute, hOutput, EDI
	invoke crt_exit

main PROC USES EDI argc:DWORD, argv:DWORD

	LOCAL	ui		:USER_INFO_1
	LOCAL	dwLevel	:DWORD
	LOCAL	dwError	:DWORD
	LOCAL	nStatus	:NET_API_STATUS
	
	.IF ( argc == 4 )

		mov	[dwLevel], 1
		and	[dwError], 0
	
		mov	esi, [argv]
		lea	edi, [ui]

		lodsd				; argv[0]
		lodsd				; argv[1] / username
		mov	[edi][USER_INFO_1.usri1_name], eax
	
		lodsd				; argv[2] /password
		mov	[edi][USER_INFO_1.usri1_password], eax

		mov	[edi][USER_INFO_1.usri1_priv], USER_PRIV_USER
		mov	[edi][USER_INFO_1.usri1_home_dir], NULL
				lodsd				; argv[3] /comment
		mov	[edi][USER_INFO_1.usri1_comment], eax
		mov	[edi][USER_INFO_1.usri1_flags], UF_SCRIPT
		mov	[edi][USER_INFO_1.usri1_script_path], NULL
	
		invoke NetUserAdd,
			NULL,
			[dwLevel],
			addr ui,
			addr dwError
	
		.IF (eax == NERR_Success)
		    invoke StdOut, addr usage
			  invoke StdOut, addr yay
		.ELSE
		    invoke StdOut, addr usage
			  invoke StdOut, addr nay
		.ENDIF
	.ELSE
		invoke StdOut, addr usage
		invoke StdOut, addr usage2
	.ENDIF
	ret
main ENDP

end start
