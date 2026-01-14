-- THIS FILE REPRESENTS THE MINIMUM DATA YOU NEED TO INSERT TO SEED THE DATABASE FOR DEVELOPMENT & TESTING

-- RESEED THE ENTIRE DATABASE WITH SAMPLE DATA
DELETE FROM public.member_items; -- Clear existing member items
DELETE FROM public.todos; -- Clear existing todos
DELETE FROM public.user_sessions; -- Clear existing session data
DELETE FROM public.group_roles; -- Clear existing group_roles
DELETE FROM public.user_groups; -- Clear existing user_groups
DELETE FROM public.roles; -- Clear existing roles
ALTER SEQUENCE roles_role_id_seq RESTART WITH 1;
DELETE FROM public.groups; -- Clear existing groups
ALTER SEQUENCE groups_group_id_seq RESTART WITH 1;
DELETE FROM public.users; -- Clear existing users

-- USERS
INSERT INTO public.users (user_luid, email_address, encrypted_password, sponsor_code, user_type, user_plan, member_profile_json, sponsor_profile_json)
VALUES ('aaaa', 'aki@mindpeak.biz', 'Justin4836', 'AKIJET', 'admin', 'admin', '{"first_name": "Aki", "last_name": "Iskandar"}', NULL);
    
INSERT INTO public.users (user_luid, email_address, encrypted_password, sponsor_code, user_type, user_plan, member_profile_json, sponsor_profile_json)
VALUES ('cafe', 'aki@iskandar.us', 'Justin4836', 'AKIJET', 'member', 'sponsored member', '{"first_name": "Aki", "last_name": "Iskandar"}', NULL);

INSERT INTO public.users (user_luid, email_address, encrypted_password, sponsor_code, user_type, user_plan, member_profile_json, sponsor_profile_json)
VALUES ('abcdef', 'peter@proton.me', 'Justin4836', 'AKIJET', 'sponsor', 'trial sponsor', NULL, '{"first_name": "Peter", "last_name": "Iskandar"}');

-- GROUPS
INSERT INTO public.groups (group_name)
VALUES ('Admins');

INSERT INTO public.groups (group_name)
VALUES ('Members');

INSERT INTO public.groups (group_name)
VALUES ('Sponsors');

-- ROLES
INSERT INTO public.roles (role_name)
VALUES ('admin');

INSERT INTO public.roles (role_name)
VALUES ('member');

INSERT INTO public.roles (role_name)
VALUES ('sponsor');

-- USER_GROUPS
INSERT INTO public.user_groups (user_luid, group_id)
VALUES ('aaaa', 1);

INSERT INTO public.user_groups (user_luid, group_id)
VALUES ('cafe', 2);

INSERT INTO public.user_groups (user_luid, group_id)
VALUES ('abcdef', 3);

-- GROUP_ROLES
INSERT INTO public.group_roles (group_id, role_id)
VALUES (1, 1);

INSERT INTO public.group_roles (group_id, role_id)
VALUES (2, 2);

INSERT INTO public.group_roles (group_id, role_id)
VALUES (3, 3);

-- USER_SESSIONS
INSERT INTO public.user_sessions (sessionid, email_address, user_luid, user_type, user_plan, sponsor_code, expires_at)
VALUES ('38e60997-73f8-48f1-b63a-bc740e591854', 'aki@iskandar.us', 'cafe', 'member', 'sponsored member', 'AKIJET', now() + INTERVAL '24 hours');

-- TODOS
INSERT INTO public.todos (entity_luid, user_luid, title, description, completed, created_at, updated_at)
VALUES (gen_entity_luid(), 'cafe', 'Sample Todo 1', 'This is a sample todo item (for a sponsored user).', false, now(), now());

INSERT INTO public.todos (entity_luid, user_luid, title, description, completed, created_at, updated_at)
VALUES (gen_entity_luid(), 'cafe', 'Sample Todo 2', 'This is another sample todo item (for a sponsored user).', false, now(), now());

INSERT INTO public.todos (entity_luid, user_luid, title, description, completed, created_at, updated_at)
VALUES (gen_entity_luid(), 'abcdef', 'Sample Todo 3', 'Update branding carousel (for a sponsor).', false, now(), now());


-- -------------------------------------------------------------------------------------------------
-- THE FOLLOWING EXAMPLE INSERT STATEMENTS ARE FOR WHEN YOU NEED TO CREATE MORE GRANULAR PERMISSIONS
INSERT INTO public.roles (role_name)
VALUES ('branding_stage_all_crud'); -- only when I implement mutiple branding stages (Phase 2)
INSERT INTO public.roles (role_name)
VALUES ('branding_stage_listing'); -- only when I implement mutiple branding stages (Phase 2)
INSERT INTO public.roles (role_name)
VALUES ('branding_stage_detail'); -- Phase 1
INSERT INTO public.roles (role_name)
VALUES ('branding_stage_create'); -- only when I implement mutiple branding stages (Phase 2)
INSERT INTO public.roles (role_name)
VALUES ('branding_stage_update'); -- Phase 1
INSERT INTO public.roles (role_name)
VALUES ('branding_stage_publish'); -- Special role for publishing (for Phase 1)
INSERT INTO public.roles (role_name)
VALUES ('branding_stage_delete'); -- only when I implement mutiple branding stages (Phase 2)

INSERT INTO public.roles (role_name)
VALUES ('todos_all_crud');
INSERT INTO public.roles (role_name)
VALUES ('todos_listing');
INSERT INTO public.roles (role_name)
VALUES ('todos_detail');
INSERT INTO public.roles (role_name)
VALUES ('todos_create');
INSERT INTO public.roles (role_name)
VALUES ('todos_update');
INSERT INTO public.roles (role_name)
VALUES ('todos_delete');
-- -------------------------------------------------------------------------------------------------