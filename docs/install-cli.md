# Install `uaa` CLI

There is a nice new [UAA CLI](https://github.com/cloudfoundry-incubator/uaa-cli) `uaa` that interacts with the UAA and returns JSON.

At the time of writing, the only method for installation is via Golang.

1. Install Golang and setup `$GOROOT` and `$GOPATH`
1. Download and build `uaa`:

    ```shell
    go get -u github.com/cloudfoundry-incubator/uaa-cli
    cd $GOPATH/src/github.com/cloudfoundry-incubator/uaa-cli
    make && make install
    uaa -h
    ```