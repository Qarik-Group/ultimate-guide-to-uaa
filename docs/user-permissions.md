Each new user is automatically added as a member of various groups:

```
uaa get-user drnic | jq -r ".groups[].display" | sort
```

The output might be similar to:

```
approvals.me
oauth.approvals
openid
password.write
profile
roles
scim.me
uaa.offline_token
uaa.user
user_attributes
```

To start to learn what authorizations/priveleges each group provides:

```
uaa list-groups | jq -r ".resources[] | {displayName, description}"
```

An interesting selection of the output is:

```json
{
  "displayName": "openid",
  "description": "Access profile information, i.e. email, first and last name, and phone number"
}
{
  "displayName": "password.write",
  "description": "Change your password"
}
{
  "displayName": "uaa.user",
  "description": "Act as a user in the UAA"
}
{
  "displayName": "scim.userids",
  "description": "Read user IDs and retrieve users by ID"
}
{
  "displayName": "scim.invite",
  "description": "Send invitations to users"
}
{
  "displayName": "uaa.none",
  "description": "Forbid acting as a user"
}
```

Comparing the two lists, we see that the `drnic` user will be granted permission to:

* `openid` - Access profile information, i.e. email, first and last name, and phone number
* `password.write` - Change your own password
* `uaa.user` - Act as a user in the UAA

From the sample list of available authorization groups, we can note that `drnic` user is not in the following groups:

* `scim.userids` - cannot read the user IDs nor retrieve users by ID
* `scim.invite` - is not allowed to send invites to other users
* `uaa.node` - is not forbidden from acting as a user

In the subsequent sections we will allow our new users to "login" and authorize the `uaa` CLI to interact with the UAA on their behalf.

