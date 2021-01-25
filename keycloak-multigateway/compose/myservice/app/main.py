import logging
from typing import Optional, List

from fastapi import FastAPI, Header, HTTPException
import requests

logger = logging.getLogger(__name__)

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
                      authorization=Header(None)):
    """Add multiple pets. Requires `pet` role"""
    for name in names:
        r = requests.post(PETSTORE_URL,
                          json={"name": name, "status": "available"},
                          headers={"authorization": authorization},
                          verify=False)
        if r.status_code == 200:
            logger.info(f"Successfully added pet {name}")
        elif r.status_code == 403:
            raise HTTPException(status_code=403, detail="Error adding pets. Check that user has permission.")
        else:
            raise HTTPException(status_code=400, detail="Error adding pets to petstore")
