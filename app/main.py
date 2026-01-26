# This file will have all the routes (in sections, by service, so that the monolith can later be decomposed)

import os
from dotenv import load_dotenv
from fastapi import FastAPI, Request, Depends
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
from mangum import Mangum
from sqlmodel import create_engine, SQLModel, Session, select
from typing import List
# import logging
# import traceback

from .models import User, UserPublic
# from .services.auth import auth
# from .services.core import core
# from .services.users import users
# from .services.notifications import notifications
# from .services.branding import branding


# Global variables
load_dotenv()

def get_session():
    # The engine handles the connection to Postgres
    database_url = os.getenv("NEONDB_QA")
    engine = create_engine(database_url, echo=True)
    with Session(engine) as session:
        yield session


app = FastAPI()
templates = Jinja2Templates(directory="templates")


# -----------------------------------------------------------------------------------------
# routes for the Auth Service
@app.get("/services/auth")
async def auth_home():
    return {"message": "Hello from the Auth Service!"}

@app.get("/services/auth/login-form/{id}", response_class=HTMLResponse)
async def auth_home(request: Request, id: str):
    """HTMX will call this to return the HTML for the login form"""
    return templates.TemplateResponse(
        request=request, 
        name="auth/login-form.html", 
        context={"id": id} # Pass data to the HTML file via the "context" dictionary
    )

# -----------------------------------------------------------------------------------------
# routes for the Core Service
@app.get("/services/core")
async def core_home():
    return {"message": "Hello from the Core Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Users Service
@app.get("/services/user")
async def core_home():
    return {"message": "Hello from the User Service!"}

@app.get("/services/user/users", response_model=List[UserPublic])
async def read_users(session: Session = Depends(get_session)):
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
async def notifications_home():
    return {"message": "Hello from the Notification Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Branding Service
@app.get("/services/branding")
async def branding_home():
    return {"message": "Hello from the Branding Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Flash Card Service
@app.get("/services/flashcard")
async def branding_home():
    return {"message": "Hello from the Flash Card Service!"}

handler = Mangum(app)

