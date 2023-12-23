MyStack SEGMENT STACK           	; slowo STACK powoduje zaladowanie do SS przez DOS
	DB 64 DUP ('STACK!!!')  	; rezerwacja 512 bajtow
MyStack ENDS  				; -- koniec segmentu Stack



MyData SEGMENT				; poczatek segmentu danych DS zwanego MyData

myName DB 0ah,0dh,0ah,0dh,"Piotr Heinzelman",0AH,0DH,'$'; definicja imienia i nazwiska na koncu terminator $
myStudy DB "Wydz. Elektryczny, kierunek ", 22H ,"Informatyka Stosowana", 22h, 0AH, 0DH,'$'

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
	LEA DX,DS:MyStudy	;
	INT 21H			; ponowne wywolanie wyswietlania ciagow
				;
 				;
	MOV AH,4CH		; wyjscie do DOS
	MOV AL,00H		; errorlevel=0
	INT 21H			; wywolanie


	
	
MyCode ENDS			; koniec segmentu 
END Start 			; od Start zaczyna sie program

				;
printOneChar:			
	