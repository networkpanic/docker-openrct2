# syntax=docker/dockerfile:1.2

# Build OpenRCT2
FROM alpine:latest AS build-env
ENV OPENRCT2_REF v0.3.3

RUN apk add --no-cache git gcc g++ make cmake duktape-dev nlohmann-json libzip-dev curl-dev libressl-dev sdl2-dev speexdsp-dev fontconfig-dev fts-dev icu-dev musl-dev linux-headers

WORKDIR /openrct2
RUN git -c http.sslVerify=false clone --depth 1 -b $OPENRCT2_REF https://github.com/OpenRCT2/OpenRCT2 . \
 && mkdir build \
 && cd build \
 && cmake .. -DCMAKE_CXX_COMPILER=/usr/bin/g++ -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/openrct2-install/usr -DCMAKE_INSTALL_LIBDIR=/openrct2-install/usr/lib -DDISABLE_OPENGL=ON \
 && make -j4 install \
 && rm /openrct2-install/usr/lib/libopenrct2.a

# Build runtime image
FROM alpine:latest
COPY --from=build-env /openrct2-install /openrct2-install
RUN apk add --no-cache rsync ca-certificates libpng libzip libcurl duktape freetype fontconfig icu \
 && rsync -a /openrct2-install/* / \
 && rm -rf /openrct2-install \
 && openrct2-cli --version \
# Set up ordinary user
 && addgroup -g 1000 -S openrct2 && adduser -G openrct2 -u 1000 -DS openrct2
USER openrct2
WORKDIR /home/openrct2
EXPOSE 11753

# Test run and scan
RUN openrct2-cli --version \
 && openrct2-cli scan-objects

ARG PARK
ARG PORT
# Done
ENTRYPOINT ["sh", "-c", "openrct2-cli host $(save='/home/openrct2/.config/OpenRCT2/save'; autosave=$(ls -t1 $save/autosave | head -n 1); [ -z $autosave ] && echo $save/$PARK.sv6 || echo $save/autosave/$autosave)"]
