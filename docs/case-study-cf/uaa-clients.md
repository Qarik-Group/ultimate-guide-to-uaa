# UAA Clients in Cloud Foundry

Cloud Foundry is a combination of microservices, and a user-facing CLI `cf`, to allow developers to deploy and managing their own web/backend applications.

A running Cloud Foundry includes its own UAA service which is configured at start with a set of UAA clients used by the microservices to authenticate against each other, or for user-facing behavior to be exposed to the user.

To see the list of pre-configured UAA clients:

```text
git clone https://github.com/cloudfoundry/cf-deployment
cd cf-deployment
bosh int cf-deployment.yml --path /instance_groups/name=uaa/jobs/name=uaa/properties/uaa/clients
```

The output at the time of writing is:

```yaml
cc-service-dashboards:
  authorities: clients.read,clients.write,clients.admin
  authorized-grant-types: client_credentials
  scope: openid,cloud_controller_service_permissions.read
  secret: ((uaa_clients_cc-service-dashboards_secret))
cc_routing:
  authorities: routing.router_groups.read
  authorized-grant-types: client_credentials
  secret: ((uaa_clients_cc-routing_secret))
cc_service_key_client:
  authorities: credhub.read,credhub.write
  authorized-grant-types: client_credentials
  secret: ((uaa_clients_cc_service_key_client_secret))
cf:
  access-token-validity: 600
  authorities: uaa.none
  authorized-grant-types: password,refresh_token
  override: true
  refresh-token-validity: 2592000
  scope: network.admin,network.write,cloud_controller.read,cloud_controller.write,openid,password.write,cloud_controller.admin,scim.read,scim.write,doppler.firehose,uaa.user,routing.router_groups.read,routing.router_groups.write,cloud_controller.admin_read_only,cloud_controller.global_auditor,perm.admin
  secret: ""
cloud_controller_username_lookup:
  authorities: scim.userids
  authorized-grant-types: client_credentials
  secret: ((uaa_clients_cloud_controller_username_lookup_secret))
doppler:
  authorities: uaa.resource
  authorized-grant-types: client_credentials
  override: true
  secret: ((uaa_clients_doppler_secret))
gorouter:
  authorities: routing.routes.read
  authorized-grant-types: client_credentials
  secret: ((uaa_clients_gorouter_secret))
network-policy:
  authorities: uaa.resource,cloud_controller.admin_read_only
  authorized-grant-types: client_credentials
  secret: ((uaa_clients_network_policy_secret))
routing_api_client:
  authorities: routing.routes.write,routing.routes.read,routing.router_groups.read
  authorized-grant-types: client_credentials
  secret: ((uaa_clients_routing_api_client_secret))
ssh-proxy:
  authorized-grant-types: authorization_code
  autoapprove: true
  override: true
  redirect-uri: https://uaa.((system_domain))/login
  scope: openid,cloud_controller.read,cloud_controller.write
  secret: ((uaa_clients_ssh-proxy_secret))
tcp_emitter:
  authorities: routing.routes.write,routing.routes.read
  authorized-grant-types: client_credentials
  secret: ((uaa_clients_tcp_emitter_secret))
tcp_router:
  authorities: routing.routes.read
  authorized-grant-types: client_credentials
  secret: ((uaa_clients_tcp_router_secret))
```

## `cc-service-dashboards`

## `cc_routing`

## `cc_service_key_client`

## `cf`

The `cf` client is used by the `cf` CLI.

## `doppler`

## `gorouter`

## `network-policy`

## `routing_api_client`

## `ssh-proxy`

## `tcp_emitter`

## `tcp_router`









