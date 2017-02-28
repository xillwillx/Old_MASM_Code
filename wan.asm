; basically connects to http://checkip.dyndns.org/ and gets the html source of the page
; into a string buffer which would look like
; <html><head><title>Current IP Check</title></head><body>Current IP Address: 68.9.70.154</body></html>
; then parse off the beginning junk up to the :  in the string so it will look like
;  68.9.70.154</body></html>
; then parse the </body></html> so the remaining ip address is in the string   

.386                   
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib


includelib \masm32\lib\wininet.lib
include \masm32\include\wininet.inc

Download  PROTO :DWORD
Stripper PROTO :DWORD, :DWORD
.data
   url1         db "http://checkip.dyndns.org/",0
   szIP         db "Your WAN IP",0
   NoIPFound    db "N/A",0
.data?
   buffer       db 256 dup(?)
   htmlBuffer   db 256 dup(?)
.code
Start:

invoke Download,addr url1
invoke Stripper, ADDR htmlBuffer, ADDR buffer ; stripper ,the string to strip,the finished string
cmp eax,0
jnz noip
invoke MessageBox,0,addr buffer,addr szIP,0
invoke ExitProcess,0

noip:
invoke MessageBox,0,addr NoIPFound,addr szIP,0
invoke ExitProcess,0

Download PROC lpszURL:DWORD
    local hInternet:DWORD
    local hURL:DWORD
    local hFile:DWORD
    ;local htmlBuffer[1024]:BYTE
    local BufferLen:DWORD
    local BytesWrite:DWORD
    jmp @F
    lpszAgent DB "Mozilla",0
    @@:
    invoke InternetOpen, addr lpszAgent, INTERNET_OPEN_TYPE_PRECONFIG, 0, 0, 0
    mov hInternet, eax
    invoke InternetOpenUrl, hInternet, lpszURL, 0, 0, 0, 0
    mov hURL, eax
        invoke InternetReadFile, hURL, addr htmlBuffer, sizeof htmlBuffer, addr BufferLen

    invoke CloseHandle, hFile
    invoke InternetCloseHandle, hURL
    cmp eax, 0
    jz done
    invoke InternetCloseHandle, hInternet
    xor eax, eax
    inc eax
    ret   
    done:
    xor eax, eax
    ret
    Download ENDP

Stripper PROC uses esi edi ebx theString:DWORD, stripped:DWORD
   
   mov esi, theString
 
@@:
   cmp BYTE PTR [esi], 0
   je _ERROR            ;end of string and no :
   cmp BYTE PTR [esi], ':'
   je @f
   inc esi     
   jmp @b            ; if not found jump back up to @@
@@:
   inc esi
   inc esi   ;one space before IP now esi should point to IP.

   mov edi, stripped
@@:
   lodsb
   cmp al, 0
   je NoMore
   cmp al, '<'
   je NoMore
   stosb            ; Store String Byte 
   jmp @b
_ERROR:
   mov eax, -1 ;function returns -1 if no IP found
   ret
NoMore:
    inc edi
    mov BYTE PTR [edi], 0;bug fix
    mov eax, 0
    ret
Stripper ENDP

end Start 
