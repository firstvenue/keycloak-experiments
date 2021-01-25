package envoy.authz

import input.attributes.request.http as http_request

default allow = false

# Decode access token from "authorization" header
token = payload {
    [_, encoded] := split(http_request.headers["authorization"], " ")
    [_, payload, _] := io.jwt.decode(encoded)
}

# Whitelist paths needed to display swagger page
permitted_paths {
    paths := ["", "openapi.json", "swagger-ui.css", "swagger-ui-bundle.js", "swagger-ui-standalone-preset.js"]
    input.parsed_path[_] == paths[_]
}

headers := {
    # Remove cookie as backend server will throw "Request header is too large" error
    "cookie": ""
}

# Allow access to permitted paths
allow = response {
  permitted_paths

  response := {
      "allowed": true,
      "headers": headers
  }
}

# Allow access to pet-related APIs if user has "pet" role
allow = response {
  token.resource_access["petstore"].roles[_] == "pet"
  glob.match("*/pet*", [], http_request.path)

  response := {
      "allowed": true,
      "headers": headers
  }
}

# Allow access to store-related APIs if user has "store" role
allow = response {
  token.resource_access["petstore"].roles[_] == "store"
  glob.match("*/store*", [], http_request.path)

  response := {
      "allowed": true,
      "headers": headers
  }
}

# Allow access to user-related APIs if user has "user" role
allow = response {
  token.resource_access["petstore"].roles[_] == "user"
  glob.match("*/user*", [], http_request.path)

  response := {
      "allowed": true,
      "headers": headers
  }
}
