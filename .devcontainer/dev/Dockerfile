# See here for image contents: https://github.com/devcontainers/images/tree/main/src/python
# Available image variants: https://github.com/devcontainers/templates/blob/main/src/python/devcontainer-template.json
ARG VARIANT="3"
FROM mcr.microsoft.com/devcontainers/python:1-${VARIANT}

# Create directory and set permission.
RUN mkdir -p /home/vscode/zephyr \
    && mkdir -p /home/vscode/zephyr/dev \
    && chown -R vscode:vscode /home/vscode/zephyr

# Developing with Zephyr >> Getting Started Guide
# https://docs.zephyrproject.org/latest/develop/getting_started/index.html

# Install Zephyr SDK dependencies.
# https://docs.zephyrproject.org/latest/develop/getting_started/index.html#install-dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git cmake ninja-build gperf \
        ccache dfu-util device-tree-compiler wget \
        python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
        make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1
RUN pip3 --disable-pip-version-check --no-cache-dir install --upgrade west

# Download and install a packaged cmake from the CMake project site.
# https://docs.zephyrproject.org/latest/develop/getting_started/installation_linux.html#cmake
# Available CMake versions: https://github.com/Kitware/CMake/releases
ARG CMAKE_VERSION="3.21.1"
RUN mkdir -p /tmp/cmake-tmp \
    && cd /tmp/cmake-tmp \
    && wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    && chmod +x cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    && ./cmake-${CMAKE_VERSION}-Linux-x86_64.sh --skip-license --prefix=/usr/local \
    && hash -r \
    && rm -rf /tmp/cmake-tmp
    
WORKDIR /home/vscode/zephyr
USER vscode

# Get Zephyr and install Python dependencies
# https://docs.zephyrproject.org/latest/develop/getting_started/index.html#get-zephyr-and-install-python-dependencies
ARG MANIFEST_REVISION="main"
RUN west init --mr ${MANIFEST_REVISION} && west update && west zephyr-export
RUN west packages pip --install --ignore-venv-check

# Install Zephyr SDK
# https://docs.zephyrproject.org/latest/develop/getting_started/index.html#install-the-zephyr-sdk
ENV ZEPHYR_SDK_DIR=/home/vscode/zephyr/zephyr-sdk
RUN cd zephyr && west sdk install -d ${ZEPHYR_SDK_DIR} -t arm-zephyr-eabi

# Install Node.js and microbit-universal-hex
ARG NODE_VERSION="lts/*"
RUN umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1
RUN npm install @microbit/microbit-universal-hex

USER root

# Setup tools for USB access and permission control in WSL2 with usbipd-win
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends usbutils
COPY ./dev/scripts/ /home/vscode/zephyr/dev/scripts/
RUN chmod -R +x /home/vscode/zephyr/dev/scripts \
    && chown -R vscode:vscode /home/vscode/zephyr/dev/scripts
