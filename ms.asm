IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	Clock equ es:6Ch

	array db 81 dup(0)
	bombs db 10 dup(81)
	flagCount db 10
	gameOver db 0

	xpos dw ?
	ypos dw ?

	rLength dw ?
	rHeight dw ?
	rectX dw ?

CODESEG
proc checkBombsPos
	push cx
	
	cmp al, 80
	jg endBombProc
	
	mov si, offset bombs
	xor ah, ah
	mov cx, 10

checkBombs:
	mov ah, [si]
	cmp al, ah
	je bombTaken
	
	cmp ah, 81
	je placeBomb
	
	inc si
	loop checkBombs
	
	jmp endBombProc
	
bombTaken:
	mov al, 81
	jmp endBombProc
	
placeBomb:
	mov [di], al

endBombProc:
	pop cx
	ret
endp checkBombsPos
proc arrayValues
	mov di, offset array
	mov cx, 81
	mov si, 1
	
arrValuing:
	mov bl, [di]
	cmp bl, 9 ; value = 9 ---> bomb
	jl arrValJMP1

	cmp si, 9
	jne arrIsOne
	
	; bomb at pos 9
	inc [array+7] ; 8
	inc [array+16] ; 17
	inc [array+17] ; 18
	jmp arrValJMP1
	
arrIsOne:
	cmp si, 1
	jne seventy3
	; bomb at pos 1
	inc [array+1] ; 2
	inc [array+9] ; 9
	inc [array+10] ; 10
	jmp arrValJMP1

seventy3:
	cmp si, 73
	jne eighty1
	; bomb at pos 73
	inc [array+63] ; 64
	inc [array+64] ; 65
	inc [array+73] ; 74
	jmp arrValJMP1

eighty1:
	cmp si, 81
	jne restOfArray
	; bomb at pos 81
	inc [array+70] ; 71
	inc [array+71] ; 72
	inc [array+79] ; 80

arrValJMP1:
	inc si
	inc di
	loop arrValuing
	jmp endArrLoop
	
restOfArray:
	mov ax, si
	mov bl, 9
	div bl
	
	cmp ah, 0 ; right column
	jne leftCol
	
	inc [byte ptr di - 1]
	inc [byte ptr di - 10]
	inc [byte ptr di + 8]
	inc [byte ptr di - 9]
	inc [byte ptr di + 9]
	jmp endArrLoop
	
leftCol:
	cmp ah, 1 ; left column
	jne topRow
	
	inc [byte ptr di + 1]
	inc [byte ptr di + 9]
	inc [byte ptr di - 9]
	inc [byte ptr di + 10]
	inc [byte ptr di - 8]
	jmp endArrLoop

topRow:
	inc [byte ptr di + 1]
	inc [byte ptr di - 1]
	
	cmp al, 0 ; top row
	jne bottomRow
	
	inc [byte ptr di + 9]
	inc [byte ptr di + 8]
	inc [byte ptr di + 10]
	jmp endArrLoop
	
arrValJMP2:
	jmp arrValJMP1
	
bottomRow:
	cmp al, 8 ; bottom row
	jne middleSqr
	
	inc [byte ptr di - 9]
	inc [byte ptr di - 8]
	inc [byte ptr di - 10]
	jmp endArrLoop
	
middleSqr:
	inc [byte ptr di - 8]
	inc [byte ptr di - 9]
	inc [byte ptr di - 10]
	inc [byte ptr di + 8]
	inc [byte ptr di + 9]
	inc [byte ptr di + 10]


endArrLoop:
	cmp cx, 0
	jne arrValJMP2
	
	; every value that is above nine need to be reset
	mov di, offset array
	mov cx, 81

biggerThanNine:
	mov bl, [di]
	cmp bl, 9
	jle endNineCheckLoop
	
	mov bl, 9
	mov [di], bl
	
endNineCheckLoop:
	inc di
	loop biggerThanNine
	
	ret
endp arrayValues
proc DrawEmptyBoard
	; gray screen
	xor bx, bx
	xor cx, cx ; cx = 0 (x val)
	xor dx, dx ; dx = 0 (y val)
	mov al, 7 ; gray
	
GrayScreen:
	mov ah, 0ch
	int 10h
	
	inc dx
	cmp dx, 200
	jne GrayScreen
	
	xor dx, dx
	inc cx
	cmp cx, 320
	jne GrayScreen
	
	; dark gray lines
	mov al, 8 ; dark gray
	xor cx, cx ; cx = 0 (x val)
	mov dx, 19 ; dx = 19 (y val)
	
HorizontalLines:
	mov ah, 0ch
	int 10h
	
	inc cx
	cmp cx, 320
	jne HorizontalLines
	
	xor cx, cx
	add dx, 20
	cmp dx, 199
	jle HorizontalLines
	

	mov cx, 36 
	mov dx, 20 
	
