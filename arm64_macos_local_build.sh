#!/bin/bash
# Build script for OR-Tools ARM64 macOS using CMake

set -e

echo "Building OR-Tools for ARM64 macOS using CMake..."

# Clean previous build if it exists
if [ -d "build_arm64" ]; then
    echo "Cleaning previous build directory..."
    rm -rf build_arm64
fi

# Create build directory
mkdir -p build_arm64

# Configure the build
echo "Configuring build..."
cmake -S. -Bbuild_arm64 \
    -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_DEPS=ON \
    -DCMAKE_INSTALL_PREFIX=install_arm64 \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_OSX_ARCHITECTURES=arm64

# Build the project
echo "Building OR-Tools..."
cmake --build build_arm64 \
    --config Release \
    --target all \
    -v -j$(sysctl -n hw.ncpu)

# Run tests
#echo "Running tests..."
#cd build_arm64
#CTEST_OUTPUT_ON_FAILURE=1 ctest --config Release -V

# Install
echo "Installing OR-Tools..."
#cd ..
cmake --build build_arm64 \
    --config Release \
    --target install \
    -v

echo "Build completed successfully!"
echo "OR-Tools has been built and installed in the install_arm64 directory."

# archive the output
echo "Creating archive of the build..."
tar -czf or-tools_arm64_macos.tar.gz -C build_arm64 install_arm64
echo "Archive created: or-tools_arm64_macos.tar.gz"
