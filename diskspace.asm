.386
.model	flat, stdcall
option	casemap:none
include		windows.inc
include		kernel32.inc
include		user32.inc
include shlwapi.inc
includelib	user32.lib
includelib	kernel32.lib
includelib shlwapi.lib
CTEXT MACRO y:VARARG
LOCAL sym, dummy
dummy EQU $;; MASM error fix
CONST segment
IFIDNI <y>,<>
sym db 0
ELSE
sym db y,0
ENDIF
CONST ends
EXITM <OFFSET sym>
ENDM


.data?
szFileSysName 	db 256 dup(?)
lpFreeNumberOfBytes dd ?,?          ;GetDiskFreeSpaceEx expects this to be 64-bits
lpTotalNumberOfBytes dd ?,?                  ;GetDiskFreeSpaceEx expects this to be 64-bits
buffer 	db 64 dup(?)
buffer2	db 64 dup(?)
outbuffer 	db 256 dup(?)

.code
start:
INVOKE GetVolumeInformation,CTEXT("C:\"),0,0,0,0,0,ADDR szFileSysName,MAX_PATH
invoke GetDiskFreeSpaceEx, CTEXT("C:\"),addr lpFreeNumberOfBytes,addr lpTotalNumberOfBytes, 0 
invoke StrFormatByteSize64, lpTotalNumberOfBytes, lpTotalNumberOfBytes+4, ADDR buffer, SIZEOF lpTotalNumberOfBytes
invoke StrFormatByteSize64, lpFreeNumberOfBytes, lpFreeNumberOfBytes+4, ADDR buffer2, SIZEOF lpFreeNumberOfBytes
invoke wsprintf,addr outbuffer,CTEXT("Disk Space: %s/%s",13,10,"File System: %s"),addr buffer,addr buffer2,addr szFileSysName
invoke MessageBox, NULL,addr outbuffer,CTEXT("C:\ Drive Info"), MB_OK
INVOKE MessageBox,NULL,0FF478h,CTEXT("Bios Date"),MB_OK
invoke ExitProcess,NULL
end start
