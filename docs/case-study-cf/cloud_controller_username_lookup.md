# `cloud_controller_username_lookup`

The Cloud Controller stores its own data, attributing much of it to its users. Since the UAA is the home of user data, the Cloud Controller only stores the User ID. The Cloud Controller needs to look up the user profile information for one or more User IDs for the following `cf` CLI commands:

```text
cf org-users starkandwayne
cf space-users starkandwayne www-production
```

As an example, the output of `cf org-users starkandwayne` will include email addresses which were sourced from the UAA API as they are not stored by the Cloud Controller:

```text
Getting users in org starkandwayne as drnic@starkandwayne.com...

ORG MANAGER
  drnic@starkandwayne.com

BILLING MANAGER
  drnic@starkandwayne.com

ORG AUDITOR
  drnic@starkandwayne.com
```

If you run the same command with `CF_TRACE=1` set, and observe the API calls made between `cf` and the Cloud Foundry subsystems you can see that `cf` does not interact with the UAA API itself. Instead it is the Cloud Controller API that is converting User IDs into email addresses.

For the Cloud Controller API to communicate with the UAA API it will need a UAA client to grant it authorization.

The `cloud_controller_username_lookup` client grants the Cloud Controller permission to look up user information from the UAA API. Whereas many UAA clients are used to grant permission for different Cloud Foundry microservices to communicate with each other, the `cloud_controller_username_lookup` client is actually to allow access to the UAA API itself.

The definition of the UAA client is:

```yaml
cloud_controller_username_lookup:
  authorities: scim.userids
  authorized-grant-types: client_credentials
  secret: ((uaa_clients_cloud_controller_username_lookup_secret))
```

The `scim.userids` authority is required to [convert a username and origin into a user ID and vice versa](https://github.com/cloudfoundry/uaa/blob/master/docs/UAA-Security.md#username-from-id-queries).

Interesting reference points in the source code:

* [cloud_controller/dependency_locator.rb](https://github.com/cloudfoundry/cloud_controller_ng/blob/5a767b860bf641964a2a84f049a8b8d863013129/lib/cloud_controller/dependency_locator.rb#L233-L272) - see the `uaa_client` method at the bottom which is used by the `username_populating_object_renderer`, `username_populating_collection_renderer`, and `username_and_roles_populating_collection_renderer` methods.
* [`UaaClient#usernames_for_ids`](https://github.com/cloudfoundry/cloud_controller_ng/blob/5a767b860bf641964a2a84f049a8b8d863013129/lib/cloud_controller/uaa/uaa_client.rb#L38-L50) constructs a query to the UAA to resolve `user_ids` into User objects.
* [`CF::UAA::Scim` class](https://github.com/cloudfoundry/cf-uaa-lib/blob/master/lib/uaa/scim.rb) is a UAA client library for Ruby.