VerticalLines:
	mov ah, 0ch
	int 10h
	
	inc dx
	cmp dx, 200
	jne VerticalLines
	
	mov dx, 20
	add cx, 35
	cmp cx, 300
	jl VerticalLines
	
	; drawing smile
	mov cx, 149
	mov dx, 7
	xor si, si
	xor di, di
	xor al, al ; black
	
DrawSmile1:
	mov ah, 0ch
	int 10h
	
	mov al, 44 ; yellow
	inc si
	inc cx
	cmp si, 17
	jl DrawSmile1
	
	xor al, al ; black
	mov ah, 0ch
	int 10h

	mov cx, 149
	inc dx
	inc di
	xor si, si
	cmp di, 6
	jl DrawSmile1
	
	mov cx, 155
	mov dx, 1
	xor si, si
	xor di, di
	xor al, al ; black
	
DrawSmile2:
	mov ah, 0ch
	int 10h

	mov al, 44 ; yellow
	inc si
	inc dx
	cmp si, 17
	jl DrawSmile2
	
	xor al, al ; black
	mov ah, 0ch
	int 10h
	
	mov dx, 1
	inc cx
	inc di
	xor si, si
	cmp di, 6
	jl DrawSmile2
	
	mov cx, 153
	mov dx, 2
	xor al, al ; black
	xor si, si
	xor di, di
	
DrawSmile3:
	mov ah, 0ch
	int 10h
	
	mov al, 44 ; yellow
	inc si
	inc dx
	cmp si, 15
	jl DrawSmile3
	
	xor al, al ; black
	mov ah, 0ch
	int 10h
	
	mov dx, 2
	inc cx
	inc di
	xor si, si
	cmp di, 2
	jl DrawSmile3
	
	mov cx, 161
	cmp di, 3
	jl DrawSmile3
	
	inc cx
	cmp di, 4
	jl DrawSmile3
	
	mov cx, 150
	mov dx, 5
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	mov dx, 13
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	mov cx, 165
	mov dx, 5
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	mov dx, 13
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	mov cx, 151
	mov dx, 4
	mov ah, 0ch
	int 10h
	inc cx
	dec dx
	mov ah, 0ch
	int 10h
	mov cx, 163
	mov ah, 0ch
	int 10h
	inc cx
	inc dx
	mov ah, 0ch
	int 10h
	mov dx, 15
	mov ah, 0ch
	int 10h
	inc dx
	dec cx
	mov ah, 0ch
	int 10h
	mov cx, 152
	mov ah, 0ch
	int 10h
	dec dx
	dec cx
	mov ah, 0ch
	int 10h
	
	mov al, 44 ; yellow
	dec dx
	mov ah, 0ch
	int 10h
	dec dx
	mov ah, 0ch
	int 10h
	inc cx
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	mov dx, 4
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	dec cx
	mov ah, 0ch
	int 10h
	dec dx
	mov ah, 0ch
	int 10h
	mov cx, 164
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	dec cx
	mov ah, 0ch
	int 10h
	dec dx
	mov ah, 0ch
	int 10h
	dec dx
	mov ah, 0ch
	int 10h
	mov dx, 15
	mov ah, 0ch
	int 10h
	dec dx
	mov ah, 0ch
	int 10h
	dec dx
	mov ah, 0ch
	int 10h
	inc cx
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	
	xor al, al ; black
	mov dx, 6
	mov cx, 154
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	inc cx
	mov ah, 0ch
	int 10h
	dec dx
	mov ah, 0ch
	int 10h
	mov cx, 160
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	inc cx
	mov ah, 0ch
	int 10h
	dec dx
	mov ah, 0ch
	int 10h
	
	mov dx, 14
	mov cx, 155
	xor si, si
	
DrawSmile4:
	mov ah, 0ch
	int 10h
	
	inc cx
	inc si
	cmp si, 6
	jl DrawSmile4
	
	dec dx
	mov ah, 0ch
	int 10h
	inc cx
	dec dx
	mov ah, 0ch
	int 10h
	mov cx, 153
	mov ah, 0ch
	int 10h
	inc cx
	inc dx
	mov ah, 0ch
	int 10h

	; Flags remaining counter starting at 10
	call FlagRcounter
	
	ret
endp DrawEmptyBoard
proc DrawRectangle
	xor si, si
	xor di, di
	mov cx, [xpos]
	add cx, [rectX]
	
Rect:
	mov ah, 0ch
	int 10h
	
	inc si
	inc cx
	cmp si, [rLength]
	jl Rect
	
	xor si, si
	inc di
	inc dx
	mov cx, [xpos]
	add cx, [rectX]
	cmp di, [rHeight]
	jl rect

	ret
endp DrawRectangle
proc SmallDelay
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]

FirstTick :
	cmp ax, [Clock]
	je FirstTick

DelayLoop:
	mov ax, [Clock]
Tick:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop

	ret
endp SmallDelay
proc CxNotZero
	cmp cx, 0
	jne endCxNotZero
	inc cx

endCxNotZero:
	ret
endp CxNotZero

