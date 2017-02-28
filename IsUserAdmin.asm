IsUserAdmin PROC
	LOCAL NtAuthority:SID_IDENTIFIER_AUTHORITY
	LOCAL AdministratorsGroup:SID
	LOCAL fAdmin:BOOL
	invoke RtlZeroMemory, addr NtAuthority, sizeof SID_IDENTIFIER_AUTHORITY
	mov NtAuthority.Value[5], 5 ;SECURITY_NT_AUTHORITY
	mov fAdmin, FALSE
	invoke AllocateAndInitializeSid, addr NtAuthority, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, addr AdministratorsGroup
	test eax, eax
	jz short @@admin_end
	lea eax, AdministratorsGroup
	mov eax, [eax]
	xchg ebx, eax
	invoke CheckTokenMembership, 0, ebx, addr fAdmin
	invoke FreeSid, addr AdministratorsGroup
	mov eax, fAdmin
	ret
@@admin_end:
	xor eax, eax
	ret
IsUserAdmin ENDP
