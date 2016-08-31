TITLE	lab04
; Programmer:	Marcus Ross
; Due:		14 Mar, 2014
; Description:	This program takes input from the user as a number of gallons of refuse which must be disposed. It compares the prices of services provided by the city and by a private company.

	.MODEL SMALL
	.386
	.STACK 64
;==========================
		.DATA
trash	DW	?			; gallons of trash
remCity	DB	?			; remainder; trash saved for next week for city service
remPriv	DB	?			; remainder; trash saved for next week for private service
prcBag1	DB	2			; price of bag 1
prcBag2	DB	3
prcBag3	DB	4
prcBag4	DB	5
prcBin	DW	30			; flat rate for private service
prcCity	DW	?			; total price for city service
prcPriv	DW	?			; total price for private service
capBag1	DB	13			; capacity in gallons of bag 1
capBag2	DB	24
capBag3	DB	40
capBag4	DB	50
capBin	DW	200			; capacity of refuse bin
capPriv	DW	300			; capacity accepted by private service
qtyBag1	DB	?			; quantity of bag 1
qtyBag2	DB	?
qtyBag3	DB	?
qtyBag4	DB	?
costBag1	DW	?
costBag2	DW	?
costBag3	DW	?
costBag4	DW	?
dollar	EQU	36			; ASCII
gap		DB	9, 9, 9		; ASCII
timesQty	DB	9, 'x', 36	; "\tx"
equals	DB	9, 61, 36		; "\t="
newLine	DB	10, 13, 36	; ASCII
prompt	DB	10, 'Gallons of trash (0 to exit): ', 36
head		DB	'Humorous Waste Management', 13, 10, 'The best in humorously named waste management', 13, 10, 10, 'City Service', 13, 10, '40gal Bags:', 9, 36
medBag	DB	'24gal Bags:', 9, 36
smBag	DB	'13gal Bags:', 9, 36
total	DB	'Total:', 9, 9, 9, 36
privHead	DB	10, 'Private Service', 13, 10, '50gal Bags:', 9, 36
privFlat	DB	'Flat rate:', 9, 9, 36
sign		DB	10, 'Sanitation engineer:', 9, '___________________', 13, 10, 9, 9, 9, 'Marcus Ross', 13, 10, 36
remaind	DB	"Remaining gallons: ", 36
;==========================
		.CODE
		EXTRN	GetDec : NEAR, PutDec : NEAR

Main		PROC	NEAR
		mov	ax, @data	; init data
		mov	ds, ax	; segment register

begin:	call	getTrash	; get amount of trash from user
		cmp	ax, 0	; check input
		jz	exit		; goto end if input = 0
		call	calcCity	; calc bag quantities for city service
		call	calcPriv	; calc bag quantities for private service
		call	calcCost	; calc costs via bag quantities
		call	dispRep	; display report
		jmp	begin	; loop

exit:	mov	ax, 4c00h	; return code 0
		int	21h
Main		ENDP
;==========================
getTrash	PROC	NEAR
		mov	dx, OFFSET prompt	; display prompt
		mov	ah, 09h
		int	21h
		call	GetDec			; get input
		mov	trash, ax			; store input
		ret
		ENDP
;==========================
calcCity	PROC	NEAR
		div	capBag3		; trash is in ax; find how many of largest bags required
		mov	qtyBag3, al	; quotient = bag qty
		mov	al, ah		; remainder = new dividend
		xor	ah, ah		; ax = al
		div	capBag2		; find how many medium bags needed
		mov	qtyBag2, al	; quotient = bag qty
		mov	al, ah		; remainder = new dividend
		xor	ah, ah		; ax = al
		div	capBag1		; find how many small bags needed
		mov	qtyBag1, al	; quotient = bag qty
		mov	remCity, ah	; remainder = trash saved for next week
		ret
		ENDP
;==========================
calcPriv	PROC	NEAR
		mov	ax, trash		; prep trash qty for operations
		cmp	ax, capPriv	; if ≥300 gal, can find remainder trash for now
		jb	lessTrash		; skip next steps if <300
		sub	ax, capPriv	; gals above 300 = gals for next week
		mov	remPriv, al
		mov	qtyBag4, 2	; with ≥300 gallons, always need 2 bags
		jmp	donePriv		; done calculating @ ≥300 gals
lessTrash:				; if ≤300, trash is still in ax
		cmp	ax, capBin	; compare qty to bin capacity
		ja	bag4			; if trash ≤ 200, no need for any bags
		mov	qtyBag4, 0
		jmp	donePriv		
bag4:	sub	ax, capBin	; 200 gal placed in the refuse bin unconditionally
		div	capBag4		; find how many 50 gal bags required
		mov	qtyBag4, al	; quotient = number of bags
		mov	remPriv, ah	; remainder = trash for next week
donePriv:	ret
		ENDP