proc DrawOne
	xor bx, bx
	mov al, 1 ; blue
	
	mov dx, [ypos]
	add dx, 16
	mov [rLength], 10
	mov [rHeight], 2
	mov [rectX], 13
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 5
	mov [rLength], 4
	mov [rHeight], 11
	mov [rectX], 16
	call DrawRectangle
	
	mov cx, [xpos]
	mov dx, [ypos]
	add cx, 15
	add dx, 7
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	dec cx
	mov ah, 0ch
	int 10h
	
	mov cx, [xpos]
	mov dx, [ypos]
	add cx, 16
	add dx, 5
	mov al, 7 ; gray
	mov ah, 0ch
	int 10h
	
	ret 
endp DrawOne
proc DrawTwo
	mov al, 2 ; green
	xor bx, bx
	
	mov dx, [ypos]
	add dx, 14
	mov [rLength], 14
	mov [rHeight], 3
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 6
	mov [rLength], 5
	mov [rHeight], 3
	mov [rectX], 19
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 3
	mov [rLength], 9
	mov [rHeight], 3
	mov [rectX], 12
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 5
	mov [rLength], 4
	mov [rHeight], 2
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 4
	mov [rLength], 2
	mov [rHeight], 2
	mov [rectX], 21
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 9
	mov [rLength], 4
	mov [rHeight], 3
	mov [rectX], 17
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 10
	mov [rLength], 4
	mov [rHeight], 3
	mov [rectX], 14
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 11
	mov [rLength], 4
	mov [rHeight], 3
	mov [rectX], 12
	call DrawRectangle
	
	mov cx, [xpos]
	mov dx, [ypos]
	add cx, 10
	add dx, 13
	mov ah, 0ch
	int 10h
	inc cx
	mov ah, 0ch
	int 10h
	dec dx
	mov ah, 0ch
	int 10h
	mov cx, [xpos]
	mov dx, [ypos]
	add cx, 21
	add dx, 9
	mov ah, 0ch
	int 10h
	mov cx, [xpos]
	mov dx, [ypos]
	add cx, 23
	add dx, 5
	mov ah, 0ch
	int 10h
	mov cx, [xpos]
	mov dx, [ypos]
	add cx, 11
	add dx, 4
	mov ah, 0ch
	int 10h

	ret
endp DrawTwo
proc DrawThree
	mov al, 4 ; red
	xor bx, bx
	
	mov dx, [ypos]
	add dx, 3
	mov [rLength], 13
	mov [rHeight], 3
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 15
	mov [rLength], 13
	mov [rHeight], 3
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 6
	mov [rLength], 3
	mov [rHeight], 9
	mov [rectX], 20
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 9
	mov [rLength], 6
	mov [rHeight], 3
	mov [rectX], 14
	call DrawRectangle
	
	mov [rLength], 1
	mov [rHeight], 5
	mov [rectX], 23
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 4
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 12
	call DrawRectangle
	
	ret
endp DrawThree
proc DrawFour
	mov al, 5 ; purple/ blue idk
	xor bx, bx
	
	mov dx, [ypos]
	add dx, 9
	mov [rLength], 14
	mov [rHeight], 3
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 3
	mov [rLength], 5
	mov [rHeight], 15
	mov [rectX], 18
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 6
	mov [rLength], 5
	mov [rHeight], 3
	mov [rectX], 11
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 3
	mov [rLength], 5
	mov [rHeight], 4
	mov [rectX], 12
	call DrawRectangle
	
	ret
endp DrawFour
proc DrawFive
	mov al, 112 ; dark red
	xor bx, bx
	
	mov dx, [ypos]
	add dx, 3
	mov [rLength], 14
	mov [rHeight], 3
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 15
	mov [rLength], 14
	mov [rHeight], 3
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 9
	mov [rLength], 14
	mov [rHeight], 3
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 6
	mov [rLength], 5
	mov [rHeight], 3
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 12
	mov [rLength], 5
	mov [rHeight], 3
	mov [rectX], 19
	call DrawRectangle
	
	mov al, 7 ; gray
	
	mov cx, [xpos]
	add cx, 23
	mov dx, [ypos]
	add dx, 9
	mov ah, 0ch
	int 10h
	mov dx, [ypos]
	add dx, 17
	mov ah, 0ch
	int 10h

	ret
endp DrawFive
proc DrawSix
	mov al, 9 ; light blue
	xor bx, bx
	
	mov dx, [ypos]
	add dx, 4
	mov [rLength], 5
	mov [rHeight], 12
	mov [rectX], 9
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 3
	mov [rLength], 12
	mov [rHeight], 2
	mov [rectX], 11
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 14
	mov [rLength], 12
	mov [rHeight], 3
	mov [rectX], 11
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 11
	mov [rLength], 5
	mov [rHeight], 5
	mov [rectX], 19
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 9
	mov [rLength], 9
	mov [rHeight], 2
	mov [rectX], 14
	call DrawRectangle
	
	mov cx, [xpos]
	mov dx, [ypos]
	add cx, 23
	add dx, 10
	mov ah, 0ch
	int 10h
	
	ret
