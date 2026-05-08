cmake_minimum_required(VERSION 3.23)

project(RaylibSpeedruns VERSION 0.1 LANGUAGES C CXX ASM_NASM)

enable_language(ASM_NASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

include(FetchContent)

FetchContent_Declare(
	chash
	GIT_REPOSITORY https://gitlab.com/TheMutta/chash.git
	GIT_TAG        main
)

FetchContent_MakeAvailable(chash)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LUAJIT REQUIRED luajit)

find_package(PkgConfig REQUIRED)
pkg_check_modules(RAYLIB REQUIRED raylib)

add_executable(c_game c/main.c)
target_link_libraries(c_game PRIVATE chash ${RAYLIB_LIBRARIES} ${LUAJIT_LIBRARIES})
target_compile_options(c_game PRIVATE -Wall -Wextra -Wpedantic -O3 -march=native)
target_include_directories(c_game PRIVATE ${RAYLIB_INCLUDE_DIRS} ${LUAJIT_INCLUDE_DIRS})

add_executable(cpp_game cpp/main.cpp)
target_link_libraries(cpp_game PRIVATE chash ${RAYLIB_LIBRARIES} ${LUAJIT_LIBRARIES})
target_compile_options(cpp_game PRIVATE -Wall -Wextra -Wpedantic -O3 -march=native)
target_include_directories(cpp_game PRIVATE ${RAYLIB_INCLUDE_DIRS} ${LUAJIT_INCLUDE_DIRS})

add_executable(nasm_game nasm/main.asm)
set_target_properties(nasm_game PROPERTIES LINKER_LANGUAGE C)
target_compile_options(nasm_game PRIVATE -felf64)
target_link_options(nasm_game PRIVATE "-no-pie")
target_link_libraries(nasm_game PRIVATE chash ${RAYLIB_LIBRARIES} ${LUAJIT_LIBRARIES} m dl)
