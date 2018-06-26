For the `uaa` CLI application to act on behalf of a user - with the permission of the user - then user will need to authenticate themselves. That is, to prove that they are who they claim to be. The simplest method is for a user to provide the secret password for their UAA user account.

In this section, the user will give their username (who they claim to be) and their password (their proof that it is them) to the `uaa` client application, rather than to the UAA.

The `uaa` CLI will forward the username/password to the UAA API to get authorization to act on behalf of the user.

For a UAA client to be allowed to authorize users with the UAA it needs a UAA client to exist with an `authorized_grant_types` list that includes `password`.

We can use the `uaa` - authenticated as the `uaa_client` client - to create a new UAA client:

```
uaa-deployment auth-client
uaa create-client our_uaa_cli -s our_uaa_cli_secret \
  --authorized_grant_types password,refresh_token \
  --scope "openid"  \
  --authorities uaa.none \
  --access_token_validity 120 \
  --refresh_token_validity 86400
```

A user can now provide the `uaa` CLI permission to interact with the UAA on its behalf:

```
uaa get-password-token uaa_cli -s uaa_cli_secret -u drnic -p drnic_secret
```

To demonstrate that the `uaa` is now operating on behalf of the `drnic` user:

```
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