endp DrawSix
proc DrawSeven
	xor al, al ; black
	xor bx, bx
	
	mov dx, [ypos]
	add dx, 4
	mov [rLength], 14
	mov [rHeight], 3
	mov [rectX], 9
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 15
	mov [rLength], 4
	mov [rHeight], 3
	mov [rectX], 15
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 12
	mov [rLength], 5
	mov [rHeight], 3
	mov [rectX], 16
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 9
	mov [rLength], 5
	mov [rHeight], 3
	mov [rectX], 17
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 7
	mov [rLength], 4
	mov [rHeight], 3
	mov [rectX], 19
	call DrawRectangle
	
	ret
endp DrawSeven
proc DrawEight
	xor al, al ; black
	xor bx, bx
	
	mov dx, [ypos]
	add dx, 9
	mov [rLength], 10
	mov [rHeight], 2
	mov [rectX], 12
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 14
	mov [rLength], 10
	mov [rHeight], 2
	mov [rectX], 12
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 11
	mov [rLength], 4
	mov [rHeight], 4
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 11
	mov [rLength], 4
	mov [rHeight], 4
	mov [rectX], 20
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 5
	mov [rLength], 4
	mov [rHeight], 4
	mov [rectX], 10
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 5
	mov [rLength], 4
	mov [rHeight], 4
	mov [rectX], 20
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 3
	mov [rLength], 12
	mov [rHeight], 3
	mov [rectX], 11
	call DrawRectangle
	
	mov al, 7 ; gray
	mov cx, [xpos]
	mov dx, [ypos]
	add cx, 11
	add dx, 3
	mov ah, 0ch
	int 10h
	mov cx, [xpos]
	add cx, 22
	mov ah, 0ch
	int 10h

	ret
endp DrawEight

proc DrawEmptySquare

	mov dx, [ypos]
	inc dx
	xor si, si
	mov ax, 38
	mov [rectX], 1
	
		
	cmp [xpos], 281
	je Empty1
	add si, 2
	
	dec [rectX]
	
	cmp [xpos], 0
	je Empty1
	add si, 2
	inc [rectX]
	
Empty1:
	sub ax, si
	mov [rLength], ax
	mov [rHeight], 19
	
	mov al, 23 ; darker gray
	call DrawRectangle
	
	ret
endp DrawEmptySquare
proc DrawBomb
	xor al, al ; black

	mov dx, [ypos]
	add dx, 4
	mov [rLength], 12
	mov [rHeight], 12
	mov [rectX], 11
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 9
	mov [rLength], 3
	mov [rHeight], 2
	mov [rectX], 8
	call DrawRectangle

	mov dx, [ypos]
	add dx, 9
	mov [rLength], 3
	mov [rHeight], 2
	mov [rectX], 23
	call DrawRectangle

	mov dx, [ypos]
	add dx, 1
	mov [rLength], 2
	mov [rHeight], 3
	mov [rectX], 16
	call DrawRectangle
	
	mov dx, [ypos]
	add dx, 16
	mov [rLength], 2
	mov [rHeight], 2
	mov [rectX], 16
	call DrawRectangle
	
	mov al, 15 ; white
	
	mov dx, [ypos]
	add dx, 6
	mov [rLength], 3
	mov [rHeight], 3
	mov [rectX], 13
	call DrawRectangle

	mov al, 7 ; gray
	mov cx, [xpos]
	mov dx, [ypos]
	add cx, 11
	add dx, 5
	mov ah, 0ch
	int 10h
	dec dx
	add cx, 2
	mov ah, 0ch
	int 10h
	add cx, 7
	mov ah, 0ch
	int 10h
	add cx, 2
	inc dx
	mov ah, 0ch
	int 10h
	add dx, 8
	mov ah, 0ch
	int 10h
	sub cx, 2
	inc dx
	mov ah, 0ch
	int 10h
	inc dx
	mov ah, 0ch
	int 10h
	sub cx, 7
	mov ah, 0ch
	int 10h
	dec dx
	mov ah, 0ch
	int 10h
	
	ret
endp DrawBomb
proc DrawFlag
	xor al, al ; black
	xor bx, bx

	mov dx, [ypos]
	add dx, 14
	mov [rLength], 9
	mov [rHeight], 3
	mov [rectX], 13
	call DrawRectangle

	mov dx, [ypos]
	add dx, 13
	mov [rLength], 6
	mov [rHeight], 1
	mov [rectX], 15
	call DrawRectangle

	mov dx, [ypos]
	add dx, 9
	mov [rLength], 2
	mov [rHeight], 4
	mov [rectX], 18
	call DrawRectangle

	mov dx, [ypos]
	add dx, 9
	mov [rLength], 2
	mov [rHeight], 4
	mov [rectX], 18
	call DrawRectangle

	mov al, 4 ; red

	mov dx, [ypos]
	add dx, 2
	mov [rLength], 2
	mov [rHeight], 7
	mov [rectX], 18
	call DrawRectangle

	mov dx, [ypos]
	add dx, 4
	mov [rLength], 4
	mov [rHeight], 4
	mov [rectX], 14
	call DrawRectangle

	mov dx, [ypos]
	add dx, 5
	mov [rLength], 2
	mov [rHeight], 2
	mov [rectX], 12
	call DrawRectangle

	mov dx, [ypos]
	add dx, 2
	mov [rLength], 1
	mov [rHeight], 2
	mov [rectX], 17
	call DrawRectangle

	ret
