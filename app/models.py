from datetime import datetime
from typing import Optional, Dict, Any
from sqlmodel import SQLModel, Field, Column
from sqlalchemy import String, DateTime, JSON, text
from sqlalchemy.dialects.postgresql import JSONB


class UserBase(SQLModel):
    email_address: str = Field(sa_column=Column(String(36), nullable=False))
    sponsor_code: str = Field(sa_column=Column(String(7), nullable=False))
    user_type: str = Field(default="member")
    user_plan: str = Field(default="sponsored member")
    member_profile_json: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column(JSONB))
    sponsor_profile_json: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column(JSONB))


class UserPublic(UserBase):
    user_luid: str
    created_at: datetime


class User(UserBase, table=True):
    __tablename__ = "users"
    __table_args__ = {"schema": "public"}

    # Primary Key with Postgres-side default
    user_luid: str = Field(
        sa_column=Column(
            String(36), 
            primary_key=True, 
            server_default=text("gen_entity_luid()")
        )
    )

    encrypted_password: str = Field(sa_column=Column(String(200), nullable=False))
    
    password_reset_guid: Optional[str] = Field(default=None, sa_column=Column(String(36)))
    password_reset_expiry: Optional[datetime] = Field(
        default=None, 
        sa_column=Column(DateTime(timezone=True))
    )
    
    # Timestamps with server-side defaults
    created_at: datetime = Field(
        sa_column=Column(
            DateTime(timezone=True), 
            nullable=False, 
            server_default=text("now()")
        )
    )
    updated_at: datetime = Field(
        sa_column=Column(
            DateTime(timezone=True), 
            nullable=False, 
            server_default=text("now()"),
            onupdate=text("now()")  # Keeps the updated_at fresh
        )
    )
    

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