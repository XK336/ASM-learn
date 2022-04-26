assume cs:code,ds:data,ss:stack

data segment
strTABLE	dw	STRING,STRING1,STRING2
STRING		db	'A) please press "F1" key if you want to start game',0
STRING1		db	'B) press "ESC" key to exit game',0
STRING2		db	'C) press "F5" key to restart game',0

IMAGECOR_TABLE		dw	IMAGECOR,IMAGE90COR,IMAGE180COR,IMAGE270COR
	
IMAGECOR		dw	dot1,dot2,dot3,dot4,dot5,dot6,dot7,dot8
dot1			db	5,10			;dh,dl
dot2			db	5,11
dot3			db	6,10
dot4			db	6,11
dot5			db	6,12
dot6			db	6,13
dot7			db	6,14
dot8			db	6,15

IMAGE90COR		dw	dot1_90,dot2_90,dot3_90,dot4_90,dot5_90,dot6_90,dot7_90,dot8_90
dot1_90			db	6,12
dot2_90			db	6,13
dot3_90			db	6,10
dot4_90			db	6,11
dot5_90			db	7,10
dot6_90			db	7,11
dot7_90			db	8,10
dot8_90			db	8,11

IMAGE180COR		dw	dot1_180,dot2_180,dot3_180,dot4_180,dot5_180,dot6_180,dot7_180,dot8_180
dot1_180		db	7,10
dot2_180		db	7,11
dot3_180		db	6,10
dot4_180		db	6,11
dot5_180		db	6,9
dot6_180		db	6,8
dot7_180		db	6,7
dot8_180		db	6,6

IMAGE270COR		dw	dot1_270,dot2_270,dot3_270,dot4_270,dot5_270,dot6_270,dot7_270,dot8_270
dot1_270		db	6,8
dot2_270		db	6,9
dot3_270		db	6,10
dot4_270		db	6,11
dot5_270		db	5,10
dot6_270		db	5,11
dot7_270		db	4,10
dot8_270		db	4,11

VALUE_BX		db	0,2,4,6					;si��ֵ����Ӧ��һ���е�IMAGECOR
copyed_table_ip		dw	7E00H,7E10H,7E20H,7E30H

PORTADDR		db	9,8,7,4,2,0			;CMOSʱ��˿ں�������ʱ����
			
data ends

stack segment stack
	db	128 dup(0)
stack ends

code segment 
		mov bx,stack
		mov ss,bx
		mov sp,128

start:		call clear_screen
		call show_interface
		call start_button
		call copyed_table
		call show_image
		call put_time
		call auto_movedownctrlbutton	

gameEND:	mov ax,4C00H
		int 21H


;===================================================
clear_screen:	mov bx,0B800H
		mov es,bx
		
		mov bx,700H
		mov di,0

		mov cx,2000
clearScreen:	mov es:[di],bx
		add di,2
		loop clearScreen
		ret
;===================================================
show_interface:	push si
		push bx
		push es
		push di
		push ax
		push bx
		push ds

		mov si,0
	
		mov bx,0B800H
		mov es,bx
		mov di,1*160+8*2

		mov bx,data
		mov ds,bx

shownextSTR:	mov bx,strTABLE[si]
showSTR:	mov al,ds:[bx]
		cmp al,0
		je nextSTR
		mov byte ptr es:[di],al
		mov byte ptr es:[di+1],0BH
		add di,2
		inc bx
		jmp showSTR

nextSTR:	add si,2
		cmp si,2
		ja showTHEOTHERSTR
		mov di,2*160+8*2
		jmp shownextSTR

showTHEOTHERSTR:cmp si,4
		ja showSTRRET
		mov di,3*160+8*2
		jmp shownextSTR

showSTRRET:	pop ds
		pop bx
		pop ax
		pop di
		pop es
		pop bx
		pop si
		ret
;===================================================
start_button:	push ax
conPress:	in al,60H
		cmp al,3BH			;3Bh=F1
		je showINSTRUCTION
		
		cmp al,01H			;01h=ESC
		je gameEND
		
		jmp conPress		
STARTGAME:	pop ax
		ret
;---------------------------------------------------
showINSTRUCTION: jmp near ptr showINSTR

DIRECMARK	dw	left,rgiht,down,rotate
left		db	'press "s" or "S" <- move left',0
rgiht		db	'press "f" or "F" -> move right',0
down		db	'press "c" or "C" to move down',0
rotate		db	'press "ENTER" key to rotate block',0

showINSTR:	call show_instruction	
		jmp STARTGAME