endp DrawFlag
proc RemoveFlag
	mov al, 7 ; gray
	xor bx, bx

	mov dx, [ypos]
	add dx, 2
	mov [rLength], 19
	mov [rHeight], 15
	mov [rectX], 12
	call DrawRectangle

	ret
endp RemoveFlag
proc FlagRcounter
	xor al, al ; black
	mov dx, 2
	mov [xpos], 301
	mov [rLength], 16
	mov [rHeight], 14
	mov [rectX], 0
	call DrawRectangle

	mov al, [flagCount]

	cmp al, 10
	je flagCount10
	jmp flagCount9
flagCount10:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 304
	mov [rLength], 2
	mov [rHeight], 11
	call DrawRectangle
	mov dx, 3
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 11
	call DrawRectangle
	xor al, al ; black
	mov dx, 8
	mov [xpos], 304
	mov [rLength], 10
	mov [rHeight], 1
	call DrawRectangle
	mov dx, 5
	mov [xpos], 310
	mov [rLength], 2
	mov [rHeight], 7
	call DrawRectangle
	ret

flagCount9:
	cmp al, 9
	je flagCount91
	jmp flagCount8

flagCount91:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 11
	call DrawRectangle
	xor al, al ; black
	mov dx, 9
	mov [xpos], 308
	mov [rLength], 4
	mov [rHeight], 3
	call DrawRectangle
	mov dx, 5
	mov [xpos], 310
	mov [rLength], 2
	mov [rHeight], 3
	call DrawRectangle
	ret
flagCount8:
	cmp al, 8
	je flagCount81
	jmp flagCount7

flagCount81:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 11
	call DrawRectangle
	xor al, al ; black
	mov dx, 5
	mov [xpos], 310
	mov [rLength], 2
	mov [rHeight], 3
	call DrawRectangle
	mov dx, 9
	mov [xpos], 310
	call DrawRectangle
	ret
flagCount7:
	cmp al, 7
	je flagCount71
	jmp flagCount6

flagCount71:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 2
	call DrawRectangle
	mov dx, 5
	mov [xpos], 312
	mov [rLength], 2
	mov [rHeight], 9
	call DrawRectangle
	xor al, al ; black
	mov cx, 312
	mov dx, 8
	mov ah,0ch
	int 10h
	inc cx
	mov ah,0ch
	int 10h
	ret
flagCount6:
	cmp al, 6
	je flagCount61
	jmp flagCount5

flagCount61:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 11
	call DrawRectangle
	xor al, al ; black
	mov dx, 5
	mov [xpos], 310
	mov [rLength], 4
	mov [rHeight], 3
	call DrawRectangle
	mov dx, 9
	mov [xpos], 310
	mov [rLength], 2
	mov [rHeight], 3
	call DrawRectangle
	ret
flagCount5:
	cmp al, 5
	je flagCount51
	jmp flagCount4

flagCount51:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 11
	call DrawRectangle
	xor al, al ; black
	mov dx, 5
	mov [xpos], 310
	mov [rLength], 4
	mov [rHeight], 3
	call DrawRectangle
	mov dx, 9
	mov [xpos], 308
	mov [rLength], 4
	mov [rHeight], 3
	call DrawRectangle
	ret
flagCount4:
	cmp al, 4
	je flagCount41
	jmp flagCount3

flagCount41:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 11
	call DrawRectangle
	xor al, al ; black
	mov dx, 3
	mov [xpos], 310
	mov [rLength], 2
	mov [rHeight], 5
	call DrawRectangle
	mov dx, 9
	mov [xpos], 308
	mov [rLength], 4
	mov [rHeight], 5
	call DrawRectangle
	ret
flagCount3:
	cmp al, 3
	je flagCount31
	jmp flagCount2

flagCount31:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 11
	call DrawRectangle
	xor al, al ; black
	mov dx, 5
	mov [xpos], 308
	mov [rLength], 4
	mov [rHeight], 3
	call DrawRectangle
	mov dx, 9
	mov [xpos], 308
	mov [rLength], 4
	mov [rHeight], 3
	call DrawRectangle
	ret
flagCount2:
	cmp al, 2
	je flagCount21
	jmp flagCount1

flagCount21:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 11
	call DrawRectangle
	xor al, al ; black
	mov dx, 5
	mov [xpos], 308
	mov [rLength], 4
	mov [rHeight], 3
	call DrawRectangle
	mov dx, 9
	mov [xpos], 310
	mov [rLength], 4
	mov [rHeight], 3
	call DrawRectangle
	ret
flagCount1:
	cmp al, 1
	je flagCount11
	jmp flagCount0

