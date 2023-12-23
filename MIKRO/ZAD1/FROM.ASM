dane segment
assume cs:program,ds:dane

text1 db 0ah,0dh,0ah,0dh,'text w CMOS :$'
cmos db 20h dup (' ')
pusty db 0ah,0dh,0ah,0dh,'$'



dane ends



program segment


starcik:

mov ax,dane
mov ds,ax
include io.
include hack.

wypisz_ciag text1 


czytaj_cmos cmos

wypisz_ciag cmos
wypisz_ciag pusty




mov ax,4c00h
int 21h
program ends

end starcik
