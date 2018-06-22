#!/bin/bash

jobs=(bpm nats blobstore director health_monitor)
for job in "${jobs[@]}"; do
  cat <<YAML
- type: remove
  path: /instance_groups/name=bosh/jobs/name=$job

YAML
done

releases=(bpm)
for release in "${releases[@]}"; do
  cat <<YAML
- type: remove
  path: /releases/name=$release

YAML
done

properties=(agent nats blobstore director hm ntp)
for property in "${properties[@]}"; do
  cat <<YAML
- type: remove
  path: /instance_groups/name=bosh/properties/$property

YAML
done

uaa_properties=(uaa/clients/bosh_cli uaa/clients/hm)
for property in "${uaa_properties[@]}"; do
  cat <<YAML
- type: remove
  path: /instance_groups/name=bosh/jobs/name=uaa/properties/$property

YAML
done

variables=(blobstore_director_password blobstore_agent_password
  hm_password mbus_bootstrap_password
  nats_ca nats_server_tls nats_clients_director_tls director_ssl
  blobstore_ca blobstore_server_tls)
for var in "${variables[@]}"; do
  cat <<YAML
- type: remove
  path: /variables/name=$var

YAML
done
