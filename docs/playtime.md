# Playtime with UAA

## Install uaa CLI

There is a nice new [UAA CLI](https://github.com/cloudfoundry-incubator/uaa-cli) `uaa` that interacts with the UAA and returns JSON.

At the time of writing, the only method for installation is:

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
```

Once our UAA is running we can view the target URL and some admin-level authentication:

```
uaa-deployment info
```

The output might look like:

```
UAA:
  url: https://192.168.50.6:8443
  client: uaa_admin
  client_secret: nnb2tbev0j82gxdz65xc
  username: admin
  password: 2rbaswzllkuy51ymzahz
```

Visit the URL and you will be redirected to the `/login` page:

![uaa-web-user-login](images/uaa-web-user-login.png)

Try to login with both pairs of credentials - client/client_secret, and username/password.

You will discover that you cannot authenticate with client/client_secret. These are not user credentials.

Rather they are credentials for an application to talk to the UAA API - either on behalf of itself (say, to register new UAA users or new UAA clients), or on behalf of a UAA user (say, to ask for the user's personal information, or their authorized permissions within the organization).

Succesfully logging in with the `admin` username/password will look like:

![uaa-web-user-success](images/uaa-web-user-success.png)

You'll see a corporate logo (the default is "Cloud Foundry"), the title "Where to?", and .... a void of emptiness. This homepage of the UAA can be filled with "tiles" - icons/names for your internal corporate applications that users can possible use. We will revisit this later.

## Authenticating a third-party application

The web interface above is the UAA itself. As a user (such as `admin`), you can login. That is, you can authenticate that you are `admin`, or later when we create more users you can authenticate that you are one of those users. Conceptually, each human knows how to authenticate as a single UAA user.

The `uaa` CLI is a separate application from the UAA. The UAA refers to third-party applications as "clients". We want to configure this separate application to target our UAA, to authenticate as a valid application, and to interact with the UAA's API.

For convenience the `uaa-deployment auth` command will target and authentication with your UAA:

```
uaa-deployment auth-client
```

Alternately, you can run the `uaa` commands directly:

```
uaa target https://192.168.50.6:8443 --skip-ssl-validation
uaa get-client-credentials-token uaa_admin -s nnb2tbev0j82gxdz65xc
```

This time we use the client/client_secret values. We are giving the `uaa` application permission to interact with the UAA API as a peer: one application talking to another application.

You can now use the `uaa` CLI to interact with your UAA.

To see a list of user accounts in JSON:

```
uaa list-users
```

You can filter the attributes of each user:

```
uaa list-users --attributes id,userName
```

To see the various scopes that the `admin` user is allowed to access:

```
uaa list-users | jq -r ".resources[] | select(.userName == \"admin\").groups[].display"
```

The output might look like:

```
user_attributes
roles
scim.me
uaa.user
cloud_controller.write
cloud_controller.read
approvals.me
openid
uaa.offline_token
password.write
bosh.admin
oauth.approvals
profile
notification_preferences.write
notification_preferences.read
cloud_controller_service_permissions.read
```

To see the list of groups in JSON:

```
uaa list-groups
uaa list-groups | jq -r ".resources[].displayName" | sort
```

As a logged in user - by any of the authentication commands - we potentially can ask the UAA "who am I?"

To see a list of application clients in JSON:

```
uaa list-clients

uaa list-clients | jq -r ".[] | {client_id, authorized_grant_types, scope}"
```

We've introduced one client so far - `uaa_client` - which we're using currently to allow the `uaa` CLI application to talk to the UAA API. To view its configuraton:

```
uaa get-client uaa_admin
```

The output might look like:

```json
{
  "client_id": "uaa_admin",
  "scope": [
    "uaa.none"
  ],
  "resource_ids": [
    "none"
  ],
  "authorized_grant_types": [
    "client_credentials"
  ],
  "authorities": [
    "clients.read",
    "password.write",
    "clients.secret",
    "clients.write",
    "uaa.admin",
    "scim.write",
    "scim.read"
  ],
  "lastModified": 1529652956499
}
```

We have authenticated our `uaa` application so we should be able to ask "who am I?":

```
uaa userinfo
```

This command fails, so run the command again with `--verbose` to see the error message:

```
uaa userinfo --verbose
```

The output will include an error:

```
GET /userinfo?scheme=openid HTTP/1.1
...
{"error":"access_denied","error_description":"Invalid token does not contain resource id (openid)"}
```

The reason we cannot invoke `uaa userinfo` is that we are currently authenticated as a client, not on behalf of a user.

That is, the `uaa` application is talking directly to the UAA - one application to another. Peers.

The `uaa userinfo` command assumes that the `uaa` application is talking to the UAA on behalf of an authenticated user.

## Authenticating on behalf of a user - via local password

```
uaa create-client our_uaa_cli -s our_uaa_cli_secret \
  --authorized_grant_types password,refresh_token \
  --scope "openid,bosh.admin,bosh.read,bosh.*.admin,bosh.*.read"  \
  --authorities uaa.none \
  --access_token_validity 120 \
  --refresh_token_validity 86400
```

A user can now provide the `uaa` CLI permission to interact with the UAA on its behalf:

```
uaa get-password-token uaa_cli -s uaa_cli_secret -u admin -p 2rbaswzllkuy51ymzahz
```

To demonstrate that the `uaa` is now operating on behalf of the `admin` user:

```
uaa userinfo
```

The JSON output will be like:

```json
{
  "user_id": "4a7e6e3d-e39c-43f9-9c98-6052eb63109a",
  "sub": "4a7e6e3d-e39c-43f9-9c98-6052eb63109a",
  "user_name": "admin",
  "given_name": "",
  "family_name": "",
  "email": "admin",
  "phone_number": null,
  "previous_logon_time": 1529658329563,
  "name": " "
}
```


## Authenticating on behalf of a user - via web UI

First, register a new UAA client that is designed to allow the `uaa` to be used by normal UAA users.

```
uaa create-client uaa-cli-authcode -s uaa-cli-authcode \
  --authorized_grant_types authorization_code,refresh_token \
  --redirect_uri http://localhost:9876 \
  --scope openid
```

Now, to allow a user to authenticate:

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

Running `uaa get-authcode-token` again will automatically authenticate the user via the browser:

```
uaa get-authcode-token uaa-cli-authcode -s uaa-cli-authcode --port 9876
```

The `uaa` CLI is now acting on behalf of a user.


To add more scopes to a client, first get the current scopes:

```
uaa get-client admin
uaa get-client admin | jq -r ".scope | join(\",\")"
```

And update a new `scope` as a comma-separated list:

```
uaa update-client admin --scope uaa.none,openid
```