-- This file serves as the documentation of Agentic MindScape's Postgres functions and stored procedures
-- =====================================================================================================

-- -------------------------------------------------------------------
-- Calling the functionS:
SELECT * FROM public.get_user_roles('aaaa'); -- Should return all roles for the admin user
SELECT * FROM public.get_user_roles('cafe'); -- Should return all roles for the member user
SELECT * FROM public.get_user_roles('abcdef'); -- Should return roles for the sponsor user
-- -------------------------------------------------------------------


-- -------------------------------------------------------------------
-- Function to get all todos by user_luid
CREATE OR REPLACE FUNCTION get_todos_by_user_luid(
    p_user_luid TEXT  -- The string argument for user_luid
)
RETURNS SETOF todos AS $$
BEGIN
    -- Return all rows from the 'todos' table where user_luid matches the input argument.
    RETURN QUERY
    SELECT *
    FROM todos
    WHERE user_luid = p_user_luid;
END;
$$ LANGUAGE plpgsql;


-- -------------------------------------------------------------------
-- Script to create the function for getting todos by user as JSON
CREATE OR REPLACE FUNCTION get_all_todos_as_json_func(
    p_filter_user_luid VARCHAR
)
RETURNS JSON -- This is where you specify the JSON return type
LANGUAGE plpgsql
AS $$
DECLARE
    v_all_todos_json JSON;
BEGIN
    SELECT json_agg(row_to_json(t))::JSON
    INTO v_all_todos_json
    FROM public.todos AS t
    WHERE t.user_luid = p_filter_user_luid;

    IF v_all_todos_json IS NULL THEN
        v_all_todos_json := '[]'::JSON;
    END IF;

    RETURN v_all_todos_json;
END;
$$;


-- -------------------------------------------------------------------
-- Function to generate a random alphanumeric string of a given length
CREATE OR REPLACE FUNCTION gen_random_alphanumeric(length INT)
RETURNS TEXT AS $$
DECLARE
    chars TEXT := '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    result TEXT := '';
    i INT := 0;
BEGIN
    IF length < 0 THEN
        RAISE EXCEPTION 'Length must be a non-negative integer.';
    END IF;

    FOR i IN 1..length LOOP
        -- Concatenate a random character from the 'chars' set
        result := result || SUBSTR(chars, (FLOOR(RANDOM() * LENGTH(chars)) + 1)::INT, 1);
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


-- -------------------------------------------------------------------
-- Function to create the concatenated string in YYMMDDhhmmss-xxxx format
CREATE OR REPLACE FUNCTION gen_entity_luid()
RETURNS TEXT AS $$
DECLARE
    timestamp_part TEXT;
    random_part TEXT;
BEGIN
    -- Get the current timestamp and format it as YYMMDDhhmmss
    -- YY: 2-digit year
    -- MM: 2-digit month
    -- DD: 2-digit day
    -- HH24: 24-hour format hour
    -- MI: 2-digit minute
    -- SS: 2-digit second
    SELECT TO_CHAR(NOW(), 'YYMMDDHH24MISS') INTO timestamp_part;

    -- Generate a random 4-character alphanumeric string
    SELECT gen_random_alphanumeric(4) INTO random_part;

    -- Concatenate the two parts with a hyphen
    RETURN timestamp_part || '-' || random_part;
END;
$$ LANGUAGE plpgsql;


-- START: AUTHENTICATION AND AUTHORIZATION FUNCTIONS ------------------------------
-- -------------------------------------------------------------------
-- Function to check if a session ID exists in the user_sessions table
CREATE OR REPLACE FUNCTION get_session_data(p_session_id VARCHAR(36))
RETURNS BOOLEAN AS $$
DECLARE
    session_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO session_count
    FROM public.user_sessions
    WHERE sessionid = p_session_id;

    RETURN session_count > 0;
END;
$$ LANGUAGE plpgsql;



-- -------------------------------------------------------------------
-- Function to retrieve a distinct list of role names for a given user_luid
CREATE OR REPLACE FUNCTION public.get_user_roles(
    p_user_luid character varying(36)
)
RETURNS SETOF character varying
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Return the distinct role names by joining the necessary tables.
    RETURN QUERY
    SELECT
        DISTINCT r.role_name
    FROM
        public.users AS u
    INNER JOIN
        public.user_groups AS ug ON u.user_luid = ug.user_luid
    INNER JOIN
        public.group_roles AS gr ON ug.group_id = gr.group_id
    INNER JOIN
        public.roles AS r ON gr.role_id = r.role_id
    WHERE
        u.user_luid = p_user_luid;

END;
$BODY$;


-- -------------------------------------------------------------------
-- Function to retrieve a pipe delimited distinct list of role names for a given user_luid
CREATE OR REPLACE FUNCTION public.get_piped_user_roles(
    p_user_luid character varying(36)
)
RETURNS TEXT
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
v_roles TEXT;
BEGIN
    -- Return the pipe delimited distinct role names by joining the necessary tables.
SELECT DISTINCT string_agg(r.role_name, '|') INTO v_roles
FROM
    public.users AS u
        INNER JOIN
    public.user_groups AS ug ON u.user_luid = ug.user_luid
        INNER JOIN
    public.group_roles AS gr ON ug.group_id = gr.group_id
        INNER JOIN
    public.roles AS r ON gr.role_id = r.role_id
WHERE
    u.user_luid = p_user_luid;
RETURN v_roles;
END;
$BODY$;


