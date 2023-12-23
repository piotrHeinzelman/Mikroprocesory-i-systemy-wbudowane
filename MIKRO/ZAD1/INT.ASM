prog segment byte 
assume cs:prog
poczatek_int:

adres_21h dd (?)
pomoc1 dw (?)
pomoc2 dw (?)
pomoc3 dw (?)

obsluga_21h:

pushf
call dword ptr [adres_21h]

mov word ptr pomoc1,ax
pop ax
mov word ptr pomoc2,ax
pop ax 
mov word ptr pomoc3,ax
pop ax
pushf
mov ax,pomoc3
push ax
mov ax,pomoc2
push ax
mov ax,pomoc1

iret

koniec_int:


include przerwan.ia
start:

instaluj 21h
pozostaw_rezydentny 


mov ax,4c00h
int 21h





prog ends
end start
