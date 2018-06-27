# Authenticating User via Web UI

It is common for CLIs to support user login via username/password. But a risk of a user providing their username/password to a UAA third-party client application is that a sneaky client application might store the raw username/password and reuse them later without the user's permission.

Fundamentally, a UAA clients do not need a user's username and password - they only need authoriziation to act on behalf of a user.

Fortunately, the UAA allows UAA clients to gain user authentication and authorization without them asking for a user's password. A UAA client can temporarily direct the user to the UAA web UI. It is more common to see web application's "Login" button redirect the user to a login page that is a different web application - in our case, it would be the UAA - before being returned to the original web application. It is less common for CLI applications, but just as important for them to support for user security.

The mechanism of authentication and authorization is an authorization code received after the user is returned from the UAA Web UI.
That is, the third-party client application delgates the login process to the UAA user interface, and in return receives a authorization token that the application can use to make subsequent API requests on behalf of the user.

Once again we will use the `uaa` CLI to perform the administrative task of creating a new UAA client, and then using it to login as a user.

First, register a new UAA client that is designed to allow the `uaa` to be used by normal UAA users.

```text
uaa-deployment auth-client
uaa create-client uaa-cli-authcode -s uaa-cli-authcode \
  --authorized_grant_types authorization_code,refresh_token \
  --redirect_uri http://localhost:9876 \
  --scope openid
```

Next, you can authenticate as `drnic` and then authorize the `uaa` CLI without providing the username/password directly to the CLI:

```text
uaa get-authcode-token uaa-cli-authcode -s uaa-cli-authcode --port 9876
```

The output will look similar to:

```text
Launching browser window to https://drnic-uaa.starkandwayne.com:8443/oauth/authorize?client_id=uaa-cli-authcode&redirect_uri=http%3A%2F%2Flocalhost%3A9876&response_type=code where the user should login and grant approvals
Starting local HTTP server on port 9876
Waiting for authorization redirect from UAA...
```

The user's web browser will be redirected to the UAA UI. If they have not already authenticated (logged in) then they will be prompted to do that.

![uaa-web-user-login](images/uaa-web-user-login.png)

Next, they will be asked to grant authorization to the `uaa` CLI (via its `uaa-cli-authcode` UAA client):

![uaa-app-auth-ack](images/uaa-app-auth-ack.png)

The UAA UI explains to the user the scope of permissions that the `uaa` CLI is requesting. When we ran `uaa create-client uaa-cli-authcode` to create the UAA client, we only requested `--scope openid`. That is, the `uaa` CLI only wants the abilities of the `openid` scope. The UAA UI now confirms that this means in plain english: "Access profile information, i.e. email, first and last name, and phone number".

After clicking "Authorize" the browser changes to:

![uaa-app-auth-success](images/uaa-app-auth-success.png)

Back in the terminal, the `uaa get-authcode-token` command has now completed:

```text
Local server received request to GET /?code=xfnUz8RUON
Calling UAA /oauth/token to exchange code xfnUz8RUON for an access token
Stopping local HTTP server on port 9876
Access token added to active context.
```

If we visit the "Account Settings" in the UAA web UI we can see that `drnic` has a record of the new third-party application that has been previously authorized. It also documents that the application only has permission to use UAA API operations that only require the `openid` scope.

![uaa-web-user-profile-authorized-client](images/uaa-web-user-profile-authorized-client.png)

Running `uaa get-authcode-token` again will automatically authenticate the user via the browser:

```text
uaa get-authcode-token uaa-cli-authcode -s uaa-cli-authcode --port 9876
```

The `uaa` CLI is now acting on behalf of a user.

The `openid` scope allows the UAA API calls for:

```text
uaa userinfo
```
