-- This file serves as the docuentation of Agentic MindScape's Postgres tables 
-- =============================================================================


-- START: AUTHENTICATION AND AUTHORIZATION TABLES ------------------------------
-- USERS TABLE
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

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.users
    OWNER to postgres;


-- GROUPS TABLE
CREATE TABLE IF NOT EXISTS public.groups
(
    group_id SERIAL PRIMARY KEY,
    group_name character varying(100) NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.groups
    OWNER to postgres;


-- ROLES TABLE
CREATE TABLE IF NOT EXISTS public.roles
(
    role_id SERIAL PRIMARY KEY,
    role_name character varying(100) NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.roles
    OWNER to postgres;


-- USER_GROUPS TABLE
CREATE TABLE IF NOT EXISTS public.user_groups
(
    user_luid character varying(36) NOT NULL,
    group_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT pk_user_groups PRIMARY KEY (user_luid, group_id),

    -- Define the foreign key constraint for user_luid.
    -- It references the 'user_luid' column in the 'users' table.
    CONSTRAINT fk_user_luid FOREIGN KEY (user_luid)
        REFERENCES public.users (user_luid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,

    -- Define the foreign key constraint for group_id.
    -- It references the 'group_id' column in the 'groups' table.
    CONSTRAINT fk_group_id FOREIGN KEY (group_id)
        REFERENCES public.groups (group_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_groups
    OWNER to postgres;


-- GROUP_ROLES TABLE
CREATE TABLE IF NOT EXISTS public.group_roles
(
    group_id integer NOT NULL,
    role_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT pk_group_roles PRIMARY KEY (group_id, role_id),

    -- Define the foreign key constraint for user_luid.
    -- It references the 'user_luid' column in the 'users' table.
    CONSTRAINT fk_group_id FOREIGN KEY (group_id)
        REFERENCES public.groups (group_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,

    -- Define the foreign key constraint for group_id.
    -- It references the 'group_id' column in the 'groups' table.
    CONSTRAINT fk_role_id FOREIGN KEY (role_id)
        REFERENCES public.roles (role_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.group_roles
    OWNER to postgres;


-- Add these two tables for direct user-role assignments
allow_roles -> this adds a role for a specific user
---------------
user_luid: varchar(36)
role_id: integer


deny_roles -> this removes a role from a specific user
---------------
user_luid: varchar(36)
role_id: integer    
-- END: AUTHENTICATION AND AUTHORIZATION TABLES ------------------------------


-- ** NOTE: See the email that you sent to yourself from your BusPatrol email regarding the sprocs and session table setup **
-- START: SESSION MANAGEMENT TABLES ------------------------------
-- USER_SESSIONS TABLE
CREATE TABLE IF NOT EXISTS public.user_sessions
(
    sessionid character varying(36) NOT NULL,
    email_address character varying(36) NOT NULL,
    user_luid character varying(36) NOT NULL,
    user_type character varying(8) NOT NULL,
    user_plan character varying(36) NOT NULL,
    sponsor_code character varying(7),
    session_data JSON,
    expires_at timestamp with time zone NOT NULL DEFAULT NOW() + INTERVAL '24 hours',
    CONSTRAINT sessionid_pkey PRIMARY KEY (sessionid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_sessions
    OWNER to postgres;
-- END: SESSION MANAGEMENT TABLES ------------------------------


-- START: OPERATIONAL TABLES ------------------------------
-- MEMBER_ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.member_items
(
    item_luid character varying(36) NOT NULL DEFAULT gen_entity_luid(),
    user_luid character varying(36) NOT NULL,
    item_type character varying(36) NOT NULL,
    name character varying(50),
    description character varying(200),
    details text,
    category character varying(36),
    completed boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT member_items_pkey PRIMARY KEY (item_luid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.member_items
    OWNER to postgres;


-- BRANDING_CAROUSELS TABLE
CREATE TABLE IF NOT EXISTS public.branding_carousels
(
    carousel_luid character varying(36) NOT NULL DEFAULT gen_entity_luid(),
    user_luid character varying(36) NOT NULL,
    bizcard_json JSON,
    infopanel_json JSON,
    video_json JSON,
    status character varying(8) NOT NULL DEFAULT 'wip',
    name character varying(50),
    description character varying(200),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT branding_carousels_pkey PRIMARY KEY (carousel_luid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.branding_carousels
    OWNER to postgres;


-- LIVE_BRANDING_CAROUSELS TABLE
CREATE TABLE IF NOT EXISTS public.live_branding_carousels
(
    sponsor_code character varying(7) NOT NULL,
    carousel_luid character varying(36) NOT NULL,
    bizcard_json JSON,
    infopanel_json JSON,
    video_json JSON,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT sponsor_code_pkey PRIMARY KEY (sponsor_code)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.live_branding_carousels
    OWNER to postgres;


-- TODOS TABLE
CREATE TABLE public.todos (
	entity_luid VARCHAR(36) PRIMARY KEY DEFAULT gen_entity_luid()::TEXT,
	user_luid VARCHAR(36) NOT NULL,
	title VARCHAR(255) NOT NULL,
	description TEXT,
	completed BOOLEAN DEFAULT FALSE,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.todos
    OWNER to postgres;
-- END: OPERATIONAL TABLES ------------------------------