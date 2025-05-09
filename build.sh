cmake -S . -B build \
      -DCMAKE_INSTALL_PREFIX=`pwd`/install \
      -DCMAKE_TOOLCHAIN_FILE=`pwd`/vcpkg/scripts/buildsystems/vcpkg.cmake \
      --fresh
cmake --build build
cmake --install build
