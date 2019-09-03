# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2017 Lukas Rusak (lrusak@libreelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2019 Trond Haugland (trondah@gmail.com)

PKG_NAME="docker-oem"
PKG_VERSION="19.03.1"
PKG_SHA256="dad9123e203751ce9981bc34773721593655231c32412e310e748b18f10f0053"
PKG_GIT_COMMIT="74b1e89e8ac68948be88fe0aa1e2767ae28659fe"
PKG_ARCH="any"
PKG_ADDON_PROJECTS="any !WeTek_Core !WeTek_Play"
PKG_LICENSE="ASL"
PKG_SITE="http://www.docker.com/"
PKG_URL="https://github.com/docker/docker-ce/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain sqlite go:host containerd runc libnetwork tini systemd"
PKG_SECTION="escalade"
PKG_SHORTDESC="Docker is an open-source engine that automates the deployment of any application as a lightweight, portable, self-sufficient container that will run virtually anywhere."
PKG_LONGDESC="Docker containers can encapsulate any payload, and will run consistently on and between virtually any server. The same container that a developer builds and tests on a laptop will run at scale, in production*, on VMs, bare-metal servers, OpenStack clusters, public instances, or combinations of the above."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-lto"

configure_target() {
  export DOCKER_BUILDTAGS="daemon \
                           autogen \
                           exclude_graphdriver_devicemapper \
                           exclude_graphdriver_aufs \
                           journald"

  case $TARGET_ARCH in
    x86_64)
      export GOARCH=amd64
      ;;
    arm)
      export GOARCH=arm

      case $TARGET_CPU in
        arm1176jzf-s)
          export GOARM=6
          ;;
        *)
          export GOARM=7
          ;;
      esac
      ;;
    aarch64)
      export GOARCH=arm64
      ;;
  esac

  export GOOS=linux
  export CGO_ENABLED=1
  export CGO_NO_EMULATION=1
  export CGO_CFLAGS=$CFLAGS
  export LDFLAGS="-w -linkmode external -extldflags -Wl,--unresolved-symbols=ignore-in-shared-libs -extld $CC"
  export GOLANG=$TOOLCHAIN/lib/golang/bin/go
  export GOPATH=$PKG_BUILD/.gopath_cli:$PKG_BUILD/.gopath
  export GOROOT=$TOOLCHAIN/lib/golang
  export PATH=$PATH:$GOROOT/bin

  mkdir -p $PKG_BUILD/.gopath
  mkdir -p $PKG_BUILD/.gopath_cli

  PKG_ENGINE_PATH=$PKG_BUILD/components/engine
  PKG_CLI_PATH=$PKG_BUILD/components/cli

  if [ -d $PKG_ENGINE_PATH/vendor ]; then
    mv $PKG_ENGINE_PATH/vendor $PKG_BUILD/.gopath/src
  fi

  if [ -d $PKG_CLI_PATH/vendor ]; then
    mv $PKG_CLI_PATH/vendor $PKG_BUILD/.gopath_cli/src
  fi

  # Fix missing/incompatible .go files
  cp -rf $PKG_BUILD/.gopath/src/github.com/moby/buildkit/frontend/* $PKG_BUILD/.gopath_cli/src/github.com/moby/buildkit/frontend
  cp -rf $PKG_BUILD/.gopath/src/github.com/moby/buildkit/frontend/gateway/* $PKG_BUILD/.gopath_cli/src/github.com/moby/buildkit/frontend/gateway
  cp -rf $PKG_BUILD/.gopath/src/github.com/moby/buildkit/solver/* $PKG_BUILD/.gopath_cli/src/github.com/moby/buildkit/solver
  cp -rf $PKG_BUILD/.gopath/src/github.com/moby/buildkit/util/progress/* $PKG_BUILD/.gopath_cli/src/github.com/moby/buildkit/util/progress
  cp -rf $PKG_BUILD/.gopath/src/github.com/docker/swarmkit/manager/* $PKG_BUILD/.gopath_cli/src/github.com/docker/swarmkit/manager
  cp -rf $PKG_BUILD/.gopath/src/github.com/coreos/etcd/raft/* $PKG_BUILD/.gopath_cli/src/github.com/coreos/etcd/raft
  cp -rf $PKG_BUILD/.gopath/src/golang.org/x/* $PKG_BUILD/.gopath_cli/src/golang.org/x
  cp -rf $PKG_BUILD/.gopath/src/github.com/opencontainers/runtime-spec/specs-go/* $PKG_BUILD/.gopath_cli/src/github.com/opencontainers/runtime-spec/specs-go

  rm -rf $PKG_BUILD/.gopath_cli/src/github.com/containerd/containerd
  mkdir -p $PKG_BUILD/.gopath_cli/src/github.com/containerd/containerd
  cp -rf $PKG_BUILD/.gopath/src/github.com/containerd/containerd/* $PKG_BUILD/.gopath_cli/src/github.com/containerd/containerd

  rm -rf $PKG_BUILD/.gopath_cli/src/github.com/containerd/continuity
  mkdir -p $PKG_BUILD/.gopath_cli/src/github.com/containerd/continuity
  cp -rf $PKG_BUILD/.gopath/src/github.com/containerd/continuity/* $PKG_BUILD/.gopath_cli/src/github.com/containerd/continuity

  mkdir -p $PKG_BUILD/.gopath_cli/src/github.com/docker/docker/builder
  cp -rf $PKG_ENGINE_PATH/builder/* $PKG_BUILD/.gopath_cli/src/github.com/docker/docker/builder

  if [ ! -L $PKG_BUILD/.gopath/src/github.com/docker/docker ];then
    ln -fs $PKG_ENGINE_PATH $PKG_BUILD/.gopath/src/github.com/docker/docker
  fi

  if [ ! -L $PKG_BUILD/.gopath_cli/src/github.com/docker/cli ];then
    ln -fs $PKG_CLI_PATH $PKG_BUILD/.gopath_cli/src/github.com/docker/cli
  fi

  # used for docker version
  export GITCOMMIT=${PKG_GIT_COMMIT}
  export VERSION=${PKG_VERSION}
  export BUILDTIME="$(date --utc)"

  cd $PKG_ENGINE_PATH
  bash hack/make/.go-autogen
  cd $PKG_BUILD
}

make_target() {
  mkdir -p bin
  PKG_CLI_FLAGS="-X 'github.com/docker/cli/cli/version=${VERSION}'"
  PKG_CLI_FLAGS="${PKG_CLI_FLAGS} -X 'github.com/docker/cli/cli/version.GitCommit=${GITCOMMIT}'"
  PKG_CLI_FLAGS="${PKG_CLI_FLAGS} -X 'github.com/docker/cli/cli/version.BuildTime=${BUILDTIME}'"
  $GOLANG build -v -o bin/docker -a -tags "$DOCKER_BUILDTAGS" -ldflags "$LDFLAGS ${PKG_CLI_FLAGS}" ./components/cli/cmd/docker
  $GOLANG build -v -o bin/dockerd -a -tags "$DOCKER_BUILDTAGS" -ldflags "$LDFLAGS" ./components/engine/cmd/dockerd
}

makeinstall_target() {
  mkdir -p $INSTALL/etc
  mkdir -p $INSTALL/usr/bin
  mkdir -p $INSTALL/usr/config
  ln -sf /storage/.config/docker $INSTALL/etc/docker
  cp bin/docker $INSTALL/usr/bin
  cp bin/dockerd $INSTALL/usr/bin
  cp $PKG_DIR/scripts/* $INSTALL/usr/bin
  cp -R $PKG_DIR/config/* $INSTALL/usr/config

  # containerd
  cp -P $(get_build_dir containerd)/bin/containerd $INSTALL/usr/bin/containerd
  cp -P $(get_build_dir containerd)/bin/containerd-shim $INSTALL/usr/bin/containerd-shim

  # libnetwork
  cp -P $(get_build_dir libnetwork)/bin/docker-proxy $INSTALL/usr/bin/docker-proxy

  # runc
  cp -P $(get_build_dir runc)/bin/runc $INSTALL/usr/bin/runc

  # tini
  cp -P $(get_build_dir tini)/.$TARGET_NAME/tini-static $INSTALL/usr/bin/docker-init
}
