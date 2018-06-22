# UAA deployment

This project is dedicated to making it easy to bring up UAA on a single VM locally or on any cloud supported by BOSH. You do not need to have BOSH already installed; instead we use the standalone `bosh create-env` command.

This project is hugely influenced by, and code/files copied from, [BUCC](https://github.com/starkandwayne/com).

Also check out the [in-progress walk thru guide](docs/README.md) to using `uaa-deployment` to learn about the UAA, client applications, and users.

To bootstrap UAA inside VirtualBox:

```plain
uaa-deployment up
```

To bootstrap UAA on AWS:

```plain
uaa-deployment up --cpi aws
```

To target and authorize the [`uaa` CLI](https://github.com/cloudfoundry-incubator/uaa-cli):

```plain
uaa-deployment auth
```

To target and authorize the older `uaac` CLI:

```plain
uaa-deployment uaac
```

