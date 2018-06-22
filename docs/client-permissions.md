Third-party client applications are also scoped in their ability to interact with the UAA API.

Consider our original client `uaa_admin`:

```
uaa get-client uaa_admin
```

The output shows that `uaa_admin` client has many authorities, but scope `uaa.none`:

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
    "uaa.admin",
    "clients.read",
    "clients.secret",
    "clients.write",
    "scim.write",
    "scim.read"
    "password.write",
  ],
  "lastModified": 1529652956499
}
```

Alternately, the `uaa-cli-authcode` client has a scope `openid` but authorities `uaa.none`:

```json
{
  "client_id": "uaa-cli-authcode",
  "scope": [
    "openid"
  ],
  "resource_ids": [
    "none"
  ],
  "authorized_grant_types": [
    "refresh_token",
    "authorization_code"
  ],
  "redirect_uri": [
    "http://localhost:9876"
  ],
  "authorities": [
    "uaa.none"
  ],
  "lastModified": 1529653539556
}
```