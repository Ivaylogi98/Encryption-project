masm
model   small
.stack   256
.data
message1 db 'Message: $'
message2 db 'Press 1 to crypt $'
message3 db 'Press 2 to decrypt $'
message4 db 'Press 3 to save current message to file $'
message5 db 'Press 4 to exit $'
message6 db 'Max encryption $'
message7 db 'Min decryption $'

filename1 db 'input.txt',0
handler1 dw ?
point_fname1 dd	filename1
fileSize1 dw ?

filename2 db 'output.txt',0
handler2 dw ?
point_fname2 dd	filename2
fileSize2 dw ?

len dw 200
level db 30h

pass equ 170
pass2 equ 3

buffer db 200 dup (0)

.code
main:
	mov ax, @data
	mov ds, ax
	
	xor ax, ax ;Open file
	mov al, 02h
	mov	ah, 3dh
	lds	dx, point_fname1
	int	21h
	mov handler1, ax

	mov ah, 3fh ;Read file
	mov bx, handler1
	mov cx, len
	lea dx, buffer
	int 21h
	
	mov cx, len
	mov si, 0
	
computeLen:
	cmp buffer[si], 20h
	jl correctLen
	cmp buffer[si], 7fh
	jg correctLen
	inc si
	loop computeLen
	jmp output
	
correctLen:
	sub len, cx
	
output:
	xor dx, dx
	mov dx, offset message1 ;'Message: $'
	mov ah, 09h
	int 21h
	
	xor cx, cx
	xor si, si
	mov cx, len
	mov si, 0
printMessage:
	mov dl, buffer[si]
	mov ah, 02h
	int 21h
	inc si
	loop printMessage
	
input:
	mov dl, 10
	mov ah, 02h
	int 21h ;prints new line

	xor dx, dx
	mov dx, offset message2 ;'Press 1 to crypt $'
	mov ah, 09h
	int 21h

	mov dl, 10
	mov ah, 02h
	int 21h

	xor dx, dx
	mov dx, offset message3 ;'Press 2 to decrypt $'
	mov ah, 09h
	int 21h

	mov dl, 10
	mov ah, 02h
	int 21h

	xor dx, dx
	mov dx, offset message4 ;'Press 3 to save current message to file $'
	mov ah, 09h
	int 21h

	mov dl, 10
	mov ah, 02h
	int 21h

	xor dx, dx
	mov dx, offset message5 ;'Press 4 to exit $'
	mov ah, 09h
	int 21h

	mov dl, 10
	mov ah, 02h
	int 21h

	mov ah, 1h
	int 21h
	
	cmp al, 31h
	je toCrypt
	cmp al, 32h
	je toDecryptJumptExtend
	cmp al, 33h
	je saveJumptExtend
	cmp al, 34h
	je exitJumptExtend
	
outputJumptExtend:
	jmp output
	
toCrypt:
	mov cx, len
	mov si, 0
	
	cmp level, 30h
	je crypt1
	cmp level, 31h
	je crypt2
	cmp level, 32h
	je crypt3
	cmp level, 33h
	je maxcrypt
	
crypt1:
	xor buffer[si], pass
	inc si
	loop crypt1
	inc level
	jmp outputJumptExtend

crypt2:
	mov ah, buffer[si]
	add buffer[si+1], ah
	inc si
	loop crypt2
	mov ax, len
	add buffer[0], al
	inc level
	jmp outputJumptExtend

crypt3:
	ror buffer[si], pass2
	inc si
	loop crypt3
	inc level
	jmp outputJumptExtend

maxCrypt:
	xor dx, dx
	mov dx, offset message6 ;'Max encryption$'
	mov ah, 09h
	int 21h
	mov dl, 10
	mov ah, 02h
	int 21h ;print new line
	jmp outputJumptExtend

toDecryptJumptExtend:
	jmp toDecrypt
exitJumptExtend:
	jmp exit
saveJumptExtend:
	jmp save
inputJumptExtend:
	jmp input
	
toDecrypt:
	mov cx, len
	mov si, 0
	
	cmp level, 30h
	je minDecrypt
	cmp level, 31h
	je decrypt1
	cmp level, 32h
	je decrypt2
	cmp level, 33h
	je decrypt3
	
decrypt1:
	xor buffer[si], pass
	inc si
	loop decrypt1
	dec level
	jmp outputJumptExtend

decrypt2:
	mov si, len
	mov ax, len
	sub buffer[0], al
decr2Cycle:
	mov ah, buffer[si-1]
	sub buffer[si], ah
	dec si
	loop decr2Cycle
	dec level
	jmp outputJumptExtend
	
decrypt3:
	rol buffer[si], pass2
	inc si
	loop decrypt3
	dec level
	jmp outputJumptExtend
	
minDecrypt:
	xor dx, dx
	mov dx, offset message7 ;'Min decryption$'
	mov ah, 09h
	int 21h
	
	mov dl, 10
	mov ah, 02h
	int 21h
	jmp outputJumptExtend
	
save: 
	mov	ah, 3ch ;create and open output file
	lds	dx, point_fname2
	mov cx, 1
	int	21h
	mov handler2, ax

	mov ah, 40h ;write in file
	mov cx, len
	mov bx, handler2
	lea dx, buffer
	int 21h

	mov	ah, 3eh ;close output file
	lds bx, point_fname2
	int 21h
	mov	handler2, ax 
	jmp inputJumptExtend
	
exit:
	mov	ah, 3eh ;Close input file
	lds bx, point_fname1
	int 21h
	mov	handler1, ax
	mov	ax, 4c00h 
	int	21h
end main
