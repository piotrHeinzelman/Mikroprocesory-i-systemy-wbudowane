MyStack SEGMENT STACK           ; -- segment SS Stos *STACK* powoduje przypisanie do SS
	DB 64 DUP ('STACK!!!')  ;    rezerwacja danych
MyStack ENDS  			; -- koniec segmentu



MyData SEGMENT			; -- segment DS data

myKeybBuff DB "1234\r\n + extra space for hackers extra characters;" 
myString  DB 0AH,0DH,0AH,0DH,"GREETING PROFESSOR FALKEN",0AH,0DH,0AH,0DH,"Enter first number A < 9999:",'$'
myString1 DB 0AH,0DH,"second number:",'$'
myString2 DB 0AH,0DH,"NWD: ",'$';

one DD 0000h;
two DD 0000h;
	
MyData ENDS  			;


				; -- segment CS - kod

MyCode SEGMENT

assume CS:MyCode		; przypisanie rejestrow segmentowych
assume DS:MyData		;

Start:				; rozpoczecie programu
MOV AX,MyData			; trzeba drugi raz zaladowac DS inaczej cos nie bardzo dziala
PUSH AX				; rejestrow segmentowych nie mozna ladowac wprost przez MOV
POP DS				;
				; ustawienie adresu poczatku ciagu do wyswietlenia
				; ds:dx - adres poczatku ciagu dla funkcji DOS
LEA DX,DS:myString		;	

 call printDSDX			; printString(DS:DX)
 call readBCDToAX		; call readBCD to AX
XCHG AX,BX			; first Number BCD to BX

LEA DX,DS:myString1		; 
 call printDSDX			;
 call readBCDToAX		; call readBCD to AX
 call unpackAX_BXtoDXAX_BXCX	; unpack BCD
; call packDXAX_BXCXtoAX_BX	; pack BCD

isAXequalsBX:
 ; A = BX, B=AX
 ; A=B ? -> NWD=a
 CMP DX,BX			; DX=BX ? 
 JNE noEquals			; DX<>BX -> noEquals
 CMP AX,CX
 JE printAXasBCDandExit		;   -> NWD=AX, print NWD, exit		

 noEquals:
 CMP DX,BX
 JL changeDXAX_BXCX            ; DX<BX = goto Change
 CMP AX,CX
 JL changeDXAX_BXCX            ; AX<CX = goto Change

 DXAXminusBXCX:		       ;
 nop
 nop
 SUB AL,CL 		       ; > DH:DL:AH:AL - CL			
 AAS			       ; Adjust AL	
 call rotate
 AAS
 call rotate
 AAS
 call rotate
 AAS
 call rotate
 call rotate
 nop
 nop
 nop

 


 SUB AL,CL 		       ; AL.DH:DL:AH - CH		
 AAS
 			       ; 	
 call rotate 	               ; rotate -> AH.AL:DH:DL
 
 AAS
 PUSH DX		       ;
 XOR DX,DX		       ; > 00.00:DH:DL - BL		
 SUB AL,CL		       ;
 AAS 
                           ;
 call rotate		       ; DL.00:00:DH - BH
 
 AAS
 SUB AL,CL		       ; 	
 
 AAS			       ; Adjust
 call rotate		       ; DH:DL 00:00							
 
 POP AX			       ; DH:DL:AH:AL	 

 call printAXasBCDandExit	; 

	
JMP isAXequalsBX		; JuMP to DX:AX=BX:CX test 



 changeDXAX_BXCX:
 XCHG DX,BX;
 XCHG AX,CX;
 JMP DXAXminusBXCX


 printAXasBCDandExit:
 call packDXAX_BXCXtoAX_BX      ;   


LEA DX,DS:myString2		; mov DX DS:Offset(myString1)
 call printDSDX			; print "NWD:"
 call printAXasBCD		; call print AX as BCD 
 call int21_4C			; koniec 

; ---------------------------------------------

rotate:	   ; AL->DH->DL->AH->AL
XCHG AL,DH ; AL:DL:AH:DH
XCHG AL,AH ; AL:DL:DH:AH
XCHG DL,AH ; AL:DH:DL:AH

	   ; BH:BL:CH:CL	
XCHG CL,BH ; CL:BL:CH:BH
XCHG CL,CH ; CL:BL:BH:CH
XCHG BL,CH ; CL:BH:BL:CH

RET




printDSDX:			; print string DS:DX
   PUSH AX				;
   MOV AH,09H			;
   INT 21H
   POP AX				;
RET				; ---


