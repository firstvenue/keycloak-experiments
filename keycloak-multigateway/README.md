# Multi-gateway Keycloak Demo

This demo creates a setup as shown in the diagram below:

There are two instances of Kong gateway simulating a multi-tenant environment. Behind `kongX` is the `petstore`
service (to represent any arbitrary API service). Behind `kongY` is the `myservice` service built using the Python
FastAPI framework. `myservice` is used to demonstrate how one might make API calls to a service behind another gateway
(i.e. `petstore` behind `kongX`) using the same access token minted by Keycloak for `kongY`. Both `myservice` and
`petstore` are Resource Servers in OAuth2 terms.

Keycloak is the authorization server. Kong (using the [kong-oidc plugin](https://github.com/Revomatico/kong-oidc)) acts
as a proxying OAuth2 Resource Server and an OAuth2 Client/OpenID Connect Relying Party. This basically means Kong
terminates OAuth2/OpenID Connect in front of the upstream services so those upstream services can function as OAuth2
Resource Servers without implementing the functionalities themselves.

Additionally, Kong also maintains sessions which allows authenticated users through without authenticating again. Kong
also introspects tokens and allows requests with an accompanying access token through. However, the actual token
verification is still done by the upstream services (specifically by Envoy; see next).

Both upstream services are fronted by Envoy and Open Policy Agent instances. In this setup we leverage Envoy's external
authorization filter to call OPA to check whether an incoming request is authorized or not. Envoy also validates the
access token.

There are other utility services defined in `docker-compose.yml` that provide peripheral functions. Namely `traefik` to
provide SSL all around and to provide DNS-like routing (using subdomains of localhost and Docker network aliases), and
`konga` which provides an admin UI for Kong.

## Getting Started

Run `docker-compose -f docker-compose.yml -f docker-compose-keycloak.yml -f docker-compose-services.yml up` to get all
the services running. Starting this many services at a time seems to break docker-compose's `depends_on` behaviour and
cause some pretty strange startup errors.

If this happens, start the Kong instances first with `docker-compose -f docker-compose.yml up -d`. Then start Keycloak
with `docker-compose -f docker-compose-keycloak.yml up -d`. Lastly start the API services with `docker-compose -f
docker-compose-services.yml`.


Next we will configure both Kong instances, using [deck](https://github.com/Kong/deck) to load the relevant configs:
```
cat compose/kong/kongx_config.yaml | docker run -i --rm --network host kong/deck --kong-addr http://localhost:8001 sync
-s -

cat compose/kong/kongy_config.yaml | docker run -i --rm --network host kong/deck --kong-addr http://localhost:9001 sync
-s -
```

You can log into Konga at `https://localhost:1337`. Click "Connections" and select either KongX or KongY. Notice that
there are services, routes and plugins configured.

Lastly, we will configure Keycloak. This can be done via importing the existing config via the admin UI. Log into the
admin UI at `https://keycloak.localhost`.  Click import and import the `compose/keycloak/realm.json` file, selecting
"overwrite" if resource exists. Notice that the `myservice` and `petstore` clients are created. They are also configured
with client roles and mappers.

## Trying it out

### Calling `petstore` APIs

TODO: Add relevant roles then try APIs

### Calling `myservice` APIs

TODO: In myservice client roles, add `petstore`'s `pet` role.
