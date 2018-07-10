# Install `uaa` CLI

There is a nice new [UAA CLI](https://github.com/cloudfoundry-incubator/uaa-cli) `uaa` that interacts with the UAA and returns JSON.

## MacOS/Homebrew

```text
brew install starkandwayne/cf/uaa-cli
uaa -h
```

## Debian/Ubuntu

Instructions also at http://apt.starkandwayne.com/

```text
wget -q -O - https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key | apt-key add -
echo "deb http://apt.starkandwayne.com stable main" | tee /etc/apt/sources.list.d/starkandwayne.list
apt-get update

apt-get install uaa-cli
uaa -h
```

## Install from source

After installing Golang, download and build the `uaa-cli` project:

```text
go get -u github.com/cloudfoundry-incubator/uaa-cli
cd $GOPATH/src/github.com/cloudfoundry-incubator/uaa-cli
make && make install
uaa -h
```
