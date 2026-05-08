#include <raylib.h>
#include <luajit-2.1/lua.h>
#include <luajit-2.1/lualib.h>
#include <luajit-2.1/lauxlib.h>
#include <luajit-2.1/luajit.h>
#include <hash.h>

static Model model;

int lua_load_model(lua_State *lua) {
	const char *path = luaL_checkstring(lua, 1);
	model = LoadModel(path);

	return 0;
}

static const struct luaL_Reg engine_api[] = {
	{"LoadModel", lua_load_model},
	{NULL, NULL},
};

int main() {
	// Create the raylib window and context
	const int screenWidth = 800;
	const int screenHeight = 450;
	InitWindow(screenWidth, screenHeight, "Test game");

	// Init the lua engine
	lua_State *lua = luaL_newstate();
	if (lua == NULL) {
		printf("err: can't create luajit state\n");

		return 255;
	}
	luaL_openlibs(lua);

	// Load the main game script
	const char *lua_script = "res/game.lua";
	if (luaL_loadfile(lua, lua_script) != LUA_OK) {
		//...
		return 255;
	}
	if (lua_pcall(lua, 0, 0, 0) != LUA_OK) {
		//...
		return 255;
	}

	//  Create the Engine LUA api
	luaL_newlib(lua, engine_api);
	lua_setglobal(lua, "Engine");


	// Execute OnInit
	lua_getglobal(lua, "OnInit");
	if (lua_isfunction(lua, -1)) {
		if (lua_pcall(lua, 0, 0, 0) != LUA_OK) {
			//...
			return 255;
		}
	} else {
		//...
		return 255;
	}

	Camera3D camera = { 0 };
	camera.position = (Vector3){ 5.0f, 4.0f, 5.0f };
	camera.target = (Vector3){ 0.0f, 2.0f, 0.0f };
	camera.up = (Vector3){ 0.0f, 1.0f, 0.0f };
	camera.fovy = 45.0f;
	camera.projection = CAMERA_PERSPECTIVE;
	Vector3 position = { 0.0f, 0.0f, 0.0f };

	SetTargetFPS(60);

	while (!WindowShouldClose()) {
		lua_getglobal(lua, "OnUpdate");
		if (!lua_isfunction(lua, -1)) {
			//...
			return 255;
		}

		if (lua_pcall(lua, 0, 0, 0) != LUA_OK) {
			//...
		}

		UpdateCamera(&camera, CAMERA_ORBITAL);

        	BeginDrawing();

	        	ClearBackground(WHITE);

			BeginMode3D(camera);

				DrawModelEx(model, position, (Vector3){ 1.0f, 0.0f, 0.0f }, -90.0f, (Vector3){ 1.0f, 1.0f, 1.0f }, RED);
				DrawGrid(10, 1.0f);
			EndMode3D();

			DrawText("Welcome from CRaylib!", 0, 0, 40, RED);
			DrawFPS(0, 80);

		EndDrawing();
	}

	CloseWindow();

	return 0;
}
