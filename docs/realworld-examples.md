# Real-world Examples

## Cloud Foundry CLI

The resource server is the [Cloud Foundry API](https://apidocs.cloudfoundry.org/2.5.0/). The UAA authentication server is typically hosted at both `login` and `uaa` subdomains for historical reasons (they used to be two separate applications).

To view the API calls from the `cf` CLI to the UAA authorization server and the Cloud Foundry API resource server:

```text
export CF_TRACE=1
```

```text
cf login
```

### Passcode

```text
$ cf login -a https://api.run.pivotal.io --sso
API endpoint: https://api.run.pivotal.io

Temporary Authentication Code ( Get one at https://login.run.pivotal.io/passcode )>
```

The UAA presents you with an authentication code:

![uaa-passcode](images/uaa-passcode.png)

When you paste it into the terminal the `cf` CLI completes its authentication process.

```text
Temporary Authentication Code ( Get one at https://login.run.pivotal.io/passcode )>
Authenticating...
OK
```

Alternately, you could go directly to the [`/passcode`](https://login.run.pivotal.io/passcode) URL to get the passcode to authenticate to any machine:

```text
cf login -a https://api.run.pivotal.io --sso-passcode c6ERPWaGLP
```

### Client Credentials

```text
cf auth CLIENT_ID CLIENT_SECRET --client-credentials
```

### Generate OAuth Access Token

Once a `cf` user is authenicated - via password grant, auth code/passcode, or with client credentials - they can generate a new access token:

```text
cf oauth-token
```

The output is in the format `bearer <JWT access token>`.

The user can now use the `bearer <JWT access token>` in their API calls with the [Cloud Foundry API](https://apidocs.cloudfoundry.org/) resource server:

```text
cf_auth=$(cf oauth-token)
curl -H "Authorization: ${cf_auth}" https://api.run.pivotal.io/v2/apps
curl -H "Authorization: ${cf_auth}" https://api.run.pivotal.io/v2/domains
```

If we [decode the `<JWT access token>`](https://jwt.io) we can see the UAA scopes that `cf` CLI has been authorized:

![cf-uaa-access-token](images/cf-uaa-access-token.png)

Placing the mouse over the `exp` expiry timestamp helpfully shows us when the access token will expire (8:31am). This is 10 minutes after the current time (8:21am).

![cf-uaa-access-token-10min-expiry](images/cf-uaa-access-token-10min-expiry.png)

### Dual Scope

The access token scopes for `cf` CLI are a combination of Cloud Controller API authorizations (`cloud_controller.read`, `cloud_controller.write`) and UAA API authorizations (`openid`, `uaa.user`, `password.write`).

This means we can use the same access token to interact with a subset of the [UAA API](https://docs.cloudfoundry.org/api/uaa).

For example, `openid` allows a user to [look up their own profile](http://docs.cloudfoundry.org/api/uaa/version/4.19.0/index.html#user-info):

```text
curl -H "Authorization: ${cf_auth}" https://login.run.pivotal.io/userinfo
```

My output is:

```json
{
  "user_id": "xxxx",
  "user_name": "drnic@starkandwayne.com",
  "name": "",
  "email": "drnic@starkandwayne.com",
  "email_verified": true,
  "previous_logon_time": 1530852395198,
  "sub": "xxxx"
}
```

Another example is the `password.write` scope which allows a user to [change their password](http://docs.cloudfoundry.org/api/uaa/version/4.19.0/index.html#change-user-password).


The `cf passwd` command prompts the user for new credentials and then invokes the UAA API to attempt to change the password. In my case below, I get an error message from the UAA API:

```text
$ CF_TRACE=1 cf passwd
Current Password>
New Password>
Verify Password>
Changing password...

REQUEST: [2018-07-07T08:37:25+10:00]
PUT /Users/f61c0d28-5d9c-4e15-a26f-f8f42129e2e4/password HTTP/1.1
Host: uaa.run.pivotal.io

RESPONSE: [2018-07-07T08:37:28+10:00]
HTTP/1.1 400 Bad Request

{"error_description":"Password must contain at least 1 special characters.","error":"invalid_password","message":"Password must contain at least 1 special characters."}
```

That was annoying. I had already changed 1password to the new value.

### Authentication UX determined by UAA

The user experience of the `cf` CLI when authenticating users is derived from the UAA. The text `Temporary Authentication Code ( Get one at https://login.run.pivotal.io/passcode )>` originated from the UAA:

```text
curl https://login.run.pivotal.io/info -H 'Accept: application/json' | jq .
```

The output for Pivotal Web Services at the time of writing is:

```json
{
  "app": {
    "version": "4.19.0"
  },
  "showLoginLinks": true,
  "links": {
    "uaa": "https://uaa.run.pivotal.io",
    "passwd": "https://account.run.pivotal.io/forgot-password",
    "login": "https://login.run.pivotal.io",
    "register": "https://account.run.pivotal.io/sign-up"
  },
  "zone_name": "uaa",
  "entityID": "login.run.pivotal.io",
  "commit_id": "7897100",
  "idpDefinitions": {
    "pivotal-oktapreview-com": "https://login.run.pivotal.io/saml/discovery?returnIDParam=idp&entityID=login.run.pivotal.io&idp=pivotal-oktapreview-com&isPassive=true",
    "pivotal-okta-com": "https://login.run.pivotal.io/saml/discovery?returnIDParam=idp&entityID=login.run.pivotal.io&idp=pivotal-okta-com&isPassive=true"
  },
  "prompts": {
    "username": [
      "text",
      "Email"
    ],
    "password": [
      "password",
      "Password"
    ],
    "passcode": [
      "password",
      "Temporary Authentication Code ( Get one at https://login.run.pivotal.io/passcode )"
    ]
  },
  "timestamp": "2018-06-13T12:02:09-0700"
}
```

The `cf` CLI uses the prompts and text from this `/info` output with its own users.

Of very special note is `links.passwd`... the browser URL for me to reset my password.

## BOSH CLI

BOSH is a platform to run systems such as Cloud Foundry, or the UAA, on any cloud infrastructure (AWS, Azure, GCP, vSphere, OpenStack, VirtualBox, Docker, Kubernetes).

The resource server is the [BOSH API](https://bosh.io/docs/director-api-v1/). The BOSH API and UAA are typically colocated on the same VM. The BOSH API is on port `25555` and the UAA is on port `8443` (like our `uaa-deployment up` UAA).

```text
export BOSH_ENVIRONMENT=10.10.1.4
export BOSH_CA_CERT='...'
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=password
bosh env
```

Even if you are not a BOSH user, you can provision a single VM BOSH API using the a similar approach we've been running our UAA. The `uaa-deployment up` tool originated with a BOSH/UAA version [BUCC](https://github.com/starkandwayne/bucc) by [Stark & Wayne](https://www.starkandwayne.com).

You will need to tear down your local UAA as it uses the same local IP address:

```text
uaa-deployment down
```

To deploy a BOSH/UAA:

```text
git clone https://github.com/starkandwayne/bucc ~/workspace/bucc
source <(~/workspace/bucc/bin/bucc env)
bucc up
source <(~/workspace/bucc/bin/bucc env)
```