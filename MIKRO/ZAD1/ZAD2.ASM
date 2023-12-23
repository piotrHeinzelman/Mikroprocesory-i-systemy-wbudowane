MyStack SEGMENT STACK           	; slowo STACK powoduje zaladowanie do SS przez DOS
	DB 64 DUP ('STACK!!!')  	; rezerwacja 512 bajtow
MyStack ENDS  				; -- koniec segmentu Stack



MyData SEGMENT				; poczatek segmentu danych DS zwanego MyData

myName DB 0ah,0dh,0ah,0dh,"Piotr Heinzelman",0AH,0DH,'$'; definicja imienia i nazwiska na koncu terminator $
myStudy DB "Wydz. Elektryczny, kierunek ", 22H ,"Informatyka Stosowana", 22h, 0AH, 0DH,'$'
myDataTime DB "hh:mm:ss dd-mm-yyyy",0AH,0DH,'$'

CRLF DB 0DH, 0AH, '$'
MyData ENDS  			; -- koniec segmentu


; -- segment kod --

MyCode SEGMENT

assume CS:MyCode		; przypisanie rejestrow segmentowych
assume DS:MyData		;

Start:				; rozpoczecie programu
MOV AX,MyData			; trzeba drugi raz zaladowac DS inaczej cos nie bardzo dziala
PUSH AX				; rejestrow segmentowych nie mozna ladowac wprost przez MOV
POP DS				;
				; ustawienie adresu poczatku ciagu do wyswietlenia
				; ds:dx - adres poczatku ciagu dla funkcji DOS
	LEA DX,DS:myName	;	
				;
				; funkcja int21.f09 drukuj ciag znakow na konsole
	MOV AH,09H 		; bedzie wywolana funkcja 9
	INT 21H			; wywolanie int 21	
				;
	LEA DX,DS:myStudy	;
	INT 21H			; ponowne wywolanie wyswietlania ciagow
				;
				; aby nie wywolywac INT 21 wielokrotnie wpisze dane 
	LEA SI,DS:myDataTime	; do pamieci a potem wypisze ciag
				; adres kom. DS:SI
				;
				; pobieram czas
	MOV AH,02H		;
	INT 1AH			;  CH-godziny, CL-minuty, DH-sekundy DL czas letni
	PUSH DX ; CH sek
	PUSH CX ; CL min
	PUSH CX ; CH godz

	POP DX	      ; wypisz CH godz	
	XCHG DL,DH    ;	
	call wypiszDL ; wypisz DL godz

	MOV DL,':'    ;		
	call wypisz   ;	

	POP DX	      ; min
	call wypiszDL ;

	MOV DL,':'    ;		
	call wypisz   ;	

	POP DX	      ; sek
	XCHG DL,DH    ;	
	call wypiszDL ;

	XOR DL,DL     ; szybsze MOV DL,0
	call wypisz   ;	



			
				;
				;
	MOV AH,04H		; wczytanie daty INT 1Ah AH=04 
	INT 1Ah			; CH-wiek
				; CL-rok
				; DH=miesiac
				; DL=dzien
				;	
	PUSH CX			; zapisuje na stosie wiek i rok
	PUSH CX			;
	PUSH DX			; zapisuje na stosie miesiac i dzien
	PUSH DX			;
				;
	POP DX			; wypisze BCD z AH za pomoca procedury				; najpierw mlodsza para - dzien
	call wypiszDL		;
				;	
	MOV DL,'-'		; rozdzielam
	call wypisz		; wypisuje pusty znak - przerwa miedzy rok a miesiac
				;
	POP DX			; starsza para - miesiac	
	XCHG DH,DL		;
	call wypiszDL		;

	MOV DL,'-'		; rozdzielam
	call wypisz		; wypisuje pusty znak - przerwa miedzy rok a miesiac
				;

	POP DX			; rok - starszy
	XCHG DH,DL		;
	call wypiszDL		;
				;
	POP DX			; rok mlodszy
	call wypiszDL		;


	LEA DX,DS:myDataTime	; bufor do wypisania

	MOV AH,09H		; wypisz
	INT 21H			; na ekran		
				;

	
 				;	
	MOV AH,4CH		; wyjscie do DOS
	MOV AL,00H		; errorlevel=0
	INT 21H			; wywolanie


	
wypiszDL:			; procedura wypisze pare liczb BCD spakowanych z DL
MOV CL,4			; 
AND DX,00FFh			; maskuje starsze bity 0-7
SHL DX,CL			;
SHR DL,CL			; rozpakowuje DX
ADD DX,3030h			; dodaje 3030 dla ascii
PUSH DX				; DX na stos eby kto nie popsul
XCHG DL,DH			; najpierw starszy znak
; MOV AH,02			;
; INT 21H			; wypisuje
MOV [DS:SI],DL			;	
INC SI				; nastepna komorka pamieci
POP DX				; DX ze stosu - mlodszy znak
wypisz:				;     - czesc kodu uzyta ponownie
; MOV AH,02			; funkcja 02
; INT 21H			; wypisuje mlodszy
MOV [DS:SI],DL			;
INC SI				;
				;
ret				; wracamy



	
MyCode ENDS			; koniec segmentu 
END Start 			; od Start zaczyna sie program



