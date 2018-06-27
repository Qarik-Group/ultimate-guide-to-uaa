# Real-world UAA Client Examples

Typically each third-party application in the world will have its own registered UAA client. They become synomynous. If we talk about the application, we implicitly can refer to its UAA client, and vice versa.

Some examples:

* The Cloud Foundry CLI `cf` primarily interacts with a target UAA via a client `cf` ([UAA configuration](https://github.com/cloudfoundry/cf-deployment/blob/master/cf-deployment.yml#L415-L423))
* The BOSH CLI `bosh` interacts with a target UAA via a client `bosh_cli` ([UAA configuration](https://github.com/cloudfoundry/bosh-deployment/blob/master/uaa.yml#L51-L59), [`bosh` cli configuration](https://github.com/cloudfoundry/bosh-cli/blob/master/cmd/session.go#L75-L76))

A third-party application might use multiple UAA clients - each with different scopes of authority. For example, the `cf` CLI can use `cloud_controller_username_lookup` to convert UAA user IDs back into readable names (see [definition of client](https://github.com/cloudfoundry/cf-deployment/blob/38b304405764e1307f606d02856e4366b2337cbd/cf-deployment.yml#L423-L426)).

The `uaa` third-party UAA client application is special - it can take on the behavior/authorities of any UAA client. Hence, each of its authentication/authorization commands require use to pass the client/secret.

