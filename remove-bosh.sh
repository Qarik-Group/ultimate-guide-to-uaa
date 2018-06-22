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

variables=(admin_password blobstore_director_password blobstore_agent_password
  hm_password mbus_bootstrap_password)
for var in "${variables[@]}"; do
  cat <<YAML
- type: remove
  path: /variables/name=$var

YAML
done
