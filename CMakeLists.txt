cmake_minimum_required(VERSION 3.19)
project(sdb LANGUAGES CXX)
include(CTest)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_subdirectory(src)
add_subdirectory(tools)

if(BUILD_TESTING)
    # enable_testing()
    find_package(Catch2 CONFIG REQUIRED)
    add_subdirectory(test)
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(readline REQUIRED IMPORTED_TARGET readline)

target_link_libraries(sdb PRIVATE sdb::libsdb PkgConfig::readline)