[BITS 64]

struc color
	.r: resb 1
	.g: resb 1
	.b: resb 1
	.a: resb 1
endstruc

struc vector3
	.x: resd 1
	.y: resd 1
	.z: resd 1
endstruc

struc camera3d
	.position: resb vector3_size
	.target: resb vector3_size
	.up: resb vector3_size
	.fovy: resd 1
	.projection: resd 1
endstruc

struc model
	.transform: resd 16
	.mesh_count: resd 1
	.meshes: resq 1
	.materials: resq 1
	.mesh_material: resq 1

	.bone_count: resd 1
	.bone_info: resq 1
	.bind_pose: resq 1
endstruc

section .rodata
hello_label db "Hello, world", 10, 0
window_title db "Test game", 0
text_label db "Welcome from ASMRaylib!", 0

model_path db "res/test.glb", 0

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

; todo: floats
grid_spacing dd 1.0

section .data
camera:
	istruc camera3d
		at camera3d.position, istruc vector3
				at vector3.x, dd 5.0
				at vector3.y, dd 4.0
				at vector3.z, dd 5.0
			iend
		at camera3d.target, istruc vector3
				at vector3.x, dd 0.0
				at vector3.y, dd 2.0
				at vector3.z, dd 0.0
			iend
		at camera3d.up, istruc vector3
				at vector3.x, dd 0.0
				at vector3.y, dd 1.0
				at vector3.z, dd 0.0
			iend
		at camera3d.fovy, dd 45.0
		at camera3d.projection, dd 0 ; CAMERA_PERSPECTIVE
	iend

position: istruc vector3
	at vector3.x, dd 0.0
	at vector3.y, dd 0.0
	at vector3.z, dd 0.0
iend

rotation: istruc vector3
	at vector3.x, dd 1.0
	at vector3.y, dd 0.0
	at vector3.z, dd 0.0
iend

scale: istruc vector3
	at vector3.x, dd 1.0
	at vector3.y, dd 1.0
	at vector3.z, dd 1.0
iend

angle: dd -90.0

section .bss
model_data: resb model_size

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
extern UpdateCamera
extern BeginMode3D
extern EndMode3D
extern DrawGrid
extern LoadModel
extern DrawModelEx

global main
main:
	sub rsp, 8

	; Say cheese
	lea rdi, [rel hello_label]
	xor rax, rax
	call printf

	; Init window
	mov rdi, 800
	mov rsi, 450
	lea rdx, [rel window_title]
	call InitWindow

	; Load model
	lea rdi, [rel model_data]; sysv: first arg is now the place where to put the struct
	lea rsi, [rel model_path]
	call LoadModel

	; Optional, we wanna show off
	mov rdi, 60
	call SetTargetFPS

	; Main program loop
.loop:
	call WindowShouldClose
	cmp rax, 1
	je .end
	xor rax, rax
	
	; Start of the loop
	lea rdi, [rel camera]
	mov rsi, 2 ; CAMERA_ORBITAL
	call UpdateCamera

	call BeginDrawing

	mov rdi, [rel raywhite]
	call ClearBackground

	; BeginMode3D
	sub rsp, 48 ; make space for the camera struct
	lea rsi, [rel camera] ; start address
	mov rdi, rsp ; end address
	mov rcx, 6 ; size = val(6) * 8 = 48
	rep movsq ; copy
	call BeginMode3D 
	add rsp, 48 ; free space

	; DrawModelEx
	; arg pandemonium
	; model: stack
	sub rsp, 128 ; make space for model struct
	lea rsi, [rel model_data]
	mov rdi, rsp
	mov rcx, 16
	rep movsq

	; position: xmm0 and xmm1
	movq xmm0, [rel position]
	movss xmm1, [rel position + 8]
	; rotation: xmm2 and xmm3
	movq xmm2, [rel rotation]
	movss xmm3, [rel rotation + 8]
	; angle: xmm4
	movss xmm4, [rel angle]
	; scale: xmm5, xmm6
	movq xmm5, [rel scale]
	movss xmm6, [rel scale + 8]
	; color: rdi
	mov rdi, [rel red]
	; and call
	call DrawModelEx
	; clean up the extra stack data
	add rsp, 128

	mov rdi, 10
	movss xmm0, [rel grid_spacing]
	call DrawGrid

	call EndMode3D

	lea rdi, [rel text_label]
	mov rsi, 0
	mov rdx, 0 
	mov rcx, 40
	mov r8, [rel red]
	call DrawText

	mov rdi, 0
	mov rsi, 80
	call DrawFPS

	call EndDrawing

	jmp .loop

.end:
	call CloseWindow

	mov rdi, 0
	call exit