flagCount11:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 312
	mov [rLength], 2
	mov [rHeight], 11
	call DrawRectangle
	xor al, al ; black
	mov cx, 312
	mov dx, 8
	mov ah,0ch
	int 10h
	inc cx
	mov ah,0ch
	int 10h
	ret
flagCount0:
	mov al, 4 ; red
	mov dx, 3
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 11
	call DrawRectangle
	xor al, al ; black
	mov dx, 8
	mov [xpos], 308
	mov [rLength], 6
	mov [rHeight], 1
	call DrawRectangle
	mov dx, 5
	mov [xpos], 310
	mov [rLength], 2
	mov [rHeight], 7
	call DrawRectangle
	ret
endp FlagRcounter

proc CheckRestart
	xor si, si

	cmp dx, 18
	jg EndRestart
	cmp dx, 1
	jl EndRestart
	cmp cx, 149
	jl EndRestart
	cmp cx, 166
	jg EndRestart
	
	inc si
	
EndRestart:
	ret
endp CheckRestart
proc RestartProc
	mov ax, 2h ; hide mouse
	int 33h

	mov si, offset array
	mov cx, 81
	
RestartArray:
	mov [byte ptr si], 0
	inc si
	loop RestartArray
	
	mov si, offset bombs
	mov cx, 10
	
RestartBombs:
	mov [byte ptr si], 81
	inc si
	loop RestartBombs

	mov [gameOver], 0
	mov [flagCount], 10
	
	ret
endp RestartProc

proc WhichSquare
	xor si, si
	
	cmp dx, 20
	jl SquareEnd
	
	cmp cx, 315
	jl SquareCalc
	
	mov cx, 314
	
SquareCalc:
	mov ax, dx
	mov bl, 20
	div bl
	dec al
	mov bl, 9
	mul bl
	mov si, ax
	
	mov ax, cx
	dec ax
	mov bl, 35
	div bl
	inc al
	xor ah, ah
	add si, ax
	
SquareEnd:
	ret
endp WhichSquare
proc FindDrawPos
	mov ax, si
	mov bl, 9
	div bl
	
	cmp ah, 0
	jne DrawPosX
	
	mov [xpos], 281
	
	mov bl, 20
	mul bl
	dec ax
	
	mov [ypos], ax
	jmp EndDrawPos

DrawPosX:
	dec ah
	mov al, ah
	mov bl, 35
	mul bl
	inc ax
	mov [xpos], ax
	
	;ypos
	mov ax, si
	mov bl, 9
	div bl
	
	inc al
	mov bl, 20
	mul bl
	dec ax
	mov [ypos], ax
	
EndDrawPos:
	ret
endp FindDrawPos
proc RevealSquares
	mov cx, si
	call FindDrawPos
	mov si, cx

	mov ax, si
	mov bl, 9
	div bl
	cmp ah, 1
	jne RevealTheSquares
	mov [xpos], 0

RevealTheSquares:
	mov di, offset array
	dec cx
	
sqrInArr:
	inc di
	loop sqrInArr
	
	mov al, [byte ptr di]
	
arr1:	
	cmp al, 1
	jne arr2
	
	add [byte ptr di], 10
	
	mov ax, 2h ; hide mouse
	int 33h
	call DrawOne
	mov ax, 1h ; show mouse
	int 33h

	jmp endRevealSquares

arr2:
	cmp al, 2
	jne arr3
	
	add [byte ptr di], 10
	
	mov ax, 2h ; hide mouse
	int 33h
	call DrawTwo
	mov ax, 1h ; show mouse
	int 33h

	jmp endRevealSquares
	
arr3:
	cmp al, 3
	jne arr4
	
	add [byte ptr di], 10
	
	mov ax, 2h ; hide mouse
	int 33h
	call DrawThree
	mov ax, 1h ; show mouse
	int 33h

	jmp endRevealSquares
	
arr4:
	cmp al, 4
	jne arr5
	
	add [byte ptr di], 10
	
	mov ax, 2h ; hide mouse
	int 33h
	call DrawFour
	mov ax, 1h ; show mouse
	int 33h

	jmp endRevealSquares
	
arr5:
	cmp al, 5
	jne arr6
	
	add [byte ptr di], 10
	
	mov ax, 2h ; hide mouse
	int 33h
	call DrawFive
	mov ax, 1h ; show mouse
	int 33h

	jmp endRevealSquares
	
arr6:
	cmp al, 6
	jne arr7
	
	add [byte ptr di], 10
	
	mov ax, 2h ; hide mouse
	int 33h
	call DrawSix
	mov ax, 1h ; show mouse
	int 33h

	jmp endRevealSquares
	
arr7:
	cmp al, 7
	jne arr8
	
	add [byte ptr di], 10
	
	mov ax, 2h ; hide mouse
	int 33h
	call DrawSeven
	mov ax, 1h ; show mouse
	int 33h

	jmp endRevealSquares
	
