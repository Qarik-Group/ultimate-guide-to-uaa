# `cc_service_key_client`

Cloud Controller -> CredHub to retreive secrets stored by service brokers for service keys (for service brokers that implement this feature).

```text
cf create-service-key ghost-mysql ghost-mysql
cf service-key ghost-mysql ghost-mysql
cf service-keys ghost-mysql
```

```yaml
cc_service_key_client:
  authorities: credhub.read,credhub.write
  authorized-grant-types: client_credentials
  secret: ((uaa_clients_cc_service_key_client_secret))
```

* [`DependencyLocator#credhub_client`](https://github.com/cloudfoundry/cloud_controller_ng/blob/5a767b860bf641964a2a84f049a8b8d863013129/lib/cloud_controller/dependency_locator.rb#L289-L298) constructs a `Credhub::Client` to allow the Cloud Controller API to interact with the Credhub API.
* [`Credhub::Client#get_credential_by_name`](https://github.com/cloudfoundry/cloud_controller_ng/blob/master/lib/credhub/client.rb) is a simple client that supports [retrieving credentials from Credhub](https://credhub-api.cfapps.io/#get-credentials).
* [`CredhubCredentialPopulator#transform(service_keys)`](https://github.com/cloudfoundry/cloud_controller_ng/blob/5a767b860bf641964a2a84f049a8b8d863013129/app/collection_transformers/credhub_credential_populator.rb#L14) is the only use of Credhub at the time of writing.

At the time of writing the Cloud Controller API authenticate/authorizes itself with Credhub API via the UAA. The Credhub API also supports [mutual TLS authentication](https://credhub-api.cfapps.io/#mutual-tls); so perhaps in future the Cloud Controller may switch from using the UAA to using mutual TLS.

At the time of writing, the [`Credhub::Client#get_credential_by_name`](https://github.com/cloudfoundry/cloud_controller_ng/blob/master/lib/credhub/client.rb) library only supports retrieving existing credentials. But the UAA client `cc_service_key_client` is configured to allow the Cloud Controller API with authorities `credhub.read` and `credhub.write`. Either `credhub.write` could be removed from the UAA client, or perhaps the Cloud Controller API will author and update its own Credhub secrets in future.