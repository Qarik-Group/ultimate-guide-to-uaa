# Playtime with UAA

## Install uaa CLI

There is a nice new [UAA CLI](https://github.com/cloudfoundry-incubator/uaa-cli). At the time of writing, the only method for installation is:

```
go get -u github.com/cloudfoundry-incubator/uaa-cli
cd $GOPATH/src/github.com/cloudfoundry-incubator/uaa-cli
make && make install
uaa -h
```

## Spin up UAA

See https://github.com/starkandwayne/uaa-deployment to deploy UAA locally via VirtualBox or to any cloud:

```
uaa-deployment up
uaa-deployment auth
uaa-deployment info
```

## Play time

```
uaa create-client uaa-cli-authcode -s uaa-cli-authcode \
  --authorized_grant_types authorization_code,refresh_token \
  --redirect_uri http://localhost:9876 \
  --scope openid
```

```
uaa get-authcode-token uaa-cli-authcode -s uaa-cli-authcode --port 9876
```

```
Launching browser window to https://drnic-uaa.starkandwayne.com:8443/oauth/authorize?client_id=uaa-cli-authcode&redirect_uri=http%3A%2F%2Flocalhost%3A9876&response_type=code where the user should login and grant approvals
Starting local HTTP server on port 9876
Waiting for authorization redirect from UAA...
```

![uaa-app-auth-ack](images/uaa-app-auth-ack.png)

After clicking "Authorize" the browser changes to:

![uaa-app-auth-success](images/uaa-app-auth-success.png)

More importantly, our `uaa get-authcode-token` command has automatically now completed:

```
Local server received request to GET /?code=xfnUz8RUON
Calling UAA /oauth/token to exchange code xfnUz8RUON for an access token
Stopping local HTTP server on port 9876
Access token added to active context.
```