;==========================
calcCost	PROC	NEAR
		mov	al, qtyBag1	; prep quantity of bags 1
		xor	ah, ah		; ax = al
		mul	prcBag1		; bag cost = quantity * price
		mov	costBag1, ax
		mov	al, qtyBag2	; prep quantity of bags 2
		xor	ah, ah		; ax = al
		mul	prcBag2		; bag cost = quantity * price
		mov	costBag2, ax
		mov	al, qtyBag3	; prep quantity of bags 3
		xor	ah, ah		; ax = al
		mul	prcBag3		; bag cost = quantity * price
		mov	costBag3, ax
		add	ax, costBag2	; costBag3 + costBag2
		add	ax, costBag1	; costBag3 + costBag2 + costBag1
		mov	prcCity, ax	; = total city price
		mov	al, qtyBag4	; prep quantity of bags 4
		xor	ah, ah		; ax = al
		mul	prcBag4		; bag cost = quantity * price
		mov	costBag4, ax	
		add	ax, prcBin	; flat rate + costBag4
		mov	prcPriv, ax	; = total private price
		ret
		ENDP
;==========================
dispRep	PROC	NEAR
		mov	dx, OFFSET head	; display city heading
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	al, 	prcBag3		; display large bag price
		xor	ah, ah			; ax = al
		call	PutDec
		mov	dx, OFFSET timesQty	; display tab, x
		mov	ah, 09h
		int	21h
		mov	al, qtyBag3		; display large bag qty
		xor	ah, ah			; ax = al
		call	PutDec
		mov	dx, OFFSET equals	; display tab, =
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	ax, costBag3		; display large bag cost
		call	PutDec
		mov	dx, OFFSET newLine	; display new line
		mov	ah, 09h
		int	21h

		mov	dx, OFFSET medBag	; display row heading
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	al, 	prcBag2		; display med bag price
		xor	ah, ah			; ax = al
		call	PutDec
		mov	dx, OFFSET timesQty	; display tab, x
		mov	ah, 09h
		int	21h
		mov	al, qtyBag2		; display med bag qty
		xor	ah, ah			; ax = al
		call	PutDec
		mov	dx, OFFSET equals	; display tab, =
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	ax, costBag2		; display med bag cost
		call	PutDec
		mov	dx, OFFSET newLine	; display new line
		mov	ah, 09h
		int	21h

		mov	dx, OFFSET smBag	; display row heading
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	al, 	prcBag1		; display small bag price
		xor	ah, ah			; ax = al
		call	PutDec
		mov	dx, OFFSET timesQty	; display tab, x
		mov	ah, 09h
		int	21h
		mov	al, qtyBag1		; display small bag qty
		xor	ah, ah			; ax = al
		call	PutDec
		mov	dx, OFFSET equals	; display tab, =
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	ax, costBag1		; display small bag cost
		call	PutDec
		mov	dx, OFFSET newLine	; display new line
		mov	ah, 09h
		int	21h

		mov	dx, OFFSET total	; display row heading
		mov	ah, 09h
		int	21h
		mov	dx, OFFSET equals	; display tab, =
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	ax, prcCity		; display total city price
		call	PutDec
		mov	dx, OFFSET newLine	; display new line
		mov	ah, 09h
		int	21h

		mov	dx, OFFSET remaind	; display row heading
		mov	ah, 09h
		int	21h
		mov	al, remCity		; display total private price
		xor	ah, ah			; ax = al
		call	PutDec
		mov	dx, OFFSET newLine	; display new line
		mov	ah, 09h
		int	21h

		mov	dx, OFFSET privHead	; display private heading
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	al, 	prcBag4		; display bag price
		xor	ah, ah			; ax = al
		call	PutDec
		mov	dx, OFFSET timesQty	; display tab, x
		mov	ah, 09h
		int	21h
		mov	al, qtyBag4		; display bag qty
		xor	ah, ah			; ax = al
		call	PutDec
		mov	dx, OFFSET equals	; display tab, =
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	ax, costBag4		; display bag cost
		call	PutDec
		mov	dx, OFFSET newLine	; display new line
		mov	ah, 09h
		int	21h

		mov	dx, OFFSET privFlat	; display row heading
		mov	ah, 09h
		int	21h
		mov	dx, OFFSET equals	; display tab, =
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	ax, prcBin		; display private flat rate
		call	PutDec
		mov	dx, OFFSET newLine	; display new line
		mov	ah, 09h
		int	21h

		mov	dx, OFFSET total	; display row heading
		mov	ah, 09h
		int	21h
		mov	dx, OFFSET equals	; display tab, =
		mov	ah, 09h
		int	21h
		mov	dl, dollar		; display $ char
		mov	ah, 02h
		int	21h
		mov	ax, prcPriv		; display total private price
		call	PutDec
		mov	dx, OFFSET newLine	; display new line
		mov	ah, 09h
		int	21h

		mov	dx, OFFSET remaind	; display row heading
		mov	ah, 09h
		int	21h
		mov	al, remPriv		; display total private price
		xor	ah, ah			; ax = al
		call	PutDec
		mov	dx, OFFSET newLine	; display new line
		mov	ah, 09h
		int	21h

		mov	dx, OFFSET sign	; display signature line
		mov	ah, 09h
		int 21h
		ret	
		ENDP
;==========================
	END	Main