-- -------------------------------------------------------------------
-- Function to retrieve the list of roles (as a pipe delimited string) for a given email_address and encrypted_password
CREATE OR REPLACE FUNCTION public.authenticate_user(
	p_email_address text,
	p_encrypted_password text)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_retval character varying(44);
    -- Variable to hold the user's user_luid if found
    v_user_luid character varying(36);
	v_user_type character varying(8);
	v_user_plan character varying(36);
    -- Variable to hold the generated alphanumeric string (token)
    v_sessionid character varying(12);
	-- Variable to hold the pipe delimited list of roles
	v_roles TEXT;
	-- Variable to hold the expiry time of the user session record
	v_expires_at timestamp with time zone;
BEGIN
    -- 1. Check for a matching user record
    SELECT user_luid, user_type, user_plan INTO v_user_luid, v_user_type, v_user_plan
    FROM users
    WHERE email_address = p_email_address
      AND encrypted_password = p_encrypted_password;

    -- 2. Evaluate the result
    IF FOUND THEN
		-- A user record was found
		-- delete any existing user sessions the user may have
		DELETE from user_sessions where email_address = p_email_address;
        -- generate a token using gen_random_alphanumeric
        SELECT gen_random_alphanumeric(12) INTO v_sessionid;
		-- get the pipe delimited list of roles for the user
		SELECT get_piped_user_roles(v_user_luid) INTO v_roles;
		SELECT NOW() + INTERVAL '24 hours' into v_expires_at;
		-- add a user session record for the user
		INSERT INTO user_sessions (sessionid, email_address, user_luid, user_type, user_plan, user_roles, expires_at)
		  VALUES (v_sessionid, p_email_address, v_user_luid, v_user_type, v_user_plan, v_roles, v_expires_at);
		v_retval := v_sessionid || '|' || v_user_type;
		RETURN v_retval;
    ELSE
        -- No user record was found: return 'unauthorized'
        RETURN 'unauthorized';
    END IF;
END;
$BODY$;


-- ------------------------------------------------------------------------------
-- Function to get the user's roles from the user_sessions table
CREATE OR REPLACE FUNCTION get_user_session_roles(p_session_id VARCHAR(36))
RETURNS TEXT
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
  v_session_roles TEXT;
  v_expires_at timestamp with time zone;
BEGIN
  SELECT user_roles, expires_at INTO v_session_roles, v_expires_at
  FROM public.user_sessions
  WHERE sessionid = p_session_id;

  IF FOUND THEN
    IF now() < v_expires_at THEN
      RETURN v_session_roles;
    ELSE
	  RETURN 'session expired';
	END IF;
  ELSE
    RETURN 'session expired';
  END IF;
END;
$BODY$;


-- ------------------------------------------------------------------------
-- Function to delete the user's session record from the user_sessions table
CREATE OR REPLACE FUNCTION delete_user_session(
    P_sessionid CHARACTER VARYING(12)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Execute the DELETE statement
DELETE FROM user_sessions
WHERE sessionid = P_sessionid;
END;
$$;


-- ------------------------------------------------------------------------
-- Function to generate a password reset GUID for a given email address
CREATE OR REPLACE FUNCTION password_reset_guid(
    p_email_address TEXT
)
RETURNS character varying(16)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Variable to hold the user's user_luid if found
    v_user_luid character varying(36);
	v_password_reset_guid character varying(16);
	-- Variable to hold the expiry time for the password reset link
	v_password_reset_expiry timestamp with time zone;
BEGIN
    -- 1. Check for a matching user record
    SELECT user_luid INTO v_user_luid
    FROM users
    WHERE email_address = p_email_address;

    -- 2. Evaluate the result
    IF FOUND THEN
		-- A user record was found
        -- generate a token using gen_random_alphanumeric
        SELECT gen_random_alphanumeric(16) INTO v_password_reset_guid;
		SELECT NOW() + INTERVAL '10 minutes' into v_password_reset_expiry;
		-- update the user's user record for
		UPDATE users set password_reset_guid = v_password_reset_guid,
		  password_reset_expiry = v_password_reset_expiry
		  WHERE email_address = p_email_address;
        RETURN v_password_reset_guid;
    ELSE
        -- No user record was found: return 'unauthorized'
        RETURN 'no such email address';
    END IF;
END;
$$;


-- ------------------------------------------------------------------------
-- Function to update the user's password using a password reset GUID'
CREATE OR REPLACE FUNCTION public.update_password_by_reset_guid(
	p_password_reset_guid character varying,
	p_new_encrypted_password character varying)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    -- Variable to hold the user's user_luid if found
    v_password_reset_expiry timestamp with time zone;
BEGIN
    -- 1. Check for a matching user record
    SELECT password_reset_expiry INTO v_password_reset_expiry
    FROM users
    WHERE password_reset_guid = p_password_reset_guid;

    -- 2. Evaluate the result
    IF FOUND THEN
        IF now() < v_password_reset_expiry THEN
            -- update the user's user record for
            UPDATE users set encrypted_password = p_new_encrypted_password, password_reset_expiry = now()
            WHERE password_reset_guid = p_password_reset_guid;
            RETURN 'password successfully reset';
		ELSE
			-- Password reset link is expired
        	RETURN 'expired password reset link';
        END IF;
	ELSE
		-- Password reset link is invalid
		RETURN 'invalid password reset link';
    END IF;
END;
$BODY$;

-- END: AUTHENTICATION AND AUTHORIZATION FUNCTIONS ------------------------------
