# This file will have all the routes (in sections, by service, so that the monolith can later be decomposed)

import os
from dotenv import load_dotenv
from fastapi import FastAPI, Depends
from mangum import Mangum
from sqlmodel import create_engine, SQLModel, Session, select
from typing import List
# import logging
#import traceback

from .models import User, UserPublic
from .services.auth import auth
from .services.core import core
from .services.users import users
from .services.notifications import notifications
from .services.branding import branding


# Global variables
load_dotenv()

def get_session():
    # The engine handles the connection to Postgres
    database_url = os.getenv("NEONDB_QA")
    engine = create_engine(database_url, echo=True)
    with Session(engine) as session:
        yield session


app = FastAPI()

'''
Note on mangum:
-------------------
# default Lambda handler function 
def handler(event, context): # event and context are both dictionaries
    pass
# but since we want a FastAPI app (ASGI interface with routes), we need middleware (an adapter) to translate 
# a normal Lambda request into an ASGI http request. The middleware for this is called mangum.
# It handles Function URLs, API Gateway, ALB, and CloudFront Lambda@Edge events.

from mangum import Mangum

app = FastAPI()
handler = Mangum(app)

Having the handler variable (by wrapping your app with Mangum) means you can delete 
the default expected def handler(event, context) function. 
'''

# -----------------------------------------------------------------------------------------
# routes for the Auth Service
@app.get("/services/auth")
def auth_home():
    return {"message": "Hello from the Auth Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Core Service
@app.get("/services/core")
def core_home():
    return {"message": "Hello from the Core Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Users Service
@app.get("/services/user")
def core_home():
    return {"message": "Hello from the User Service!"}

@app.get("/services/user/users", response_model=List[UserPublic])
def read_users(session: Session = Depends(get_session)):
    """ Returns a list of all users, automatically filtered to the UserPublic schema."""
    try:
        # Select the full User table model
        statement = select(User)
        # Execute and get all results
        results = session.exec(statement)
    except Exception as e:
        # print((f"Error occurred: {traceback.format_exc()}"))
        print(f"Error occurred: {str(e)}")
    else:
        users = results.all()
    # Return the list. 
    # Note: FastAPI handles the JSON conversion and filters data based on UserPublic automatically.
    return users  

# -----------------------------------------------------------------------------------------
# routes for the Notification Service
@app.get("/services/notification")
def notifications_home():
    return {"message": "Hello from the Notification Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Branding Service
@app.get("/services/branding")
def branding_home():
    return {"message": "Hello from the Branding Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Flash Card Service
@app.get("/services/flashcard")
def branding_home():
    return {"message": "Hello from the Flash Card Service!"}

handler = Mangum(app)

