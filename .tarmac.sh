#!/bin/sh

set -ev

export GOPATH=$(mktemp -d)
trap 'rm -rf "$GOPATH"' EXIT

echo Checking formatting
fmt=$(gofmt -l .)

if [ -n "$fmt" ]; then
    echo "Formatting wrong in following files"
    echo $fmt
    exit 1
fi

echo Installing godeps
go get launchpad.net/godeps
echo Install golint
go get github.com/golang/lint/golint
export PATH=$PATH:$GOPATH/bin

echo Obtaining dependencies
godeps -u dependencies.tsv

# this is a hack, but not sure tarmac is golang friendly
mkdir $GOPATH/src/launchpad.net/snappy

cp -r . $GOPATH/src/launchpad.net/snappy/
cd $GOPATH/src/launchpad.net/snappy

echo Building
go build -v launchpad.net/snappy/...

echo Running tests from $(pwd)
go test ./...

echo Running lint
# FIXME: get rid of the "grep" below
lint=$(golint ./...|grep -v "should have comment or be unexported")
if [ -n "$lint" ]; then
    echo "Lint complains:"
    echo $lint
    exit 1
fi

