# Deploy UAA

## Options for running UAA

The [Ultimate Guide to UAA](/) book includes some accompanying free tools to deploy a production-grade UAA to your local machine or any cloud infrastructure, and references to other methods of deploying a UAA or accessing an existing UAA.

If you are Pivotal Cloud Foundry customer, there is also the [Single-Sign On tile](https://docs.pivotal.io/p-identity/) which provides a multi-tenant UAA.

## Local UAA using VirtualBox

This book will introduce you to the `uaa-deployment` tool that allows you to deploy the UAA locally.

Your UAA will have generated certificates, randomized passwords, and its PostgreSQL-backed data will be stored on a persistent disk volume on your target cloud infrastructure.

The [`u` CLI](https://github.com/starkandwayne/uaa-deployment) tool is built for Linux/OSX/Bash environments.

To download and prepare the `uaa-deployment` project using `git`:

```text
git clone https://github.com/starkandwayne/uaa-deployment
cd uaa-deployment
source .envrc
```

To deploy or upgrade a UAA server to your local machine via VirtualBox:

```text
u up
```

Once our UAA is running we can view the target URL and some admin-level authentication:

```text
u info
```

The output might look like:

```text
UAA:
  url: https://192.168.50.6:8443
  client: uaa_admin
  client_secret: nnb2tbev0j82gxdz65xc
  username: admin
  password: 2rbaswzllkuy51ymzahz
```

Visit the URL and you will be redirected to the `/login` page:

![uaa-web-user-login](images/uaa-web-user-login.png)

Try to login with both pairs of credentials - client/client_secret, and username/password.

You will discover that you cannot authenticate with client/client_secret. These are not user credentials.

Rather they are credentials for an application to talk to the UAA API - either on behalf of itself (say, to register new UAA users or new UAA clients), or on behalf of a UAA user (say, to ask for the user's personal information, or their authorized permissions within the organization).

Succesfully logging in with the `admin` username/password will look like:

![uaa-web-user-success](images/uaa-web-user-success.png)

You'll see a corporate logo (the default is "Cloud Foundry"), the title "Where to?", and .... a void of emptiness. This homepage of the UAA can be filled with "tiles" - icons/names for your internal corporate applications that users can possible use. We will revisit this later.

### Upgrading

Your UAA, including Java & Tomcat & PostgreSQL, is running on a single VM (via VirtualBox if you run `u up` without the `--cpi` flag). Over time new versions of the UAA or PostgreSQL will be available.

To upgrade:

```text
git pull
u up
```

### Destroy UAA

Later when you want to destroy your UAA VM and associated persistent disk:

```text
u down
```

## Deploy UAA to any Cloud Foundry

The UAA running at https://login.starkandwayne.com/ is hosted on Cloud Foundry, specifically [Pivotal Web Services](https://run.pivotal.io). It was deployed and upgraded using https://github.com/starkandwayne/uaa-deployment-cf

## Deploy cfdev to deploy Cloud Foundry locally

The [`cf dev`](https://github.com/cloudfoundry-incubator/cfdev) project is a fast and easy local Cloud Foundry experience on native hypervisors, which means you get a UAA to boot.

```text
$ cf dev start
Downloading Resources...
Starting VPNKit ...
Starting the VM...
Deploying the BOSH Director...
Deploying CF...

  ██████╗███████╗██████╗ ███████╗██╗   ██╗
 ██╔════╝██╔════╝██╔══██╗██╔════╝██║   ██║
 ██║     █████╗  ██║  ██║█████╗  ██║   ██║
 ██║     ██╔══╝  ██║  ██║██╔══╝  ╚██╗ ██╔╝
 ╚██████╗██║     ██████╔╝███████╗ ╚████╔╝
  ╚═════╝╚═╝     ╚═════╝ ╚══════╝  ╚═══╝
             is now running!

To begin using CF Dev, please run:
    cf login -a https://api.v3.pcfdev.io --skip-ssl-validation

Admin user => Email: admin / Password: admin
Regular user => Email: user / Password: pass
```

To target your new local Cloud Foundry, and its UAA:

```text
uaa target https://uaa.v3.pcfdev.io/ --skip-ssl-validation
uaa get-client-credentials-token admin -s admin-client-secret
```
