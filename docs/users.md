# Users

When we [deployed our UAA](/deploy-uaa) we observed that an `admin` user was created for us and were able to login as `admin` within the web UI. Ideally, no one would use this pre-existing `admin` user; rather one user account would be created for each person in your organization.

Fortunately it is very easy to create new users with the `uaa` CLI.

> [!NOTE]
> Later when we investigate linking your UAA with pre-existing user directories such as Microsoft Active Directory you will not need to create UAA users at all.

Continuing as the `uaa_admin` client, we can create new users and also look up the personal details of all users.

```text
uaa create-user drnic \
  --email drnic@starkandwayne \
  --givenName "Dr Nic" \
  --familyName "Williams" \
  --password drnic_secret
```

Once created, we can lookup the user with their username:

```text
uaa get-user drnic
```

The JSON output might be similar to:

```json
{
  "id": "87fde4a5-17f3-4667-a5e2-fff62220c73e",
  "meta": {
    "created": "2018-06-22T09:27:10.655Z",
    "lastModified": "2018-06-22T09:27:10.655Z"
  },
  "userName": "drnic",
  "name": {
    "familyName": "Williams",
    "givenName": "Dr Nic"
  },
  "emails": [
    {
      "value": "drnic@starkandwayne",
      "primary": false
    }
  ],
  "groups": [
    {
      "value": "5a201c79-3265-46a8-873d-8631facdb2a1",
      "display": "user_attributes",
      "type": "DIRECT"
    },
    {
      "value": "b07d8fda-aaba-4f3e-9f5c-dca9f7c99e9f",
      "display": "roles",
      "type": "DIRECT"
    },
```

## User Assigned Groups

Newly created users are automatically added to a set of groups whose purpose will be introduced soon.

For simple view of the groups of our new `drnic` user:

```text
uaa get-user drnic | jq -r ".groups[].display" | sort
```

The output might look similar to:

```text
approvals.me
cloud_controller.read
cloud_controller.write
cloud_controller_service_permissions.read
notification_preferences.read
notification_preferences.write
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

These groups are the same as our existing `admin` user. The following command will show there are no differences between the groups of users `admin` and `drnic`:

```text
diff <(uaa get-user drnic | jq -r ".groups[].display" | sort) \
     <(uaa get-user admin | jq -r ".groups[].display" | sort)
```

## Stop Using Admin User

Now that we've created our first user for a human, we can log out from the UAA UI as `admin` and switch to `drnic`.

Visit the UAA web UI, look to the top right of the window to logout from `admin` user, and then login as `drnic`:

![uaa-web-normal-user-login](images/uaa-web-normal-user-login.png)

## User Authorized Clients

The top right corner now changes to the newly logged in user account `drnic`. Click the username to see a dropdown menu. Select "Account Settings".

You can observe that the new user has not yet granted any third-party client applications permission to access their UAA account:

![uaa-web-user-profile](images/uaa-web-user-profile.png)

As mentioned before, when the `drnic` user logs into the UAA web site it is directly interacting with the UAA itself. The login process is `drnic`'s way of identifying who they believe they are (username: `drnic`) and proving that they are indeed `drnic` via their password (this is called authentication).
