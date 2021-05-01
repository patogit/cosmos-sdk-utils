#!/bin/bash
# ./2-go-path-settings.sh go-workspace

GODIRECTORY=$1

export GOROOT=/usr/lib/go
export GOPATH=${HOME}/$GODIRECTORY
export GOBIN=$GOPATH/bin
export PATH=${PATH}:${GOROOT}/bin:${GOBIN}

echo "Now run . ~/.profile (or . ~/.bashrc if the first didn't work)"