;===================================================
show_instruction:
		push si
		push bx
		push es
		push di
		push ax
		push bx
		push cx

		mov si,0
	
		mov bx,0B800H
		mov es,bx
		mov di,8*160+42*2

		mov cx,4
shownextDIR:	mov bx,DIRECMARK[si]
		push di
showDIR:	mov al,cs:[bx]
		cmp al,0
		je nextDIR

		mov byte ptr es:[di],al
		add di,2
		inc bx
		jmp showDIR

nextDIR:	pop di
		add si,2
		add di,160	
		loop shownextDIR

		pop cx
		pop bx
		pop ax
		pop di
		pop es
		pop bx
		pop si

		ret

;==================================================
get_timer:	push bx
		push es
		;push dx
		push di
		push cx
		push ax

		mov bx,0
		mov es,bx

		;mov dx,0			
		mov bx,0			;BX����ʱ���ǣ���bx=0��˵��ʱ��û�䣬�����䣻��bx=1��˵��ʱ���Ѹı䣬�����䡣���������DX��ֵҲ����ʵ��

		mov di,0
		mov cx,6
CMPTIME:	mov al,es:[di+7F20H]		;ͼ��������ʱ��
		mov ah,es:[di+7F28H]		;��Ϸʵʱʱ��
		cmp al,ah
		jne addTIMER
		mov bx,0
		inc di
		loop CMPTIME

storetime:	;mov word ptr es:[7F38H],dx	;0:7F38H�洢����������λ/��
		mov word ptr es:[7F30H],bx	;�洢ʱ���ǣ�1/0��1��ʾʱ���б仯��0��ʾʱ��û�仯
	
		
		pop ax
		pop cx
		pop di
		;pop dx
		pop es
		pop bx
		ret
;---------------------------------------------------
addTIMER:	;inc dx		
		mov bx,1
		jmp storetime
;===================================================
put_time:	push bx
		push ds
		push es
		push si
		push di
		push cx
		push ax

		mov bx,data
		mov ds,bx
		mov bx,0
		mov es,bx

		mov si,0	
		mov di,7F20H			;0:7F20H�����ʾͼ�κ��ʱ�䣬Ҳ������Ϸ��ʼ��ʱ��

		mov cx,6

putTime:	mov ax,0
		mov al,PORTADDR[si]
		out 70H,al			;70H:CMOS RAM��ַ�˿ں�
		in al,71H			;71H:CMOS RAM���ݶ˿ں�
	
		mov byte ptr es:[di],al
		inc di 
		inc si
		
		loop putTime
		
		pop ax
		pop cx
		pop di
		pop si
		pop es
		pop ds
		pop bx

		ret
;===================================================
give_timeback:	push bx
		push es
		push di
		push ax
		push cx

		mov bx,0
		mov es,bx
		mov di,0

		mov cx,6
giveTIMEBACK:	mov al,es:[di+7F28H]
		mov byte ptr es:[di+7F20H],al
		inc di
		loop giveTIMEBACK
	
		pop cx
		pop ax
		pop di
		pop es
		pop bx
		ret	
;===================================================;ͨ������si��ֵ��������ת
ROTATE_MORE90:	call clear_image
		inc si
		cmp si,3
		ja RECOVERIMAGE
		call get_changedCOR
		call get_newCOR
		call check_rotate
		call show_image
		jmp real_time
;---------------------------------------------------
RECOVERIMAGE:	call get_changedCOR
		mov si,0
		call get_newCOR
		call check_rotate
		call show_image
		jmp real_time
;===================================================;ͨ������DH��ֵ���������ƺ�����
MOVEDOWN:	call clear_image		
		call check_down
		call show_down
		jmp real_time
;---------------------------------------------------;ͨ���ı�DL��ֵ�����������ƶ�
MOVERIGHT:	call clear_image
		call check_right
		call show_right
		jmp real_time
;---------------------------------------------------
MOVELEFT:	call clear_image
		call check_left
		call show_left
		jmp real_time
;===================================================
RESTARTgame:	call clear_image
		call copyed_table
		call show_image
		jmp real_time
;===================================================
ROTATEMORE:	jmp ROTATE_MORE90
;===================================================
auto_movedownctrlbutton:	
		push bx
		push ds
		push es
		push di
		push cx
		push ax
		push dx

		mov bx,data
		mov ds,bx
		mov bx,0
		mov es,bx

		mov dx,0

real_time:	push si
		mov si,0	
		mov di,7F28H			;0:7F28H���ʵʱ��ʱ��

		mov cx,6

