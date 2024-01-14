MyStack SEGMENT STACK           ; -- segment SS Stos *STACK* powoduje przypisanie do SS
	DB 64 DUP ('STACK!!!')  ;    rezerwacja danych
MyStack ENDS  			; -- koniec segmentu



MyData SEGMENT			; -- segment DS data

   strPodajA DB 0AH,0DH,"Podaj skadnik a:",'$'
   strPodajB DB 0AH,0DH,"podaj skadnik b:",'$'
   strWynik  DB 0AH,0DH,"Stein NWD: ";
   strZero   DB "0000";
   strEnd    DB '$';
	
MyData ENDS  			;


MyCode SEGMENT			; -- segment CS - kod

assume CS:MyCode		; przypisanie rejestrow segmentowych
assume DS:MyData		;

Start:				; rozpoczecie programu
MOV AX,MyData			; trzeba drugi raz zaladowac DS inaczej cos nie bardzo dziala
PUSH AX				; rejestrow segmentowych nie mozna ladowac wprost przez MOV
POP DS				;

				; ustawienie adresu poczatku ciagu do wyswietlenia
				; ds:dx - adres poczatku ciagu dla funkcji DOS
LEA DX,DS:strPodajA		;	
 call printDSDX			; printString(DS:DX)

	; check + MOV DL,05h
	; check + call print_DLasChar	;


call readKeysToBX		; call readBCD to AX				; info bx
MOV AX,BX			; w AX dana 1

LEA DX,DS:strPodajB		;	
 call printDSDX			; printString(DS:DX)

call readKeysToBX		; w BX dana 2

	XOR CX,CX 	;CX=0
int 1
; ----- S T A R T ----
; ( AX parity & BX parity ) ?
isAXandBXparity:	
  MOV DX,AX
  OR  DX,BX
  TEST DX,01
  JNZ AXandBXNotParity
  SHR AX,1	; AX=AX/2
  SHR BX,1	; BX=BX/2
  INC CX
  JMP isAXandBXparity	

AXandBXNotParity:
isAXequalsBX:
 
; AX=BX ? 
   CMP AX,BX
   JE AXequalsBX
	
   ; AX is parity ?
   isAXparity:
   TEST AX,01
   JNZ AXnotParity
   SHR AX,1	; a=a/2
   JMP isAXparity	

AXnotParity:
   

   ; BX is parity ?
   isBXparity:
   TEST BX,01
   JNZ BXnotParity
   SHR BX,1	; b=b/2
   JMP isBXparity	

BXnotParity:


   CMP AX,BX
   JE AXequalsBX
   JG aGb
   JNG bGa

aGb:
   SUB AX,BX	
   JMP isAXequalsBX

bGa:
   SUB BX,AX	
   JMP isAXequalsBX

; ----- END -----

AXequalsBX:
	    ; a = a*2^k = a*(1 SHR CX) = AX SHR CL
SHL AX,CL

call print_0xAXasChars		;
call int21_4C			; koniec 

; ---------------------------------------------

readKeysToBX:			; 
   PUSH AX				
   PUSH CX
   PUSH DX
   MOV CX,04h			; max 4 chars to read (3,2,1,0)
   XOR BX,BX			; oldFashion MOV BX,0	
     char_read:
        MOV AH,08H
        INT 21H			; read char(code) to AL
				;
	CMP AL,0DH		; Enter?
	JE charEnter		; Jump to exit 
	  			; enter=0DH
	    			; '0' = 30h
	   			; '1' = 31H
	   			; '9' = 39H
        SUB AL,030H		; AL-=30h
				; '0' = 0
				; '1' = 1
				; '9' = 9
				; '?' = >0Ah
        CMP AL,0AH		; AL< 0Ah?	
	JG char_read		; bad char, repeat read
				; good char, good value, print char
	MOV DL,AL		;
	call print_DLasChar 	; 
	SHL BX,01		; BX=BX*02h
        MOV DX,BX		; DX = 2*BX
	SHL DX,01		; DX = 4*BX
	SHL DX,01		; DX = 8*BX
	ADD BX,DX		; BX = 2*BX + (8*DX) = 10*BX

	ADD BL,AL		; BL=0; BX=BX+AL => BL=BL+AL
	LOOP char_read		;
	charEnter:
   POP DX
   POP CX			;
   POP AX			;
RET




print_0xAXasChars:
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX    
	LEA BX,DS:strEnd
	xG0:
	XOR DX,DX ; DX=0
	MOV CX,0Ah ; CX=000ah
	DIV CX     ; => AX = DX:AX / CX ; DX = DX:AX % CX ; DL = rest
	MOV CL,DL  ; 

	DEC BX	   	
	ADD DL,30h
	MOV [DS:BX],DL	
	CMP AX,0;
	JG xG0

	LEA DX,DS:strWynik
	call printDSDX

	POP DX
	POP CX
	POP BX
	POP AX
ret





print_DLasChar:
  PUSH AX    ; NO destroy AX value !
  PUSH DX    ;
  ADD DL,30h ; value->ASCIIcode
  MOV AH,02h ; function 02
  INT 21H    ; print Char(DL)
  POP DX     ;	
  POP AX     ;
ret


printDSDX:			; print string DS:DX
   PUSH AX				;
   MOV AH,09H			;
   INT 21H
   POP AX				;
RET				; ---


int21_4C:			; exit to dos
MOV AH,4CH			;
INT 21H				;	
	
MyCode ENDS			; koniec segmentu 
END Start 			; od Start zaczyna sie program