arr8:
	cmp al, 8
	jne arrBomb
	
	add [byte ptr di], 10
	
	mov ax, 2h ; hide mouse
	int 33h
	call DrawEight
	mov ax, 1h ; show mouse
	int 33h

	jmp endRevealSquares
	
arrBomb:
	cmp al, 9
	jne arr0
	
	mov ax, 2h ; hide mouse
	int 33h
	call Lose
	mov ax, 1h ; show mouse
	int 33h
	ret
	
endRevealSquares:
	call Win
	ret

arr0:
	cmp al, 0
	jne endRevealSquares
	
	add [byte ptr di], 10
	push si

	mov ax, 2h ; hide mouse
	int 33h
	call DrawEmptySquare
	mov ax, 1h ; show mouse
	int 33h

	pop si
	;JMP endRevealSquares

	cmp si, 1
	jne emptysqr1

	mov si, 2
	call RevealSquares
	mov si, 10
	call RevealSquares
	mov si, 11
	call RevealSquares
	ret
emptysqr1:
	cmp si, 9
	jne emptysqr2

	mov si, 8
	call RevealSquares
	mov si, 17
	call RevealSquares
	mov si, 18
	call RevealSquares
	ret
emptysqr2:
	cmp si, 73
	jne emptysqr3

	mov si, 74
	call RevealSquares
	mov si, 64
	call RevealSquares
	mov si, 65
	call RevealSquares
	ret
emptysqr3:
	cmp si, 81
	jne emptysqr4

	mov si, 80
	call RevealSquares
	mov si, 71
	call RevealSquares
	mov si, 72
	call RevealSquares
	ret
emptysqr4:
	mov ax, si
	mov bl, 9
	div bl

	cmp ah, 0
	jne emptysqr5

	push si
	dec si
	call RevealSquares
	pop si
	push si
	sub si, 9
	call RevealSquares
	pop si
	push si
	sub si, 10
	call RevealSquares
	pop si
	push si
	add si, 9
	call RevealSquares
	pop si
	push si
	add si, 8
	call RevealSquares
	pop si
	ret
emptysqr5:
	cmp ah, 1
	jne emptysqr6

	push si
	inc si
	call RevealSquares
	pop si
	push si
	sub si, 9
	call RevealSquares
	pop si
	push si
	sub si, 8
	call RevealSquares
	pop si
	push si
	add si, 9
	call RevealSquares
	pop si
	push si
	add si, 10
	call RevealSquares
	pop si
	ret
emptysqr6:
	xor ah, ah
	push ax
	push si
	inc si
	call RevealSquares
	pop si
	push si
	dec si
	call RevealSquares
	pop si
	pop ax

	cmp al, 0
	jne emptysqr7

	push si
	add si, 9
	call RevealSquares
	pop si
	push si
	add si, 8
	call RevealSquares
	pop si
	push si
	add si, 10
	call RevealSquares
	pop si
	ret
emptySqr7:
	cmp al, 8
	jne emptysqr8

	push si
	sub si, 9
	call RevealSquares
	pop si
	push si
	sub si, 8
	call RevealSquares
	pop si
	push si
	sub si, 10
	call RevealSquares
	pop si
	ret
emptySqr8:
	push si
	add si, 9
	call RevealSquares
	pop si
	push si
	add si, 8
	call RevealSquares
	pop si
	push si
	add si, 10
	call RevealSquares
	pop si
	push si
	sub si, 9
	call RevealSquares
	pop si
	push si
	sub si, 8
	call RevealSquares
	pop si
	push si
	sub si, 10
	call RevealSquares
	pop si
	ret
endp RevealSquares
proc Flagging
	mov cx, si
	call FindDrawPos

	mov di, offset array
	dec cx
	
sqrInArrF:
	inc di
	loop sqrInArrF
	
	mov al, [byte ptr di]

	cmp al, 9
	jg Flag2

	mov al, [flagCount]
	cmp al, 0
	je EndFlagging

	add [byte ptr di], 20
	dec [flagCount]

	mov ax, 2h ; hide mouse
	int 33h
	call DrawFlag
	mov ax, 1h ; show mouse
	int 33h
	call FlagRcounter
	mov cx, 4 ; 4x0.055sec = ~0.2 sec
	call SmallDelay
	call Win

	jmp EndFlagging

Flag2:
	cmp al, 20
	jl EndFlagging

	sub [byte ptr di], 20
	inc [flagCount]

	mov ax, 2h ; hide mouse
	int 33h
	call RemoveFlag
	mov ax, 1h ; show mouse
	int 33h
	call FlagRcounter
	mov cx, 4 ; 4x0.055sec = ~0.2 sec
	call SmallDelay

EndFlagging:
	ret
endp Flagging

proc Lose
	mov di, offset array
	mov si, 1

RevealBombs:
	mov al, [byte ptr di]
	cmp al, 9
	jne RevealBombsLoop

	call FindDrawPos

	push si
	call DrawBomb
	pop si

	mov di, offset array
	add di, si
	dec di

