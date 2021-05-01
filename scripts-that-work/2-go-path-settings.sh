#!/bin/bash
# ./2-go-path-settings.sh go-workspace

echo 'export GOPATH="$HOME/go"' >> ~/.profile
echo 'export GOBIN="$GOPATH/bin"' >> ~/.profile
echo 'export PATH="$GOBIN:$PATH"' >> ~/.profile

echo "Now run . ~/.profile (or . ~/.bashrc if the first didn't work)"
