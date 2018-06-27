# Authenticating User with Password

For the `uaa` CLI application to act on behalf of a user - with the permission of the user - then user will need to authenticate themselves. That is, to prove that they are who they claim to be. The simplest method is for a user to provide the secret password for their UAA user account.

In this section, the user will give their username (who they claim to be) and their password (their proof that it is them) to the `uaa` client application, rather than to the UAA.

The `uaa` CLI will forward the username/password to the UAA API to get authorization to act on behalf of the user; for example, to look up its own profile information and its associated groups. First and foremostly, to login as a UAA user is to confirm that the current user is indeed authenticated as that UAA user and can proceed with more requests with its data.

To allow the `uaa` CLI to authenticate as `drnic` it will need to act with a new UAA client. Handily the `uaa` CLI can create new UAA clients:

```text
uaa-deployment auth-client
uaa create-client our_uaa_cli -s our_uaa_cli_secret \
  --authorized_grant_types password,refresh_token \
  --scope "openid"  \
  --authorities uaa.none \
  --access_token_validity 120 \
  --refresh_token_validity 86400
```

We can now authenticate as `drnic` UAA user via the `uaa` CLI. That is, we can authenticate and grant permission to the `uaa` client application to interact with the UAA on behalf of `drnic`:

```text
uaa get-password-token uaa_cli -s uaa_cli_secret -u drnic -p drnic_secret
```

To demonstrate that the `uaa` is now operating on behalf of the `drnic` user:

```text
uaa userinfo
```

The JSON output might look like:

```json
{
  "user_id": "87fde4a5-17f3-4667-a5e2-fff62220c73e",
  "sub": "87fde4a5-17f3-4667-a5e2-fff62220c73e",
  "user_name": "drnic",
  "given_name": "Dr Nic",
  "family_name": "Williams",
  "email": "drnic@starkandwayne",
  "phone_number": null,
  "previous_logon_time": 1529661057132,
  "name": "Dr Nic Williams"
}
```

That is, the `uaa` CLI has authenticated as `drnic` user, and is authorized to look up that user's personal information. User Authentication & Authorization. UAA. Boomshakalaka.

## Password Grant Type

In previous sections we used the `uaa_admin` UAA client, but in this section we created a new UAA client. Why?

Try repeating the `uaa get-password-token -u drnic -p drnic_secret` command but with the `uaa_admin` client.

First, get the `uaa_admin` password and then use it with the `uaa get-password-token` command:

```text
uaa-deployment info
uaa get-password-token uaa_admin -s <secret> -u drnic -p drnic_secret -v
```

The error will indicate that the `uaa_admin` client does not support the required `password` grant type:

```json
{"error":"invalid_client","error_description":"Unauthorized grant type: password"}
```

Compare the two clients:

```text
uaa-deployment auth-client
uaa list-clients | jq -rc ".[] | {client_id, authorized_grant_types}"
```

The output will include our two clients `uaa_admin` and `our_uaa_cli`:

```json
{"client_id":"our_uaa_cli","authorized_grant_types":["refresh_token","password"]}
{"client_id":"uaa_admin","authorized_grant_types":["client_credentials"]}
```

The `our_uaa_cli` client is permitted to authenticate users via their password because of `"authorized_grant_types":["refresh_token","password"]`.

When we created the `our_uaa_cli` client at the start of the section, we used the flag `uaa create-client our_uaa_cli --authorized_grant_types password,refresh_token` to specify the `password` authorization grant type.