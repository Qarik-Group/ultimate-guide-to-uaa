# Basic Operations for Running UAA

This section discusses some basic methods for inspecting, debugging, scaling, and upgrading your UAA.

Whilst this section focuses on the `uaa-deployment` tool, most of the information is useful for any deployment of the UAA via BOSH. You can learn more about BOSH from [Stark & Wayne](https://starkandwayne.com)'s free online book [Ultimate Guide to BOSH](https://ultimateguidetobosh.com).

## Deploy UAA to local VirtualBox

```text
uaa-deployment up
```

This will create a `vars.yml` containing default configuration for your VirtualBox VM. You can edit it and run `uaa-deployment up`.

## Deploy UAA to AWS

```text
uaa-deployment up --cpi aws
```

This will not initially create anything on AWS, instead it will create a `vars.yml` file for you to edit.

```yaml
access_key_id: # ...
secret_access_key: # ...
region: us-east-1
az: us-east-1b
subnet_id: # subnet-...
internal_cidr: 10.0.0.0/24
internal_gw: 10.0.0.1
internal_ip: 10.0.0.6
default_security_groups: [bosh]
default_key_name: bosh
private_key:

instance_type: m4.xlarge
ephemeral_disk_size: 25_000

# flag: --spot-instance
spot_bid_price: # Bid price in dollars for AWS spot instance

# flag: --security-groups
security_groups:

# flag: --lb-target-groups
lb_target_groups:
```

Once you've provided your AWS credentials, networking configuration, and even an optional spot instance price, you can then re-run the `up` command:

```text
uaa-deployment up
```

Anytime you make changes to your `vars.yml`, you then apply them using `uaa-deployment up`. The `bosh` CLI will rebuild your AWS VM, install and configure the UAA software, and keep the UAA running for you on that VM.

## Inside your UAA VM

Regardless if you've deployed your UAA to VirtualBox, AWS, GCP, Azure, vSphere, or another BOSH CPI infrastructure, you can SSH into your UAA VM with the same command:

```text
uaa-deployment ssh
```

You can find the start scripts and configuration files for the UAA:

```text
cd /var/vcap/jobs/uaa
cat config/uaa.yml
```

You can tail the logs for the various processes/sub-systems:

```text
tail -f /var/vcap/sys/log/{*.log,*/*.log}
```

To see the nested set of processes running on the VM:

```text
ps axwwf
```

The UAA is backed by a PostgreSQL database. Its contents are stored on a 60G persistent disk mounted at `/var/vcap/store`:

```text
df -h
cd /var/vcap/store/postgres/postgres*/
ls -al
```

The processes are monitored using Monit. You can force it to restart all processes:

```text
monit restart all
```
