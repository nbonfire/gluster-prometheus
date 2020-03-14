#!/bin/bash

TAR="tar"
GOPATH=$(go env GOPATH)
GOBINDIR=$GOPATH/bin
INSTALL_GOLANGCILINT=${INSTALL_GOLANGCILINT:-yes}


install_tools_darwin() {
  if type brew >/dev/null 2>&1; then
    echo "brew is already installed"
  else
    echo "Installing brew."
    mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
  fi

  if type gtar >/dev/null 2>&1; then
    echo "gnu-tar (gtar) is already installed"
  else
    echo "Installing gnu-tar."
    brew install gnu-tar
  fi

  TAR="gtar"
}

bootstrap_platform() {
  case "$OSTYPE" in
    solaris*) echo "SOLARIS" ;;
    darwin*)  echo "OSX" ; install_tools_darwin ;;
    linux*)   echo "LINUX" ;;
    bsd*)   echo "BSD" ;;
    msys*)  echo "WINDOWS" ;;
    *)  echo "unknown: $OSTYPE" ;;
  esac
}

install_dep() {
  DEPVER="v0.5.0"
  DEPURL="https://github.com/golang/dep/releases/download/${DEPVER}/dep-linux-amd64"
  if type dep >/dev/null 2>&1; then
    local version
    version=$(dep version | awk '/^ version/{print $3}')
    if [[ $version == "$DEPVER" || $version >  $DEPVER ]]; then
      echo "dep ${DEPVER} or greater is already installed"
      return
    fi
  fi

  echo "Installing dep. Version: ${DEPVER}"
  DEPBIN=$GOPATH/bin/dep
  curl -L -o "$DEPBIN" $DEPURL
  chmod +x "$DEPBIN"
}

install_golangcilint() {

  echo "Installing golangci-lint."
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.23.8

}

bootstrap_platform
install_dep
if [ "$INSTALL_GOLANGCILINT" == "yes" ];then
    install_golangcilint
fi
