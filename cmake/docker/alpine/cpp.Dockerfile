FROM ortools/cmake:alpine_base AS env

# Configure ccache for faster builds
ENV CCACHE_DIR=/root/.ccache
ENV CCACHE_MAXSIZE=2G
ENV CCACHE_COMPRESS=1
ENV CCACHE_COMPRESSLEVEL=6

RUN cmake -version

FROM env AS devel
WORKDIR /home/project
COPY . .

FROM devel AS build
RUN cmake -S. -Bbuild \
    -DBUILD_DEPS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DBUILD_PYTHON=OFF \
    -DBUILD_JAVA=OFF \
    -DBUILD_DOTNET=OFF \
    -DBUILD_SAMPLES=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DCMAKE_CXX_FLAGS="-O3 -DNDEBUG" \
    -DCMAKE_C_FLAGS="-O3 -DNDEBUG"
RUN --mount=type=cache,target=/home/project/build \
    --mount=type=cache,target=/root/.ccache \
    cmake --build build --target all -j$(nproc) --config Release
RUN cmake --build build --target install

FROM build AS test
RUN CTEST_OUTPUT_ON_FAILURE=1 cmake --build build --target test -- -j$(nproc)

FROM env AS install_env
COPY --from=build /usr/local /usr/local/

FROM install_env AS install_devel
WORKDIR /home/sample
COPY cmake/samples/cpp .

FROM install_devel AS install_build
RUN --mount=type=cache,target=/home/sample/build \
    cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release
RUN --mount=type=cache,target=/home/sample/build \
    cmake --build build --target all -j$(nproc) --config Release
RUN cmake --build build --target install

FROM install_build AS install_test
RUN cmake --build build --target test -- -j$(nproc)