RevealBombsLoop:
	inc di
	inc si

	cmp si, 81
	jle RevealBombs

	xor bx, bx
	mov al, 44 ; yellow
	mov [xpos], 153
	mov dx, 6
	mov [rLength], 10
	mov [rHeight], 9
	mov [rectX], 0
	call DrawRectangle

	xor al, al ; black
	mov [xpos], 155
	mov dx, 11
	mov [rLength], 6
	mov [rHeight], 1
	mov [rectX], 0
	call DrawRectangle

	mov cx, 154
	mov dx, 12
	mov ah, 0ch
	int 10h
	mov cx, 161
	mov ah, 0ch
	int 10h
	inc dx
	inc cx
	mov ah, 0ch
	int 10h
	mov cx, 153
	mov ah, 0ch
	int 10h

	mov dx, 5
	mov ah, 0ch
	int 10h
	add dx, 2
	mov ah, 0ch
	int 10h
	sub dx, 2
	mov cx, 155
	mov ah, 0ch
	int 10h
	add dx, 2
	mov ah, 0ch
	int 10h
	sub dx, 2
	mov cx, 160
	mov ah, 0ch
	int 10h
	add dx, 2
	mov ah, 0ch
	int 10h
	sub dx, 2
	mov cx, 162
	mov ah, 0ch
	int 10h
	add dx, 2
	mov ah, 0ch
	int 10h
	sub dx, 2
	mov cx, 154
	mov dx, 6
	mov ah, 0ch
	int 10h
	mov cx, 161
	mov ah, 0ch
	int 10h

	mov [gameOver], 1
	
	
	ret
endp Lose
proc Win
	mov di, offset array
	mov cx, 81

WinCheck:
	mov al, [byte ptr di]
	cmp al, 10
	jl EndWinCheck

	inc di
	loop WinCheck
	mov [gameOver], 1

EndWinCheck:
	mov al, [gameOver]
	cmp al, 0
	je EndWin

	xor al, al ; black

	mov [xpos], 151
	mov dx, 6
	mov [rLength], 14
	mov [rHeight], 1
	mov [rectX], 0
	call DrawRectangle

	mov dx, 7
	mov cx, 153
	mov ah, 0ch
	int 10h
	mov cx, 156
	mov ah, 0ch
	int 10h
	mov cx, 159
	mov ah, 0ch
	int 10h
	mov cx, 162
	mov ah, 0ch
	int 10h
	mov cx, 154
	inc dx
	mov ah, 0ch
	int 10h
	inc cx
	mov ah, 0ch
	int 10h
	mov cx, 160
	mov ah, 0ch
	int 10h
	inc cx
	mov ah, 0ch
	int 10h

EndWin:
	ret
endp Win
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------	
CodeStart:
; getting 10 random numbers for bomb positions
	mov ax, 40h
	mov es, ax
	mov cx, 10
	xor bx, bx
	mov di, offset bombs
RandLoop:
	; generate random number, cx number of times
	mov ax, [Clock] ; read timer counter
	mov ah, [byte cs:bx] ; read one byte from memory
	xor al, ah ; xor memory and counter
	and al, 01111111b ; leave result between 0-127
	

	call checkBombsPos
	cmp al, 80
	jg RandLoop
	
	xor ah, ah
	mov si, ax
	mov [array+si], 9 ; indicate bomb at pos 1-81
	
	inc bx
	inc di
	
	loop RandLoop
	
	; putting values into the array after we have 10 bombs (the numbers)
	call arrayValues

	; Graphic mode
	mov ax, 13h
	int 10h
	
	Call DrawEmptyBoard
	
	; Initializes the mouse
	mov ax, 0h
	int 33h
	
	; Show mouse
	mov ax, 1h
	int 33h
	
	; Loop until mouse click
MouseCheck:
	mov ax, 3h
	int 33h
	
	cmp bx, 01h ; check left mouse click
	je LeftClick
	
	shr bx, 1
	cmp bx, 01h ; check right mouse click
	je RightClick
	
	jmp MouseCheck
	
LeftClick:
	shr cx, 1
	call CxNotZero
	
	call CheckRestart
	cmp si, 1
	je Restart
	
	call WhichSquare
	cmp si, 0
	je MouseCheck
	
	call RevealSquares

	mov al, [gameOver]
	cmp al, 1
	je GameOverLoop
	
	jmp MouseCheck

RightClick:
	shr cx, 1
	call CxNotZero

	call WhichSquare
	cmp si, 0
	je MouseCheck

	call Flagging

	mov al, [gameOver]
	cmp al, 1
	je GameOverLoop
		
	jmp MouseCheck

Restart:
	call RestartProc
	jmp CodeStart 
	
GameOverLoop:
	mov ax, 3h
	int 33h
	
	cmp bx, 01h ; check left mouse click
	je goLeftClick

	jmp GameOverLoop

goLeftClick:
	shr cx, 1
	call CxNotZero
	
	call CheckRestart
	cmp si, 1
	je Restart

	jmp GameOverLoop

exit:
	mov ax, 4c00h
	int 21h
END start