printAXasBCD:			;
   PUSH AX	
   PUSH CX
   PUSH DX			; SAVE CX - i	
   MOV  CL,04H			; CX=4
   XCHG DX,AX			; Number in DX   
   XCHG DH,DL			; 
   call print_DLasBCD		; print 1,2 char
   XCHG DH,DL
   call print_DLasBCD		; print 3,4 char (DL)
   POP DX			; refresh DX
   POP CX			; refresh CX	
   POP AX			; refresh AX
RET

print_DLasBCD:
   PUSH AX
   PUSH CX
   PUSH DX	
   XOR DH,DH			; DH=0
   ROR DX,1			; DX ....|hhll -> ll..|..hh
   ROR DX,1	
   ROR DX,1	
   ROR DX,1
   SHR DH,1			; DX ..ll|..hh
   SHR DH,1
   SHR DH,1
   SHR DH,1  			; DH L value DL H value 
   ADD DX,3030H			; Convert to CharCode 
   PUSH DX			;	
   MOV AH,02H			; AH 02
   INT 21H		 	; printChar(DL)	HcharCode
   POP DX			;
   XCHG DH,DL			;
   INT 21H			; printChar(DL) LcharCode	
			
   POP DX			; refresh AX,CX,DX
   POP CX
   POP AX
RET


print_ALasBCD:
  PUSH AX    ; NO destroy AX value !
  PUSH DX    ;
  MOV DL,AL  ; DL=value
  ADD DL,30H ; DL=charCode
  MOV AH,02H ; function 02
  INT 21H    ; print Char(DL)
  POP DX     ;
  POP AX     ;
RET



readBCDtoAX:			; readChars(AL) // readLine(DS:DX)
				; ZONK int 08 read char
   PUSH BX
   XOR BX,BX			; oldFashion MOV BX,0	
     i21_0A_read:
        MOV AH,08H
        INT 21H			; read char(code) to AL
	CMP AL,0DH		; Enter?
	JE i21_0A_ret		; AL=0Dh = Enter
	    			; 0 = 30h
	   			; 1 = 31H
	   			; 9 = 39H
        SUB AL,030H		; AL-=30h
        CMP AL,0AH		; AL< 0Ah?	
        JNB i21_0A_read		; return

	SHL BX,1		;
	SHL BX,1		;	
	SHL BX,1		;
	SHL BX,1		; BX*=16 **** -> ***.
	ADD BL,AL		; BX+=AL ***. -> ***a			
	JMP i21_0A_read		; read next char	
     i21_0A_ret:
   PUSH BX			; 
   POP AX			; result -> AX	
   POP BX			; refresh BX
RET

unpackAX_BXtoDXAX_BXCX:		; unpack BCD
   XOR DX,DX 			; =0
   XOR CX,CX			; =0
   XCHG AH,DL   		; DL=AH, AH=0
   XCHG BL,CL			; BL=CL, BL=0
   XCHG BL,BH			; BL=BH, BH=0
				; A dx   ax   b bx   cx
				; 00hh 00ll   00hh 00ll

SHL AX,1
SHL AX,1
SHL AX,1
SHL AX,1	
SHR AL,1
SHR AL,1
SHR AL,1
SHR AL,1	
SHL BX,1
SHL BX,1
SHL BX,1
SHL BX,1	
SHR BL,1
SHR BL,1
SHR BL,1
SHR BL,1	
SHL CX,1
SHL CX,1
SHL CX,1
SHL CX,1	
SHR CL,1
SHR CL,1
SHR CL,1
SHR CL,1	
SHL DX,1
SHL DX,1
SHL DX,1
SHL DX,1	
SHR DL,1
SHR DL,1
SHR DL,1
SHR DL,1		
RET

packDXAX_BXCXtoAX_BX:	; pack BCD
		;    dx         ax
		; ..HH|..hh  ..LL|..ll
		;	
		;    bx         cx
		; ..HH|..hh  ..LL|..ll
SHL CL,1
SHL CL,1
SHL CL,1
SHL CL,1	;       cx -> ..LL|ll..	
SHL CX,1	
SHL CX,1	
SHL CX,1	;     bx       cx
SHL CX,1	; ..HH|..hh   LLll|....
MOV CL,04h	
SHL BL,CL       ; bx->  ..HH|hh..
SHL BX,CL	; bx -> HHhh|....
XCHG BL,CH	; bx -> HHhh|LLll

SHL DL,CL	
SHL DX,CL	; dx -> HHhh|....
SHL AL,CL
SHR AX,CL	; ax -> ....|LLll
XCHG AH,DH      ; ax -> HHhh|LLll

RET




int21_4C:			; exit to dos
MOV AH,4CH			;
INT 21H				;	
	
MyCode ENDS			; koniec segmentu 
END Start 			; od Start zaczyna sie program


