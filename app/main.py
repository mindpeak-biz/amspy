from fastapi import FastAPI
from mangum import Mangum
from models import User, UserPublic


app = FastAPI()

# This file will have all the routes (in sections, by service, so that the monolith can later be decomposed)

# -----------------------------------------------------------------------------------------
# routes for testing various things
@app.get("/")
def welcome():
    return {"message": "Hello from FastAPI on Lambda and Mangum!"}

@app.get("/users/")
def get_users():
    return {"message": "Connected to Postgres! - Retrieving users soon!"}

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



