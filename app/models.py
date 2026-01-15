from sqlmodel import SQLModel, Field
from typing import Optional

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(index=True)
    email: str


'''
CREATE TABLE IF NOT EXISTS public.users
(
    user_luid character varying(36) NOT NULL DEFAULT gen_entity_luid(),
    email_address character varying(36) NOT NULL,
    encrypted_password character varying(200) NOT NULL,
    password_reset_guid character varying(36),
    password_reset_expiry timestamp with time zone,
	sponsor_code character varying(7) NOT NULL,
	user_type character varying(8) NOT NULL DEFAULT 'member',
	user_plan character varying(36) NOT NULL DEFAULT 'sponsored member',
	member_profile_json JSON,
	sponsor_profile_json JSON,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT users_pkey PRIMARY KEY (user_luid)
)
'''