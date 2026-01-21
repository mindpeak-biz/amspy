# This file will have all the routes (in sections, by service, so that the monolith can later be decomposed)


from fastapi import FastAPI, Depends
from mangum import Mangum
from sqlmodel import create_engine, SQLModel, Session, select
from models import User, UserPublic
from typing import List


# Global variables
# Note: 
DATABASE_URL = "postgresql://postgres:yourpassword@localhost:5432/your_db_name"


def get_session():
    # The engine handles the connection to Postgres
    engine = create_engine(DATABASE_URL, echo=True)
    with Session(engine) as session:
        yield session


app = FastAPI()

# -----------------------------------------------------------------------------------------
# routes for testing various things
@app.get("/")
def welcome():
    return {"message": "Hello from FastAPI on Lambda and Mangum!"}

@app.get("/users/", response_model=List[UserPublic])
def read_users(session: Session = Depends(get_session)):
    """ Returns a list of all users, automatically filtered to the UserPublic schema."""
    # Select the full User table model
    statement = select(User)
    
    # Execute and get all results
    results = session.exec(statement)
    users = results.all()
    
    # Return the list. 
    # Note: FastAPI handles the JSON conversion and filters data based on UserPublic automatically.
    return users    

# -----------------------------------------------------------------------------------------
# routes for the Auth Service
@app.get("/services/auth/")
def auth_home():
    return {"message": "Hello from the Auth Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Core Service
@app.get("/services/core/")
def core_home():
    return {"message": "Hello from the Core Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Users Service
# GET: Uses UserPublic to hide the password
@app.get("/users", response_model=list[UserPublic])
def read_users(session: Session = Depends(get_session)):
    return session.exec(select(User)).all()


# -----------------------------------------------------------------------------------------
# routes for the Notifications Service
@app.get("/services/notifications/")
def notifications_home():
    return {"message": "Hello from the Notifications Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Branding Service
@app.get("/services/branding/")
def branding_home():
    return {"message": "Hello from the Branding Service!"}

# -----------------------------------------------------------------------------------------
# routes for the Flash Card Service
@app.get("/services/flashcards/")
def branding_home():
    return {"message": "Hello from the Flash Card Service!"}

handler = Mangum(app)



