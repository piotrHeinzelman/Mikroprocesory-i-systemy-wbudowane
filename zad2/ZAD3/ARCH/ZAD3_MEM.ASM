MyStack SEGMENT STACK           ; -- segment SS Stos *STACK* powoduje przypisanie do SS
	DB 64 DUP ('STACK!!!')  ;    rezerwacja danych
MyStack ENDS  			; -- koniec segmentu



MyData SEGMENT			; -- segment DS data

myKeybBuff DB "1234\r\n + extra space for hackers extra characters;" 
myString  DB 0AH,0DH,0AH,0DH,"GREETING PROFESSOR FALKEN",0AH,0DH,0AH,0DH,"Enter first number A < 9999:",'$'
myString1 DB 0AH,0DH,"second number:",'$'
myString2 DB 0AH,0DH,"A: ",'$';
myString3 DB 0AH,0DH,"B: ",'$';


xxx DB "***abcd>",'$'
one DB "????",'$';
two DB "????",'$'
yyy DB "<defg***",'$'



	
MyData ENDS  			;


				; -- segment CS - kod

MyCode SEGMENT

assume CS:MyCode		; przypisanie rejestrow segmentowych
assume DS:MyData,ES:MyData	;

Start:				; rozpoczecie programu
MOV AX,MyData			; trzeba drugi raz zaladowac DS inaczej cos nie bardzo dziala
PUSH AX				; rejestrow segmentowych nie mozna ladowac wprost przez MOV
PUSH AX				;
POP DS				;
POP ES				;
				; ustawienie adresu poczatku ciagu do wyswietlenia
				; ds:dx - adres poczatku ciagu dla funkcji DOS
LEA DX,DS:myString		;	
call print			; print(DS:DX)

LEA SI,DS:one			;
call readToDSSI 		; read numbers to ONE

LEA DX,DS:myString1
call print

LEA SI,DS:two
call readToDSSI 		; read numbers to TWO 

call compare 			; compare ES:DI DS:SI
; JE exit ;)

call ifBaboveXCHG

call printInfo

JMP exit			; exit



exit:			; exit to dos
MOV AH,4CH			;
INT 21H				;	

; --------------------------------------

ifBaboveXCHG:
 PUSH AX
 PUSH CX

  MOV CX,04H
  LEA SI,ES:one
  LEA DI,DS:two

_bloop:
  MOV AL,[ES:SI] ; B
  MOV AH,[DS:DI] ; A
  INC SI
  INC DI
  CMP AH,AL 
  JG _bchange
  LOOP _bloop
  

_bnochange: 
 
 POP CX
 POP AX
RET

_bchange:
  MOV CX,04H
  LEA SI,ES:one
  LEA DI,DS:two
  _bchange2:
  MOV AL,[ES:SI] ; B
  MOV AH,[DS:DI] ; A
  MOV [ES:SI],AH ; B
  MOV [DS:DI],AL ; A
  INC SI
  INC DI
  LOOP _bchange2
  
JMP _bnochange



compare:
  PUSH AX
  PUSH CX
  MOV CX,04H
  LEA SI,ES:one
  LEA DI,DS:two

_cloop:
  MOV AL,[ES:SI]
  MOV AH,[DS:DI]
  INC SI
  INC DI
  CMP AL,AH  
  LOOPZ _cloop
  
  POP CX
  POP AX
  
ret


printDSSIasBCD:
  PUSH AX
  PUSH CX

  MOV CX,04h

_ploop:
  MOV AL,[DS:SI]
  INC SI  
  call printChar
  LOOPNZ _ploop

  POP CX
  POP AX
ret


readToDSSI:
  PUSH AX		
  PUSH CX
  PUSH DX
  	
  MOV CX,04H ; loop i
 
   _readChar:
     MOV AH,08H
     INT 21H       ; read Key -> DL (0=30h 1=31h 9=39h
     CMP AL,0DH    ; <enter> ?
     JE _endRead   ; return
     SUB AL,030h   ; charCode -> hexValue (0=0,1=1,9=9

     CMP AL,0AH    ; value > 0A ? invalidKey
     JG _readChar  ; read next key 	

     MOV [DS:SI],AL; copy value to memory
     INC SI	   ; prev SI
	
     call printChar ; printChar
    LOOPNZ _readChar ; loop 3x
	
   _endRead:

  POP DX
  POP CX
  POP AX
ret


printChar: ; code in AL
 PUSH AX
 PUSH DX
 ADD AL,30h
 XCHG AL,DL
 MOV AH,02
 INT 21H
 POP DX
 POP AX
ret

print:
 PUSH AX
 MOV AX,0900h
 INT 21H
 POP AX
ret

printInfo:

LEA DX,DS:myString2
call print

LEA SI,DS:one
call printDSSIasBCD

LEA DX,DS:myString3
call print

LEA SI,DS:two
call printDSSIasBCD

ret

	
MyCode ENDS			; koniec segmentu 
END Start 			; od Start zaczyna sie program