putrealTime:	mov ax,0
		mov al,PORTADDR[si]
		out 70H,al			;70H:CMOS RAM��ַ�˿ں�
		in al,71H			;71H:CMOS RAM���ݶ˿ں�

		mov byte ptr es:[di],al
		inc di
		inc si		
		loop putrealTime
		
		call get_timer
		call give_timeback
		pop si
	
		mov bx,es:[7F30H]
		cmp bx,0			;when es:[7F30H] is not 0, it means time passed 1 sec, then block move done
		jne MOVEDOWN
;----------------------------
CHECKBUTTON:	mov al,0
		in al,60H

		cmp al,1CH
		je COUNTER
		cmp al,21H
		je COUNTER1
		cmp al,1FH
		je COUNTER2
		cmp al,2EH 
		je COUNTER3
		cmp al,01H	;01h=ESC
		je Endgame
		cmp al,3FH	;3Fh=F5
		je RESTARTgame

		mov dx,0
;-----------------------------								
		jmp real_time
Endgame:	pop dx
		pop ax
		pop cx
		pop di
		pop es
		pop ds
		pop bx

		ret				
;====================================================
CHECKBUTTON1:	jmp CHECKBUTTON			
			
;====================================================
COUNTER:	cmp dx,0
		je ADDDX
		jne CHECKBUTTON1

ADDDX:		mov dx,1
		jmp ROTATEMORE
;====================================================
COUNTER1:	cmp dx,0
		je ADDDX1
		jne CHECKBUTTON1

ADDDX1:		mov dx,1
		jmp MOVERIGHT
;====================================================
COUNTER2:	cmp dx,0
		je ADDDX2
		jne CHECKBUTTON1

ADDDX2:		mov dx,1
		jmp MOVELEFT
;====================================================
COUNTER3:	cmp dx,0
		je ADDDX3
		jne CHECKBUTTON1

ADDDX3:		mov dx,1
		jmp MOVEDOWN
;====================================================
;====================================================
check_rotate:	push ds					;���߽���ת�Ƿ����
		push es
		push di
		push bx
		push cx

		mov ax,data
		mov ds,ax
		mov ax,0
		mov es,ax

		push si
					
		add si,si
		mov di,copyed_table_ip[si]		;es:di=0:7E00
		mov bx,0

		mov cx,8
checkrotate:	mov dh,es:[di]
		mov dl,es:[di+1]

		cmp dl,1
		jb RECO_wrongRO
		cmp dl,39
		ja RECO_wrongRO
		cmp dh,23
		ja RECO_wrongRO

cmpbxrotate:	add di,2
		loop checkrotate
		
		pop si
		cmp bx,0
		ja RECOVER_ro

finishCHECKro:	pop cx
		pop bx
		pop di
		pop es
		pop ds
		ret
;---------------------------------------------------
RECO_wrongRO:	inc bx
		jmp cmpbxrotate
;---------------------------------------------------
RECOVER_ro:	cmp si,0
		je skipto3

		dec si
		jmp finishCHECKro	 
;---------------------------------------------------
skipto3:	mov si,3
		jmp finishCHECKro
			
;===================================================
get_newCOR:	push ds
		push es
		push si
		push di
		push bx
		push cx

		mov ax,data
		mov ds,ax
		mov ax,0
		mov es,ax
	
		mov bh,0
		mov bl,VALUE_BX[si]
					
		add si,si
		mov di,copyed_table_ip[si]		;es:di=0:7E00
					
		mov si,IMAGECOR_TABLE[bx]		;ds:si=dot

		mov bx,7F10H

		mov cx,8				;ds:bx + es:bx=>es:di
getNEWCOR:	push bx
		mov bx,ds:[si]
		mov ah,ds:[bx]
		mov al,ds:[bx+1]			;es:bx=>0:7F10H
		add si,2
		pop bx
		mov dh,es:[bx]
		mov dl,es:[bx+1]			;dl=�е�λ��ֵ
		add bx,2
		
		add dh,ah
		add dl,al

		mov byte ptr es:[di],dh
		mov byte ptr es:[di+1],dl
		add di,2		
		loop getNEWCOR

		pop cx
		pop bx
		pop di
		pop si
		pop es
		pop ds
		ret
	
;===================================================
get_changedCOR:	push si
		push di
		push ds
		push es
		push cx
		push bx

		dec si					;ͨ��ah,al����λ�ƣ��Ӷ��õ��µ�dh,dl
		mov ax,data
		mov ds,ax
		mov ax,0
		mov es,ax
	
		mov bh,0
		mov bl,VALUE_BX[si]

		add si,si
		mov di,copyed_table_ip[si]		;es:di=0:7E00
					
		mov si,IMAGECOR_TABLE[bx]		;ds:si=dot1

		mov bx,7F10H				;es:bx=0:7F10H ���λ��DH,DL

		mov cx,8
