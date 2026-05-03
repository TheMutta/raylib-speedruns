[BITS 64]

struc color
	.r: resb 1
	.g: resb 1
	.b: resb 1
	.a: resb 1
endstruc

section .rodata
hello_label db "Hello, world", 10, 0
window_title db "Test game", 0
text_label db "Welcome from ASMRaylib!", 0

raywhite:
	istruc color
		at color.r, db 255
		at color.g, db 255
		at color.b, db 255
		at color.a, db 255
	iend

red:
	istruc color
		at color.r, db 255
		at color.g, db 0
		at color.b, db 0
		at color.a, db 255
	iend
		

section .text
extern exit
extern printf

extern InitWindow
extern SetTargetFPS
extern WindowShouldClose
extern BeginDrawing
extern ClearBackground
extern DrawText
extern EndDrawing
extern CloseWindow
extern DrawFPS

global main
main:
	sub rsp, 8

	; Say cheese
	lea rdi, [rel hello_label]
	xor rax, rax
	call printf

	mov rdi, 800
	mov rsi, 450
	lea rdx, [rel window_title]
	call InitWindow

	; Optional, we wanna show off
	; mov rdi, 60
	; call SetTargetFPS

	; Main program loop
.loop:
	call WindowShouldClose
	cmp rax, 1
	je .end

	call BeginDrawing

	lea rdi, [rel raywhite]
	mov rdi, [rdi]
	call ClearBackground

	lea rdi, [rel text_label]
	mov rsi, 0
	mov rdx, 0 
	mov rcx, 40
	lea r8, [rel red]
	mov r8, [r8]
	call DrawText

	mov rdi, 60
	mov rsi, 80
	call DrawFPS

	call EndDrawing

	jmp .loop

.end:
	call CloseWindow

	mov rdi, 0
	call exit
