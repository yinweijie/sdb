add_library(libsdb libsdb.cpp)

# Creates an alias target 'sdb::libsdb' for the 'libsdb' target
# This allows other parts of the project to link against 'sdb::libsdb'
# using namespace-like syntax, which improves readability and organization
add_library(sdb::libsdb ALIAS libsdb)

# 默认情况下，在Linux上，CMake创建的库名为lib<target name>。由于我们不希望编译后的库名为liblibsdb.a，
# 所以我们告诉CMake输出的库应名为sdb。现在，它应该会生成sdb.a。
set_target_properties(libsdb 
    PROPERTIES OUTPUT_NAME sdb
)

target_compile_features(libsdb PUBLIC cxx_std_17)

# 当前路径下的include目录为私有头文件目录
# ${CMAKE_SOURCE_DIR}/include，即sdb/include，为公共头文件目录
# target_include_directories(libsdb
#     PRIVATE include
#     PUBLIC ${CMAKE_SOURCE_DIR}/include
# )

# Configure include directories for 'libsdb' target
#
# PUBLIC includes:
#   - When installed: 'include' directory relative to installation prefix
#   - When building: '{PROJECT_ROOT}/include' directory
#
# PRIVATE includes:
#   - '{PROJECT_ROOT}/src/include' directory (only used internally during build)
#
# The generator expressions ($<...>) ensure proper paths are used depending on
# whether we're building or installing the library.

# 通过几个生成器表达式，我们针对不同的情况指定了正确的头文件位置。如果用户访问的是已安装版本的libsdb，
# 公共头文件位于相对于安装位置的include目录中。如果他们使用的是构建树中的版本（例如，他们正在链接sdb可执行文件时），
# 我们应该使用源树中的include目录。
target_include_directories(libsdb 
PUBLIC
    $<INSTALL_INTERFACE:include>
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
PRIVATE
    ${CMAKE_SOURCE_DIR}/src/include
)

include(GNUInstallDirs)
# Install the libsdb target
# EXPORT: Exports the target for use by other projects
# LIBRARY: Installs shared libraries (.so, .dylib) to the specified directory
# ARCHIVE: Installs static libraries (.a, .lib) to the specified directory
# RUNTIME: Installs DLLs on Windows to the specified directory
# INCLUDES: Sets the include directories for dependencies
#
# The paths use variables from GNUInstallDirs:
# - CMAKE_INSTALL_LIBDIR: typically 'lib' or 'lib64'
# - CMAKE_INSTALL_BINDIR: typically 'bin'
# - CMAKE_INSTALL_INCLUDEDIR: typically 'include'
install(TARGETS libsdb
    EXPORT sdb-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install the header files from the project's include directory to the system's include directory.
# This enables other projects to include our headers when using our library.
# The '/' at the end of ${PROJECT_SOURCE_DIR}/include/ is important:
# - With '/': copies contents of the directory
# - Without '/': copies the directory itself
install(
    DIRECTORY ${PROJECT_SOURCE_DIR}/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install the export configuration for the sdb library.
# This creates a CMAKE configuration file (sdb-config.cmake) that allows other
# CMake projects to find and use the sdb library through find_package(sdb).
#
# The export name "sdb-targets" should match the one used in the export() command elsewhere in the build.
# The NAMESPACE parameter adds a prefix "sdb::" to all exported targets.
# The DESTINATION specifies where to install the config file, in this case to a standard
# location under ${CMAKE_INSTALL_LIBDIR}/cmake/sdb, where other CMake projects can find it.
install(
    EXPORT sdb-targets
    FILE sdb-config.cmake
    NAMESPACE sdb::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/sdb
)