getCHANGEDCOR:	push bx
		mov bx,ds:[si]
		mov dh,ds:[bx]
		mov dl,ds:[bx+1]
		mov ah,es:[di]
		mov al,es:[di+1]
		
		sub ah,dh				;�õ�λ��ֵah=λ��dh
		sub al,dl				; al=λ��dl

		add di,2
		add si,2
	
		pop bx
		mov byte ptr es:[bx],ah				;��λ�ƴ����0:7F10H
		mov byte ptr es:[bx+1],al
		add bx,2
		loop getCHANGEDCOR

		pop bx
		pop cx
		pop es
		pop ds
		pop di
		pop si
		ret
;===================================================
clear_image:	push ds
		push si
		push cx
		
		mov ax,data
		mov ds,ax
		add si,si
		mov si,copyed_table_ip[si]			;ds:si=0:7E00H

		mov ax,0
		mov ds,ax

		mov cx,8
clearIMAGE:	mov dh,ds:[si]
		mov dl,ds:[si+1]
		call show_blank
		add si,2
		loop clearIMAGE
		
		pop cx
		pop si
		pop ds
		ret
;===================================================
check_left:	push ds
		push si
		push cx
		push bx

		mov ax,data
		mov ds,ax
		add si,si
		mov si,copyed_table_ip[si]			;ds:si=0:7E00H
		push si

		mov ax,0					
		mov ds,ax
		mov bx,0

		mov cx,8
checkleft:	mov dh,ds:[si]
		cmp dh,4					;DH=4 �ϱ߽磬���С��4������Ϸ����
		jb ENDgame1
		
		mov dl,ds:[si+1]
		cmp dl,2					;DL=2 ��߽�
		je skipmoveleft

cmpbxleft:	add si,2
		loop checkleft

		pop si
		cmp bx,0
		ja setlimitleft

setleft:	pop bx
		pop cx
		pop si
		pop ds
		
		ret
;===================================================
skipmoveleft:	inc bx
		jmp cmpbxleft

setlimitleft:	mov cx,8
set_LEFT:	mov dl,ds:[si+1]
		inc dl
		mov byte ptr ds:[si+1],dl
		add si,2
		loop set_LEFT
		jmp setleft
;---------------------------------------------------
skipmoveright:	inc bx
		jmp cmpbxright

setlimitright:	mov cx,8
set_RIGHT:	mov dl,ds:[si+1]
		dec dl
		mov byte ptr ds:[si+1],dl
		add si,2
		loop set_RIGHT
		jmp setright

;;==================================================
ENDgame1:	jmp ENDgame
;---------------------------------------------------
check_right:	push ds
		push si
		push cx
		push bx

		mov ax,data
		mov ds,ax
		add si,si
		mov si,copyed_table_ip[si]			;ds:si=0:7E00H
		push si

		mov ax,0					
		mov ds,ax
		mov bx,0

		mov cx,8
checkright:	mov dh,ds:[si]
		cmp dh,4					;DH=4 �ϱ߽磬���С��4������Ϸ����
		jb ENDgame1
		
		mov dl,ds:[si+1]
		cmp dl,38					;DL=39 �ұ߽�
		je skipmoveright

cmpbxright:	add si,2
		loop checkright

		pop si
		cmp bx,0
		ja setlimitright

setright:	pop bx
		pop cx
		pop si
		pop ds
		
		ret
;---------------------------------------------------
skipmovedown:	inc bx
		jmp cmpbxdown

setlimitdown:	mov cx,8
set_DOWN:	mov dh,ds:[si]
		dec dh
		mov byte ptr ds:[si],dh
		add si,2
		loop set_DOWN
		jmp setdown
;---------------------------------------------------
check_down:	push ds
		push si
		push cx
		push bx

		mov ax,data
		mov ds,ax
		add si,si
		mov si,copyed_table_ip[si]			;ds:si=0:7E00H
		push si

		mov ax,0					
		mov ds,ax
		mov bx,0

		mov cx,8
checkdown:	mov dh,ds:[si]
		cmp dh,4					;DH=4 �ϱ߽磬���С��4������Ϸ����
		jb ENDgame1

		cmp dh,22					;DH=23 �±߽磬�������ü�ʱ������DH=25��ʱ�䳬�����룬��ֹͣ���ƣ�ת������һ��ͼ�ν��п���
		je skipmovedown
		
