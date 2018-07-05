# Integrating UAA and Google Apps

https://github.com/cloudfoundry/uaa/blob/master/docs/google-oidc-provider.md

https://developers.google.com/identity/protocols/OAuth2

![google-create-client-id](images/google-create-client-id.png)

```text
mkdir -p operators
cat > operators/8-google-apps-oidc-provider.yml <<YAML
- type: replace
  path: /instance_groups/name=bosh/jobs/name=uaa/properties/uaa/url
  value: "https://((internal_ip)).sslip.io:8443"

- type: replace
  path: /variables/name=mbus_bootstrap_ssl/options/alternative_names/-
  value: "https://((internal_ip)).sslip.io:8443"

- type: replace
  path: /variables/name=uaa_ssl/options/alternative_names/-
  value: "https://((internal_ip)).sslip.io:8443"

- type: replace
  path: /variables/name=uaa_service_provider_ssl/options/alternative_names/-
  value: "https://((internal_ip)).sslip.io:8443"

- type: replace
  path: /instance_groups/name=bosh/jobs/name=uaa/properties/login/oauth?/providers/google
  value:
    type: oidc1.0
    authUrl: https://accounts.google.com/o/oauth2/v2/auth
    tokenUrl: https://www.googleapis.com/oauth2/v4/token
    tokenKeyUrl: https://www.googleapis.com/oauth2/v3/certs
    issuer: https://accounts.google.com
    redirectUrl: "https://((internal_ip)):8443"
    scopes:
      - openid
      - email
    linkText: Login with Google
    showLinkText: true
    addShadowUserOnLogin: true
    relyingPartyId: ((google_client))
    relyingPartySecret: ((google_client_secret))
    skipSslValidation: false
    attributeMappings:
      user_name: email
YAML
```

In `vars.yml` add the following two lines:

```yaml
google_client:
google_client_secret:
```

Google requires that we use a domain name for our client, so the above changes also modify the URL. This means we need to regenerate the SSL certificates when we deploy.

```text
rm state/creds.yml
uaa-deployment up
```

## Login with Google

To get your new UAA URL:

```text
uaa-deployment info
```

If it was https://192.168.50.6:8443/ before then it will now be https://192.168.50.6.sslip.io:8443/

![uaa-login-with-google-link](images/uaa-login-with-google-link.png)

Click on "Login with Google" link. You will be redirected to choose a Google account and authorize the UAA. When you return to the UAA home page your email will be your UAA user.

## Google User in UAA

To view your new user, first update your local environment variables, login as `uaa_admin` client, and run `uaa list-users`:

```text
source <(bin/uaa-deployment env)
uaa-deployment auth-client
uaa list-users | jq -r ".[-1]"
```

The output might look similar to:

```json
{
  "id": "822267e9-c1a9-474f-b5b1-47f57f9e4a40",
  "externalId": "110256939637129558010",
  "meta": {
    "created": "2018-07-05T05:14:11.189Z",
    "lastModified": "2018-07-05T05:14:11.189Z"
  },
  "userName": "drnic@starkandwayne.com",
  "name": {},
  "emails": [
    {
      "value": "drnic@starkandwayne.com",
      "primary": false
    }
  ],
  "groups": [
    ...
    {
      "value": "9b838b54-3ae0-4f27-882f-ec39c928493a",
      "display": "openid",
      "type": "DIRECT"
    },
    ...
  ],
  "active": true,
  "verified": true,
  "origin": "google",
  "zoneId": "uaa",
  "passwordLastModified": "2018-07-05T05:14:11.000Z",
  "lastLogonTime": 1530767651229,
  "schemas": [
    "urn:scim:schemas:core:1.0"
  ]
}
```

Of note is `"origin": "google"` which indicates that the user originated from Google. Previously our `uaa create-user` users had `"origin": "uaa"`.