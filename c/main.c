#include <raylib.h>

int main() {
	const int screenWidth = 800;
	const int screenHeight = 450;

	InitWindow(screenWidth, screenHeight, "Test game");
	while (!WindowShouldClose()) {
        	BeginDrawing();

	        ClearBackground(WHITE);

		DrawText("Welcome from CRaylib!", 0, 0, 40, RED);
		DrawFPS(60, 80);

		EndDrawing();
	}

	CloseWindow();

	return 0;
}
