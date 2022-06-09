FROM debian:latest

ARG USER=ellipsis
ARG UID=1000
ARG GID=1000
ARG APT_PACKAGES="build-essential curl git wget unzip bash bash-completion sudo"
ARG APT_PACKAGES_EXTRA="tree vim bsdmainutils"
#ARG ELLIPSIS_PATH="${ELLIPSIS_PATH:-/home/${USER}/.ellipsis}"
ARG ELLIPSIS_PATH="/ellipsis"

# Prepare context image
RUN useradd -m ${USER} --uid=${UID}
RUN apt-get update && apt-get install -y sudo $APT_PACKAGES $APT_PACKAGES_EXTRA && \
    rm -rf /var/lib/apt/lists/* && \
    adduser ${USER} sudo && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user_admin

# Copy source code
COPY . $ELLIPSIS_PATH
# TOFIX: We cannot exactly set this as RO, because of tests
RUN chown -R $UID:$GID $ELLIPSIS_PATH

# Prepare environment
USER ${UID}:${GID}
WORKDIR /home/${USER}
ENV ELLIPSIS_PATH="$ELLIPSIS_PATH"
ENV ELLIPSIS_MANAGE_SHELL=true
CMD make -C "$ELLIPSIS_PATH" test