cmpbxdown:	add si,2
		loop checkdown
		
		pop si
		cmp bx,0
		ja setlimitdown

setdown:	pop bx
		pop cx
		pop si
		pop ds
		
		ret
;===================================================
show_left:	push ds
		push si
		push cx

		mov ax,data
		mov ds,ax
		add si,si
		mov si,copyed_table_ip[si]			;ds:si=0:7E00H

		mov ax,0					
		mov ds,ax					

		mov cx,8
showLEFT:	;mov dh,ds:[si]
		mov dl,ds:[si+1]	
		dec dl 
		mov byte ptr ds:[si+1],dl
		add si,2
		loop showLEFT

		pop cx
		pop si
		pop ds
		call show_image

		ret
;===================================================
show_right:	push ds
		push si
		push cx

		mov ax,data
		mov ds,ax
		add si,si
		mov si,copyed_table_ip[si]			;ds:bx=0:7E00H

		mov ax,0
		mov ds,ax

		mov cx,8
showRIGHT:	;mov dh,ds:[si]
		mov dl,ds:[si+1]
		inc dl
		mov byte ptr ds:[si+1],dl
		add si,2
		loop showRIGHT
		
		pop cx
		pop si
		pop ds
		call show_image

		ret
	
;===================================================
show_down:	push ds
		push si
		push cx

		mov ax,data
		mov ds,ax
		add si,si
		mov si,copyed_table_ip[si]			;ds:bx=0:7E00H

		mov ax,0
		mov ds,ax

		mov cx,8
showDOWN:	mov dh,ds:[si]
		inc dh
		mov byte ptr ds:[si],dh
		;mov dl,ds:[si+1]
		add si,2
		loop showDOWN
		
		pop cx
		pop si
		pop ds
		call show_image

		ret
;===================================================
show_image:	push ds
		push si
		push cx
		push bx

		mov ax,data
		mov ds,ax
		add si,si					;ͨ��si����Ҫ��ʾ��ͼ�Σ�0��2��4��6��
		mov si,copyed_table_ip[si]			;ds:bx=0:7E00H

		mov ax,0
		mov ds,ax

		mov cx,8
showIMAGE:	mov dh,ds:[si]
		mov dl,ds:[si+1]
		call show_screen
		add si,2
		loop showIMAGE
		
		pop bx
		pop cx
		pop si
		pop ds
		ret
;===================================================
copyed_table:					;�����di=7E00H
		mov ax,data			;ds:[si]=>ip of dot
		mov ds,ax		
		mov ax,0
		mov es,ax			;es:[di]=>0:7E00H
		
		mov si,0
		push si

		mov bh,0
		mov bl,VALUE_BX[si]		;ͨ������si��ֵ����ת90��Ҳͬʱ����7E00H�ȵĶε�ַ
		
		add si,si
		mov di,copyed_table_ip[si]	;�õ���ȫ�ڴ�Ķε�ַIP��7E00H/7E10H
		
		mov si,IMAGECOR_TABLE[bx]	
														
		mov cx,8
copyTable:	mov bx,ds:[si]			;bx=ds:[TABLECORE�ε�ַ��DOT1�Ķε�ַ]=0A05
		mov dh,ds:[bx]
		mov byte ptr es:[di],dh
		mov dl,ds:[bx+1]
		mov byte ptr es:[di+1],dl
		add si,2
		add di,2
		loop copyTable
		pop si
		ret
;===================================================
show_blank:	push es
		push bx

		mov ax,0B800H
		mov es,ax
						;��clear_image֮�䴫�ݲ���DH,DL
		mov ax,160
		mul dh				;ax=dh*160
		mov dh,0
		add dl,dl			;dl=dl*2
		adc dh,0
		add ax,dx
		mov di,ax			;�õ�DI
		
		mov bx,0
		mov word ptr es:[di],bx
	
		pop bx
		pop es
		ret
;===================================================
show_screen:	push es
		push bx

		mov ax,0B800H
		mov es,ax
				;��show_image֮�䴫�ݲ���DH,DL
		mov ax,160
		mul dh		;ax=dh*160
		mov dh,0
		add dl,dl	;dl=dl*2
		adc dh,0
		add ax,dx
		mov di,ax			;�õ�DI=bx
		
		mov bx,0C000H			;��ʾ��ɫͼ��
		mov word ptr es:[di],bx
		
		pop bx
		pop es
		ret
;===================================================

code ends

end start
