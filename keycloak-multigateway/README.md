# Multi-gateway Keycloak Demo

Recommendation:
* Use two deployments of Kong enterprise with single deployment of Keycloak (single realm)
* Alternatively, IT may want to use Apigee in place of Kong but only if there are strong reasons to do so
* Use OA AD as the only AD being federated by Keycloak. Other ops ADs will only exist to support AD-native (e.g. Windows
  network share) and legacy systems and will be deprecated when the groups are moved to OA AD.

* Using gateway to terminate OIDC (i.e. function as a proxying OIDC RP) and maintain sessions is crucial for development and proliferation of APIs in our org
