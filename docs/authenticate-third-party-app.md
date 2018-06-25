The web interface above is the UAA itself. As a user (such as `admin`), you can login. That is, you can authenticate that you are `admin`, or later when we create more users you can authenticate that you are one of those users. Conceptually, each human knows how to authenticate as a single UAA user.

The `uaa` CLI is a separate application from the UAA. The UAA refers to third-party applications as "clients". We want to configure this separate application to target our UAA, to authenticate as a valid application, and to interact with the UAA's API.

That the `uaa` CLI has a similar name to the UAA API server is confusing. The `uaa` CLI is just one of infinite applications that might want to interact with the UAA API - either directly as a client, or on behalf of the UAA's users.

For convenience the `uaa-deployment auth` command will target and authentication with your UAA:

```
uaa-deployment auth-client
```

Alternately, you can run the `uaa` commands directly:

```
uaa target https://192.168.50.6:8443 --skip-ssl-validation
uaa get-client-credentials-token uaa_admin -s <uaa_admin_client_secret>
```

This time we use the client/client_secret values. We are giving the `uaa` application permission to interact with the UAA API as a peer: one application talking to another application. It has access to all users' data, albeit potentially scoped by functionality (e.g. it mightt be able to list all user information but not be able to modify them). We will discuss scoping in future.

You can now use the `uaa` CLI to interact with your UAA.

To see a list of user accounts in JSON:

```
uaa list-users
```

You can filter the attributes of each user:

```
uaa list-users --attributes id,userName
```

To view a user called `admin`:

```
uaa list-users | jq -r ".resources[] | select(.userName == \"admin\")"
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

uaa list-clients | jq -r ".[] | {client_id, authorized_grant_types, scope, authorities}"
```

We've introduced one client so far - `uaa_admin` - which we're using currently to allow the `uaa` CLI application to talk to the UAA API. To view its configuraton:

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

We have authenticated our `uaa` CLI application  as client `uaa_admin` so we should be able to ask "who am I?":

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

