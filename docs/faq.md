# Frequently Asked Questions

## How can my UAA client application inspect Users?

Your own application will have its own concept of Users, but it will want to defer the bulk of each user's profile, passwords, multi-factor authentication (MFA/2FA), scopes, and authorities to your internal applications to the UAA. Your own application will then reference the UAA User ID, and if it ever needs to display or allow a user to update their profile data, it will call the UAA API to fetch or update this data.

The UAA API has an API endpoint to [fetch a list of UAA users](http://docs.cloudfoundry.org/api/uaa/version/4.19.0/index.html#list-3), and another to [get a specific UAA user](http://docs.cloudfoundry.org/api/uaa/version/4.19.0/index.html#get-3). Both endpoints require an `Authorization` bearer token with scope `scim.read`, or `uaa.admin`.

For example:

```plain
uaa-deployment auth-client
uaa create-client user-lookup -s user-lookup \
  --authorized_grant_types client_credentials \
  --authorities "scim.read" \
  --scope "uaa.none"
```

The `uaa` can then authorize as this new `user-lookup` client and try interacting with these endpoints.

```plain
uaa get-client-credentials-token user-lookup -s user-lookup
uaa curl /Users
uaa list-users
```

## How can guests to my application add themselves as a user?

Similarly, each time your application wants to add a new User, it will need to first create a UAA user, get its UAA User ID, and then store that in its own database to reference the user and their profile details.

The UAA API has an endpoint to [create new users `POST /Users`](http://docs.cloudfoundry.org/api/uaa/version/4.19.0/index.html#create-4). This endpoint requires the `Authorization` header bearer token to include the scope `scim.write`, or `uaa.admin`.

If you have a web application and a public facing sigup process, it will want to interact with this UAA API with client credentials. There is no user involved - it is a guest who is creating their own account.

You will need a UAA client that:

* Authorized grant type `client_credentials`
* As a client that does not involve a user authorization, we will give it a set of authorities that include `scim.write`, but its scope will be `uaa.none` Authority `scim.write`

For example:

```plain
uaa create-client user-creator -s user-creator \
  --authorized_grant_types client_credentials \
  --authorities "scim.write"  \
  --scope "uaa.none"
```

The `uaa` can then authorize as this new `user-creator` client and create a new User:

```plain
uaa get-client-credentials-token user-creator -s user-creator
uaa create-user drnic \
  --password drnic_secret \
  --email drnic@starkandwayne.com \
  --givenName "Dr Nic" \
  --familyName "Williams"
```

## How can my users be authorized to create new users?

If only some users are allowed to create new users then you will need a different UAA client.

TODO

## I added the`scim.write` scope, why can't the user create other users yet?

Once you've added ensured the client application has the scope `scim.write`, and you've added the user to the `scim.write` group, your user might discover they still cannot create other users (or whatever behavior they believe they now have). This is a behavior trait of access tokens.

