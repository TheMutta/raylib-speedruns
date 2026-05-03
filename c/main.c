#include <raylib.h>
#include <stdio.h>

int main() {
	const int screenWidth = 800;
	const int screenHeight = 450;

	InitWindow(screenWidth, screenHeight, "Test game");

	Camera3D camera = { 0 };
	camera.position = (Vector3){ 5.0f, 4.0f, 5.0f };
	camera.target = (Vector3){ 0.0f, 2.0f, 0.0f };
	camera.up = (Vector3){ 0.0f, 1.0f, 0.0f };
	camera.fovy = 45.0f;
	camera.projection = CAMERA_PERSPECTIVE;

	const char *model_path = "res/test.glb";
	Model model = LoadModel(model_path);
	Vector3 position = { 0.0f, 0.0f, 0.0f };

	SetTargetFPS(60);

	while (!WindowShouldClose()) {
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
