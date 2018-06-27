# Simple Web Client

So far the `uaa` CLI has been the only UAA client we have encountered. In this section we will start writing a bespoke UAA client that is a web application.

To write a web application in a book is to be forced to pick a programming language/web framework which some readers will not be familiar. But in its own way perhaps that is ok - since in essence you might be best equiped if you re-write the example applications in a language/framework that suites you best.

To explore the UAA integration is fundamentally to explore OAuth2. Each of the authentication flows earlier discussed are all OAuth2 flows:

* Authorization Code Flow (for apps with servers that can store persistent information).
* Password Credentials (when previous flow can't be used or during development).
* Client Credentials Flow (the client can request an access token using only its client credentials).


!!! warning "Self-signed certificates"
    The UAA service created with `uaa-deployment up` was published with a self-signed certificate with its own root certificate. Many OAuth2 client libraries do not yet support passing a custom certificate as an option, since they assume a publicly visible OAuth2 service such as Google, GitHub, or Facebook. You might need to patch these libraries.

    Examples include:

    * https://github.com/ciaranj/node-oauth/blob/master/lib/oauth2.js#L112-L120 does not support the NodeJS `ca` option for a custom CA certificate.