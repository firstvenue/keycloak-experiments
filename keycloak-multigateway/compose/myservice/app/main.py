from typing import Optional, List

from fastapi import FastAPI, Header

import requests

PETSTORE_URL = "https://petstore.kongx.localhost/v3/pet"

app = FastAPI(
    title="My Service",
    docs_url="/"
)

@app.get("/whoami")
def whoami(x_username: Optional[str] = Header(None)):
    """Returns value of `preferred_username` claim in access token"""
    if x_username:
        return f"Hello {x_username}!"
    else:
        return "I don't have your username"

@app.post("/addMultiplePets", status_code=201)
def add_multiple_pets(names: List[str] = ["fido", "bailey", "max"],
                      x_access_token = Header(None)):
    """Add multiple pets. Requires `pet` role"""
    for name in names:
        requests.post(PETSTORE_URL,
                      json={"name": name, "status": "available"},
                      headers={"x-access-token": x_access_token},
                      verify=False)
    return x_access_token
