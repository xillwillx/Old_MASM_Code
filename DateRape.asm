   include \masm32\include\masm32rt.inc

    Find_File PROTO
    SetDate   PROTO :DWORD
.data?
      day   dw ?
      month dw ?
      year  dw ?
      fpath db 260 dup (?)
.data
      ppath dd fpath

.code

 start:
    call main
    exit

main proc

    LOCAL pcmd  :DWORD
    LOCAL pbuf  :DWORD
    LOCAL buffer[128]:BYTE

    mov pbuf, ptr$(buffer)
    mov pcmd, rv(GetCommandLine)


    cmp len(pcmd),128                         ; test command line length
    jle @F
    print "Exceeds 128 Char Length",13,10,13,10
    ret
  @@:
    cmp rv(GetCL,1,ppath), 1                  ; read optional file path and file pattern
    je @F
    print "invalid path or file",13,10,13,10
    call Howto
    ret
  @@:
    cmp rv(GetCL,2,pbuf), 1                   ; get day argument
    je @F
    print "Enter Day argument",13,10,13,10
    call Howto
    ret
  @@:
    invoke atodw,pbuf
    mov day, ax

    cmp rv(GetCL,3,pbuf), 1                   ; get month argument
    je @F
    print "Enter Month argument",13,10,13,10
    call Howto
    ret
  @@:
    invoke atodw,pbuf
    mov month, ax

    cmp rv(GetCL,4,pbuf), 1                    ; get year argument
    je @F
    print "Enter Year argument",13,10,13,10
    call Howto
    ret
  @@:
    invoke atodw,pbuf
    mov year, ax

    invoke Find_File
    ret
main endp

; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

Find_File proc

    LOCAL hSrch :DWORD
    LOCAL wfd   :WIN32_FIND_DATA

    mov hSrch, rv(FindFirstFile,ppath,ADDR wfd)

    .if hSrch != INVALID_HANDLE_VALUE
      lea eax, wfd.cFileName
      switch$ eax
        case$ "."                           ; bypass current directory character
          jmp @F
      endsw$
      invoke SetDate,ADDR wfd.cFileName

    @@:
      invoke FindNextFile,hSrch,ADDR wfd
      test eax, eax
      jz close_file
      lea eax, wfd.cFileName
      switch$ eax
        case$ ".."                          ; bypass previous directory characters
          jmp @F
      endsw$
      invoke SetDate,ADDR wfd.cFileName

    @@:
      invoke FindNextFile,hSrch,ADDR wfd    ; loop through the rest
      test eax, eax
      jz close_file
      invoke SetDate,ADDR wfd.cFileName
      jmp @B

    close_file:
      invoke FindClose,hSrch

    .endif

    ret

Find_File endp

; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

SetDate proc filename:DWORD

    LOCAL hFile     :DWORD
    LOCAL ftime     :FILETIME
    LOCAL stime     :SYSTEMTIME

    mov hFile, fopen(filename)

    m2m stime.wYear, year
    m2m stime.wMonth, month
    mov stime.wDayOfWeek, 0
    m2m stime.wDay, day
    mov stime.wHour, 00
    mov stime.wMinute, 0
    mov stime.wSecond, 0
    mov stime.wMilliseconds, 0

    invoke SystemTimeToFileTime,ADDR stime,ADDR ftime
    invoke SetFileTime,hFile,ADDR ftime,ADDR ftime,ADDR ftime

    ret

SetDate endp
; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
Howto proc
   print "__________________________________________________ ",13,10
   print "                      DateRape 1.0                |",13,10
   print "                      Coded In MASM               |",13,10
   print "             by illwill  - xillwillx@yahoo.com    |",13,10
   print "__________________________________________________|",13,10,13,10,0
   print "USAGE: DateRape <Filename> Day Month Year          ",13,10
   print "                   Day   = 1-7                     ",13,10
   print "                   Month = 1-12                    ",13,10
   print "                   Year  = 4 digit year            ",13,10,13,10,0
   print "Ex:  DateRape mynotes.txt 2 11 1979                ",13,10
   print "Ex2: DateRape 'c:\my folder\yo.mp3' 1 1 1979       ",13,10
    ret
Howto endp

end start
