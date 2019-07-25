# UAA and Client Apps

![uaa-web-user-login](images/uaa-web-user-login.png)

The web interface above is the UAA itself. As a user (such as `admin`), you can login. That is, you can authenticate that you are `admin`, or later when we create more users you can authenticate that you are one of those users. Conceptually, each human knows how to authenticate as a single UAA user.

The UAA also has an API thru which all functionality is available. The UI by comparison only supports a small subset of behavior for users.

```text
curl -k  -H 'Accept: application/json' https://192.168.50.6:8443/info
```

The output will look similar to:

```json
{
  "app": {
    "version": "4.7.4"
  },
  "links": {
    "uaa": "https://192.168.50.6:8443",
    "passwd": "/forgot_password",
    "login": "https://192.168.50.6:8443",
    "register": "/create_account"
  },
  "zone_name": "uaa",
  "entityID": "192.168.50.6:8443",
  "commit_id": "6502d3b",
  "idpDefinitions": {},
  "prompts": {
    "username": [
      "text",
      "Email"
    ],
    "password": [
      "password",
      "Password"
    ]
  },
  "timestamp": "2018-01-09T13:15:31-0800"
}
```

## Client Apps

The `uaa` CLI installed earlier is not the UAA.

The `uaa` CLI is a separate application from the UAA. The UAA refers to third-party applications as "clients". Client applications might be CLIs, web applications, mobile applications, CI/CD pipelines, or similar. They might be authored and published by well-known trusted parties (for example, the `uaa` CLI is written by the same Cloud Foundry team who have written the UAA itself) or by unknown parties.

The allow the system administrator of your UAA (today, this is you) to keep track of which UAA clients might be interacting with your UAA and associated client applications, to allow you to constrain them to the least privilege that they require, and to ultimate revoke their privileges at a later stage, you will want to allocate unique permissions to each third-party client application.

## Client Credentials

The `uaa` CLI is an administrator tool for the UAA, so it needs to be granted permissions to access the UAA API, but does not need permissions for accessing other UAA client applications (such as Cloud Foundry, BOSH, CredHub, or your own UAA client web applications).

For this purpose your deployed UAA has been pre-configured with the `uaa_admin` UAA client, whose client secret was disclosed to you via the `uaa-deployment info` command earlier. The example output was:

```text
UAA:
  url: https://192.168.50.6:8443
  client: uaa_admin
  client_secret: nnb2tbev0j82gxdz65xc
  username: admin
  password: 2rbaswzllkuy51ymzahz
```

To target your UAA and authenticate as the `uaa_admin` client:

```text
uaa target https://192.168.50.6:8443 --skip-ssl-validation
uaa get-client-credentials-token uaa_admin -s <uaa_admin_client_secret>
```

This time we use the client/client_secret values. We are giving the `uaa` application permission to interact with the UAA API as a peer: one application talking to another application. It has access to all users' data, albeit potentially scoped by functionality (e.g. it might be able to list all user information but not be able to modify them). We will discuss scoping in future.

For your future convenience the `uaa-deployment auth-client` command will perform the same commands to target and authentication with your UAA as the `uaa_admin` UAA admininistrator client, without you needing to copy/paste the client secret:

```text
uaa-deployment auth-client
```

That the `uaa` CLI has a similar name to the UAA API server is confusing. The `uaa` CLI is just one of infinite applications that might want to interact with the UAA API - either directly as a client application, or as a client application on behalf of one the UAA's users (who are introduced in the next section).

Another example UAA client is the Cloud Foundry API (internally known as the Cloud Controller) that has authority to create new UAA users that in turn become Cloud Foundry users.

## Basic `uaa` commands

You can now use the `uaa` CLI to interact with your UAA.

To see a list of user accounts in JSON:

```text
uaa list-users
```

You can filter the attributes of each user:

```text
uaa list-users --attributes id,userName
```

To view a user called `admin`:

```text
uaa list-users | jq -r ".resources[] | select(.userName == \"admin\")"
```

To see the various scopes that the `admin` user is allowed to access:

```text
uaa list-users | jq -r ".resources[] | select(.userName == \"admin\").groups[].display"
```

The output might look like:

```text
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

```text
uaa list-groups
uaa list-groups | jq -r ".resources[].displayName" | sort
```

As a logged in user - by any of the authentication commands - we potentially can ask the UAA "who am I?"

To see a list of application clients in JSON:

```text
uaa list-clients

uaa list-clients | jq -r ".[] | {client_id, authorized_grant_types, scope, authorities}"
```

We've introduced one client so far - `uaa_admin` - which we're using currently to allow the `uaa` CLI application to talk to the UAA API. To view its configuraton:

```text
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

```text
uaa userinfo
```

This command fails, so run the command again with `--verbose` to see the error message:

```text
uaa userinfo --verbose
```

The output will include an error:

```text
GET /userinfo?scheme=openid HTTP/1.1
...
{"error":"access_denied","error_description":"Invalid token does not contain resource id (openid)"}
```

The reason we cannot invoke `uaa userinfo` is that we are currently authenticated as a client, not on behalf of a user.

That is, the `uaa` application is talking directly to the UAA - one application to another. Peers.

The `uaa userinfo` command assumes that the `uaa` application is talking to the UAA on behalf of an authenticated user.
