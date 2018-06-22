# UAA deployment

This project is dedicated to making it easy to bring up UAA on a single VM locally or on any cloud supported by BOSH. You do not need to have BOSH already installed; instead we use the standalone `bosh create-env` command.

This means the project uses pre-compiled BOSH releases so that `bosh create-env` is much faster.

```plain
bosh create-env bosh.yml \
  -o uaa.yml \
  -o virtualbox/cpi.yml \
  -o virtualbox/outbound-network.yml \
  -o jumpbox-user.yml \
  -v director_name=bosh-lite \
  -v internal_ip=192.168.50.6 \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork \
  --vars-store ./tmp/creds.yml \
  -o <(tmp/remove-bosh.sh)
```
