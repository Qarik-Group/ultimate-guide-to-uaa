# `cc-service-dashboards`

Single Sign-On (SSO) enables Cloud Foundry (CF) users to authenticate with third-party service dashboards using their CF credentials. Service dashboards are web interfaces which enable users to interact with some or all of the features the service offers. SSO provides a streamlined experience for users, limiting repeated logins and multiple accounts across their managed services. The user’s credentials are never directly transmitted to the service since the OAuth protocol handles authentication.


https://docs.cloudfoundry.org/services/dashboard-sso.html

To enable the SSO feature, the Cloud Controller requires a UAA client with sufficient permissions to create and delete clients for the service brokers that request them. This client can be configured by including the following snippet in the cf-release manifest:

```yaml
cc-service-dashboards:
  authorities: clients.read,clients.write,clients.admin
  authorized-grant-types: client_credentials
  scope: openid,cloud_controller_service_permissions.read
  secret: ((uaa_clients_cc-service-dashboards_secret))
```

