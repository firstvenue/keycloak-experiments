package envoy.authz

import input.attributes.request.http as http_request

default allow = false

# Decode access token from "x-access-token" header
token = payload {
    encoded := http_request.headers["x-access-token"]
    [_, payload, _] := io.jwt.decode(encoded)
}

# Whitelist paths needed to display swagger page
permitted_paths {
    paths := ["", "openapi.json", "swagger-ui.css", "swagger-ui-bundle.js", "swagger-ui-standalone-preset.js", "whoami"]
    input.parsed_path[_] == paths[_]
}

headers := {
    "x-access-token": http_request.headers["x-access-token"],
    "x-username": token["preferred_username"]
}

allow = response {
  permitted_paths

  response := {
      "allowed": true,
      "headers": headers
  }
}

allow = response {
  token.resource_access["myservice"].roles[_] == "add"
  glob.match("*/add*", [], http_request.path)

  response := {
      "allowed": true,
      "headers": headers
  }
}
