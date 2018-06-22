# UAA deployment

This project is dedicated to making it easy to bring up UAA on a single VM locally or on any cloud supported by BOSH. You do not need to have BOSH already installed; instead we use the standalone `bosh create-env` command.

This means the project uses pre-compiled BOSH releases so that `bosh create-env` is much faster.

```plain
git submodule update --init
mkdir state
bosh create-env src/bosh-deployment/bosh.yml \
  -o src/bosh-deployment/virtualbox/cpi.yml \
  -o src/bosh-deployment/virtualbox/outbound-network.yml \
  -o src/bosh-deployment/uaa.yml \
  -o src/bosh-deployment/jumpbox-user.yml \
  -v director_name=bosh-lite \
  -v internal_ip=192.168.50.6 \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork \
  --vars-store ./state/creds.yml \
  --state ./state/state.json \
  -o <(./remove-bosh.sh)
```
