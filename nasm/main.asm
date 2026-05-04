[BITS 64]

%define LUA_GLOBALSINDEX -10002
%define LUA_TFUNCTION 6

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
	; Matrix
	.transform: resd 16

	.mesh_count: resd 1
	.material_count: resd 1

	.meshes: resq 1
	.materials: resq 1

	.mesh_material: resq 1
	.bone_count: resd 1

	.bone_info: resq 1
	.bind_pose: resq 1
endstruc

section .rodata

;; strings

; debug string
print_value_reg db "dbg: reg 0x%x", 10, 0

; error messages
lua_create_error db "err: can't create luajit state", 10, 0
lua_loadfile_error db "err: can't load game.lua", 10, 0

; hello string
hello_label db "Hello, world", 10, 0

; raylib strings
window_title db "Test game", 0
text_label db "Welcome from ASMRaylib!", 0

; paths
model_path db "res/test.glb", 0
lua_script db "res/game.lua", 0

; lua api signatures
lua_oninit_signature db "OnInit", 0
lua_onupdate_signature db "OnUpdate", 0
lua_engine_signature db "Engine", 0
lua_load_model_signature db "LoadModel", 0

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
; lua state ptr
lua_state: resq 1

model_data: resb model_size


section .text

; libc
extern exit
extern printf

; raylib
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

; luajit
extern luaL_newstate
extern luaL_openlibs
extern luaL_checklstring
extern luaL_loadfile
extern lua_pcall
extern lua_createtable
extern lua_pushcclosure
extern lua_setfield
extern lua_getfield
extern lua_isfunction
extern lua_type

global main
main:
	sub rsp, 8

	; Say cheese
	lea rdi, [rel hello_label]
	xor rax, rax
	call printf

.init_window:
	; Init window
	mov rdi, 800
	mov rsi, 450
	lea rdx, [rel window_title]
	call InitWindow

.init_lua:
	call luaL_newstate
	test rax, rax
	jnz .init_lua_2

	lea rdi, [rel lua_create_error]
	xor rax, rax
	call printf

	mov rdi, 255
	call exit
	; end of path

.init_lua_2:
	; align stack for rdi pushes before calls
	sub rsp, 8

	; save lua ptr from rax
	mov [rel lua_state], rax

	; load in rdi
	mov rdi, rax
	; load lua libs
	push rdi
	call luaL_openlibs 
	pop rdi

	; load script
	lea rsi, [rel lua_script]
	push rdi
	call luaL_loadfile
	pop rdi
	test rax, rax
	jz .init_lua_pcall

	lea rdi, [rel lua_loadfile_error]
	xor rax, rax
	call printf

	mov rdi, 255
	call exit
	; end of path

.init_lua_pcall:
	xor rsi, rsi
	xor rdx, rdx
	xor rcx, rcx
	push rdi
	call lua_pcall
	pop rdi

	test rax, rax
	jz .init_lua_api
	
	; ...

	mov rdi, 255
	call exit
	; end of path

.init_lua_api:
	; create table api
	mov rsi, 1 ; reserved function spaces
	mov rdx, 0
	push rdi
	call lua_createtable
	pop rdi

	; push functions
	lea rsi, [rel lua_load_model]
	xor rdx, rdx
	push rdi
	call lua_pushcclosure
	pop rdi

	mov rsi, -2 ; [1] table [2] load_model
	lea rdx, [rel lua_load_model_signature]
	push rdi
	call lua_setfield
	pop rdi

	mov rsi, LUA_GLOBALSINDEX
	lea rdx, [rel lua_engine_signature]
	push rdi
	call lua_setfield
	pop rdi

	; get the on init function
	mov rsi, LUA_GLOBALSINDEX
	lea rdx, [rel lua_oninit_signature]
	push rdi
	call lua_getfield
	pop rdi

	; check if oninit is a function
	mov rsi, -1
	push rdi
	call lua_type
	pop rdi

	cmp rax, LUA_TFUNCTION
	je .lua_run_oninit

	; ...

	mov rdi, 255
	call exit

	; end of path

.lua_run_oninit:
	; Runs OnInit
	xor rsi, rsi
	xor rdx, rdx
	xor rcx, rcx
	push rdi
	call lua_pcall
	pop rdi

	push rax

	pop rax

	; rdi with lua state has been fully popped, restore stack alignment
	add rsp, 8

	test rax, rax
	jz .post_init

	;...
	mov rdi, 255
	call exit

	; path ends here

.post_init:
	; Optional, we wanna show off
	mov rdi, 60
	call SetTargetFPS

	; Main program loop
.loop:
	call WindowShouldClose
	cmp rax, 1
	je .end
	xor rax, rax

.loop_lua_onupdate:
	sub rsp, 8

	mov rdi, [rel lua_state]

	; get the on update function
	mov rsi, LUA_GLOBALSINDEX
	lea rdx, [rel lua_onupdate_signature]
	push rdi
	call lua_getfield
	pop rdi

	; check if oninit is a function
	mov rsi, -1
	push rdi
	call lua_type
	pop rdi

	cmp rax, LUA_TFUNCTION
	jne .end


	; Runs OnUpdate
	xor rsi, rsi
	xor rdx, rdx
	xor rcx, rcx
	push rdi
	call lua_pcall
	pop rdi

	push rax

	pop rax
	add rsp, 8

	test rax, rax
	jz .loop_rendering

	; ...

	mov rdi, 255
	call exit
	; path ends

.loop_rendering:
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

	; todo cleanup

	mov rdi, 0
	call exit

; engine api
lua_load_model:
	; prologue
	push rbp
	mov rbp, rsp

	; stack is 16 bit aligned, can call
	
	; get the model path
	mov rsi, 1
	xor rdx, rdx
	push rdi
	sub rsp, 8
	call luaL_checklstring

	; load model

	lea rdi, [rel model_data]; sysv: first arg is now the place where to put the struct
	mov rsi, rax
	call LoadModel

	add rsp, 8
	pop rdi

	xor rax, rax

	; epilogue
	leave
	ret
