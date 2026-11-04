\restrict dbmate

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: auth_token_purpose; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.auth_token_purpose AS ENUM (
    'email_verification',
    'password_reset'
);


--
-- Name: child_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.child_status AS ENUM (
    'active',
    'archived'
);


--
-- Name: invitation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.invitation_status AS ENUM (
    'pending',
    'accepted',
    'expired',
    'cancelled'
);


--
-- Name: post_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.post_type AS ENUM (
    'meal',
    'nap',
    'activity',
    'achievement',
    'mood',
    'photo',
    'announcement'
);


--
-- Name: relationship_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.relationship_type AS ENUM (
    'father',
    'mother',
    'guardian'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'staff',
    'parent',
    'admin'
);


--
-- Name: user_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_status AS ENUM (
    'pending',
    'active',
    'disabled'
);


--
-- Name: enforce_invitation_acceptor(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_invitation_acceptor() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.accepted_by IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM users
        WHERE id = NEW.accepted_by AND daycare_id = NEW.daycare_id
    ) THEN
        RAISE EXCEPTION 'accepted_by must belong to the same daycare'
            USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: enforce_parent_child_role(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_parent_child_role() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users
        WHERE id = NEW.parent_id AND daycare_id = NEW.daycare_id AND role = 'parent'
    ) THEN
        RAISE EXCEPTION 'parent_children requires a parent user from the same daycare'
            USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: enforce_staff_room_role(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_staff_room_role() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM users
        WHERE id = NEW.user_id AND daycare_id = NEW.daycare_id AND role = 'staff'
    ) THEN
        RAISE EXCEPTION 'staff_rooms requires a staff user from the same daycare'
            USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_tokens (
    id uuid DEFAULT uuidv7() NOT NULL,
    user_id uuid NOT NULL,
    purpose public.auth_token_purpose NOT NULL,
    token_hash bytea NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT auth_tokens_expiry_after_creation CHECK ((expires_at > created_at)),
    CONSTRAINT auth_tokens_token_hash_check CHECK ((octet_length(token_hash) = 32))
);


--
-- Name: children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.children (
    id uuid DEFAULT uuidv7() NOT NULL,
    daycare_id uuid NOT NULL,
    room_id uuid,
    full_name text NOT NULL,
    birth_date date NOT NULL,
    enrolled_at date NOT NULL,
    medical_notes text,
    allergy_tags text[] DEFAULT '{}'::text[] NOT NULL,
    photo_consent boolean DEFAULT false NOT NULL,
    status public.child_status DEFAULT 'active'::public.child_status NOT NULL,
    archived_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT children_allergy_tags_check CHECK ((allergy_tags <@ ARRAY['peanut'::text, 'lactose'::text, 'gluten'::text, 'egg'::text, 'soy'::text, 'fish'::text, 'shellfish'::text, 'tree_nut'::text, 'sesame'::text])),
    CONSTRAINT children_archive_consistency CHECK (((status = 'archived'::public.child_status) = (archived_at IS NOT NULL))),
    CONSTRAINT children_birth_date_check CHECK ((birth_date > '1900-01-01'::date)),
    CONSTRAINT children_enrolled_after_birth CHECK ((enrolled_at >= birth_date)),
    CONSTRAINT children_full_name_check CHECK (((char_length(full_name) >= 1) AND (char_length(full_name) <= 120))),
    CONSTRAINT children_medical_notes_check CHECK (((medical_notes IS NULL) OR (char_length(medical_notes) <= 4000)))
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id uuid DEFAULT uuidv7() NOT NULL,
    daycare_id uuid NOT NULL,
    post_id uuid NOT NULL,
    author_id uuid NOT NULL,
    body text NOT NULL,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT comments_body_check CHECK (((char_length(body) >= 1) AND (char_length(body) <= 2000)))
);


--
-- Name: daily_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_summaries (
    id uuid DEFAULT uuidv7() NOT NULL,
    daycare_id uuid NOT NULL,
    child_id uuid NOT NULL,
    summary_date date NOT NULL,
    meals_count integer DEFAULT 0 NOT NULL,
    sleep_minutes integer DEFAULT 0 NOT NULL,
    activities_count integer DEFAULT 0 NOT NULL,
    mood text,
    highlight text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT daily_summaries_activities_count_check CHECK ((activities_count >= 0)),
    CONSTRAINT daily_summaries_highlight_check CHECK (((highlight IS NULL) OR (char_length(highlight) <= 500))),
    CONSTRAINT daily_summaries_meals_count_check CHECK ((meals_count >= 0)),
    CONSTRAINT daily_summaries_mood_check CHECK (((mood IS NULL) OR (char_length(mood) <= 200))),
    CONSTRAINT daily_summaries_sleep_minutes_check CHECK (((sleep_minutes >= 0) AND (sleep_minutes <= 1440)))
);


--
-- Name: data_access_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_access_log (
    id bigint NOT NULL,
    daycare_id uuid NOT NULL,
    user_id uuid NOT NULL,
    entity text NOT NULL,
    entity_id uuid NOT NULL,
    action text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT data_access_log_action_check CHECK ((action = ANY (ARRAY['read'::text, 'export'::text, 'delete'::text]))),
    CONSTRAINT data_access_log_entity_check CHECK ((entity = ANY (ARRAY['child'::text, 'medical_notes'::text, 'post'::text, 'post_photo'::text])))
);


--
-- Name: data_access_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.data_access_log ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.data_access_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: daycares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daycares (
    id uuid DEFAULT uuidv7() NOT NULL,
    name text NOT NULL,
    timezone text DEFAULT 'America/Mexico_City'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT daycares_name_check CHECK (((char_length(name) >= 1) AND (char_length(name) <= 120))),
    CONSTRAINT daycares_timezone_check CHECK ((timezone ~ '^[A-Za-z_]+(/[A-Za-z0-9_+-]+)+$'::text))
);


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devices (
    id uuid DEFAULT uuidv7() NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    platform text NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT devices_platform_check CHECK ((platform = ANY (ARRAY['ios'::text, 'android'::text, 'web'::text]))),
    CONSTRAINT devices_token_check CHECK ((char_length(token) <= 512))
);


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitations (
    id uuid DEFAULT uuidv7() NOT NULL,
    daycare_id uuid NOT NULL,
    child_id uuid NOT NULL,
    invited_by uuid NOT NULL,
    full_name text NOT NULL,
    email public.citext NOT NULL,
    relationship public.relationship_type NOT NULL,
    code text NOT NULL,
    status public.invitation_status DEFAULT 'pending'::public.invitation_status NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    accepted_at timestamp with time zone,
    accepted_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT invitations_accepted_consistency CHECK ((((status = 'accepted'::public.invitation_status) = (accepted_at IS NOT NULL)) AND ((accepted_by IS NULL) = (accepted_at IS NULL)))),
    CONSTRAINT invitations_code_check CHECK ((code ~ '^[A-Z0-9]{6,10}$'::text)),
    CONSTRAINT invitations_expiry_after_creation CHECK ((expires_at > created_at)),
    CONSTRAINT invitations_full_name_check CHECK (((char_length(full_name) >= 1) AND (char_length(full_name) <= 120)))
);


--
-- Name: parent_children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parent_children (
    daycare_id uuid NOT NULL,
    parent_id uuid NOT NULL,
    child_id uuid NOT NULL,
    relationship public.relationship_type NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: post_children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_children (
    daycare_id uuid NOT NULL,
    post_id uuid NOT NULL,
    child_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: post_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_photos (
    id uuid DEFAULT uuidv7() NOT NULL,
    post_id uuid NOT NULL,
    storage_key text NOT NULL,
    width integer,
    height integer,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT post_photos_height_check CHECK (((height IS NULL) OR (height > 0))),
    CONSTRAINT post_photos_position_check CHECK (("position" >= 0)),
    CONSTRAINT post_photos_storage_key_check CHECK ((char_length(storage_key) <= 512)),
    CONSTRAINT post_photos_width_check CHECK (((width IS NULL) OR (width > 0)))
);


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id uuid DEFAULT uuidv7() NOT NULL,
    daycare_id uuid NOT NULL,
    author_id uuid NOT NULL,
    room_id uuid,
    type public.post_type NOT NULL,
    title text,
    body text NOT NULL,
    published_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT posts_body_check CHECK (((char_length(body) >= 1) AND (char_length(body) <= 10000))),
    CONSTRAINT posts_title_check CHECK (((title IS NULL) OR (char_length(title) <= 200)))
);


--
-- Name: reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reactions (
    daycare_id uuid NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    type text DEFAULT 'love'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reactions_type_check CHECK ((type = 'love'::text))
);


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
    id uuid DEFAULT uuidv7() NOT NULL,
    daycare_id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT rooms_name_check CHECK (((char_length(name) >= 1) AND (char_length(name) <= 80)))
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: staff_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_rooms (
    daycare_id uuid NOT NULL,
    user_id uuid NOT NULL,
    room_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_sessions (
    id uuid DEFAULT uuidv7() NOT NULL,
    user_id uuid NOT NULL,
    refresh_token_hash bytea NOT NULL,
    user_agent text,
    ip inet,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_sessions_expiry_after_creation CHECK ((expires_at > created_at)),
    CONSTRAINT user_sessions_refresh_token_hash_check CHECK ((octet_length(refresh_token_hash) = 32)),
    CONSTRAINT user_sessions_user_agent_check CHECK (((user_agent IS NULL) OR (char_length(user_agent) <= 512)))
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT uuidv7() NOT NULL,
    daycare_id uuid NOT NULL,
    role public.user_role NOT NULL,
    status public.user_status DEFAULT 'pending'::public.user_status NOT NULL,
    email public.citext NOT NULL,
    password_hash text,
    email_verified_at timestamp with time zone,
    full_name text NOT NULL,
    avatar_key text,
    notify_on_post boolean DEFAULT true NOT NULL,
    daily_summary_enabled boolean DEFAULT true NOT NULL,
    last_login_at timestamp with time zone,
    token_version bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT users_active_requires_password CHECK (((password_hash IS NOT NULL) OR (status <> 'active'::public.user_status))),
    CONSTRAINT users_avatar_key_check CHECK (((avatar_key IS NULL) OR (char_length(avatar_key) <= 512))),
    CONSTRAINT users_email_check CHECK ((email OPERATOR(public.~) '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'::public.citext)),
    CONSTRAINT users_full_name_check CHECK (((char_length(full_name) >= 1) AND (char_length(full_name) <= 120))),
    CONSTRAINT users_password_hash_check CHECK (((password_hash IS NULL) OR (password_hash ~~ '$argon2id$%'::text))),
    CONSTRAINT users_token_version_check CHECK ((token_version >= 0))
);


--
-- Name: auth_tokens auth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_tokens
    ADD CONSTRAINT auth_tokens_pkey PRIMARY KEY (id);


--
-- Name: auth_tokens auth_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_tokens
    ADD CONSTRAINT auth_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: children children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.children
    ADD CONSTRAINT children_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: daily_summaries daily_summaries_child_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_summaries
    ADD CONSTRAINT daily_summaries_child_date_key UNIQUE (child_id, summary_date);


--
-- Name: daily_summaries daily_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_summaries
    ADD CONSTRAINT daily_summaries_pkey PRIMARY KEY (id);


--
-- Name: data_access_log data_access_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_access_log
    ADD CONSTRAINT data_access_log_pkey PRIMARY KEY (id);


--
-- Name: daycares daycares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daycares
    ADD CONSTRAINT daycares_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: devices devices_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_token_key UNIQUE (token);


--
-- Name: invitations invitations_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_code_key UNIQUE (code);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: parent_children parent_children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_children
    ADD CONSTRAINT parent_children_pkey PRIMARY KEY (parent_id, child_id);


--
-- Name: post_children post_children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_children
    ADD CONSTRAINT post_children_pkey PRIMARY KEY (post_id, child_id);


--
-- Name: post_photos post_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_photos
    ADD CONSTRAINT post_photos_pkey PRIMARY KEY (id);


--
-- Name: post_photos post_photos_position_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_photos
    ADD CONSTRAINT post_photos_position_key UNIQUE (post_id, "position");


--
-- Name: post_photos post_photos_storage_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_photos
    ADD CONSTRAINT post_photos_storage_key_key UNIQUE (storage_key);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: reactions reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_pkey PRIMARY KEY (post_id, user_id);


--
-- Name: rooms rooms_daycare_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_daycare_name_key UNIQUE (daycare_id, name);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: staff_rooms staff_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_rooms
    ADD CONSTRAINT staff_rooms_pkey PRIMARY KEY (user_id, room_id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_refresh_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_refresh_token_hash_key UNIQUE (refresh_token_hash);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: auth_tokens_active_expiry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_tokens_active_expiry_idx ON public.auth_tokens USING btree (expires_at) WHERE (used_at IS NULL);


--
-- Name: auth_tokens_active_purpose_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX auth_tokens_active_purpose_key ON public.auth_tokens USING btree (user_id, purpose) WHERE (used_at IS NULL);


--
-- Name: children_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX children_active_idx ON public.children USING btree (daycare_id) WHERE (status = 'active'::public.child_status);


--
-- Name: children_daycare_id_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX children_daycare_id_id_key ON public.children USING btree (daycare_id, id);


--
-- Name: children_daycare_room_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX children_daycare_room_idx ON public.children USING btree (daycare_id, room_id);


--
-- Name: comments_author_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_author_id_idx ON public.comments USING btree (author_id);


--
-- Name: comments_post_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_post_created_idx ON public.comments USING btree (post_id, created_at) WHERE (deleted_at IS NULL);


--
-- Name: daily_summaries_daycare_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX daily_summaries_daycare_date_idx ON public.daily_summaries USING btree (daycare_id, summary_date);


--
-- Name: data_access_log_daycare_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX data_access_log_daycare_created_idx ON public.data_access_log USING btree (daycare_id, created_at DESC);


--
-- Name: devices_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX devices_user_id_idx ON public.devices USING btree (user_id);


--
-- Name: invitations_accepted_by_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitations_accepted_by_idx ON public.invitations USING btree (accepted_by) WHERE (accepted_by IS NOT NULL);


--
-- Name: invitations_invited_by_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitations_invited_by_idx ON public.invitations USING btree (invited_by);


--
-- Name: invitations_pending_expiry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invitations_pending_expiry_idx ON public.invitations USING btree (expires_at) WHERE (status = 'pending'::public.invitation_status);


--
-- Name: invitations_pending_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitations_pending_key ON public.invitations USING btree (daycare_id, child_id, email) WHERE (status = 'pending'::public.invitation_status);


--
-- Name: parent_children_child_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX parent_children_child_id_idx ON public.parent_children USING btree (child_id);


--
-- Name: post_children_child_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX post_children_child_id_idx ON public.post_children USING btree (child_id);


--
-- Name: posts_author_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_author_id_idx ON public.posts USING btree (author_id);


--
-- Name: posts_daycare_id_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX posts_daycare_id_id_key ON public.posts USING btree (daycare_id, id);


--
-- Name: posts_feed_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_feed_idx ON public.posts USING btree (daycare_id, published_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: posts_room_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_room_id_idx ON public.posts USING btree (room_id);


--
-- Name: reactions_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reactions_user_id_idx ON public.reactions USING btree (user_id);


--
-- Name: rooms_daycare_id_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rooms_daycare_id_id_key ON public.rooms USING btree (daycare_id, id);


--
-- Name: staff_rooms_room_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_rooms_room_id_idx ON public.staff_rooms USING btree (room_id);


--
-- Name: user_sessions_active_expiry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_sessions_active_expiry_idx ON public.user_sessions USING btree (expires_at) WHERE (revoked_at IS NULL);


--
-- Name: user_sessions_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_sessions_user_id_idx ON public.user_sessions USING btree (user_id);


--
-- Name: users_daycare_id_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_daycare_id_id_key ON public.users USING btree (daycare_id, id);


--
-- Name: users_daycare_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_daycare_id_idx ON public.users USING btree (daycare_id);


--
-- Name: children children_set_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER children_set_updated_at BEFORE UPDATE ON public.children FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: comments comments_set_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER comments_set_updated_at BEFORE UPDATE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: daily_summaries daily_summaries_set_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER daily_summaries_set_updated_at BEFORE UPDATE ON public.daily_summaries FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: daycares daycares_set_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER daycares_set_updated_at BEFORE UPDATE ON public.daycares FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: invitations invitations_enforce_acceptor; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER invitations_enforce_acceptor BEFORE INSERT OR UPDATE ON public.invitations FOR EACH ROW EXECUTE FUNCTION public.enforce_invitation_acceptor();


--
-- Name: invitations invitations_set_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER invitations_set_updated_at BEFORE UPDATE ON public.invitations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: parent_children parent_children_enforce_role; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER parent_children_enforce_role BEFORE INSERT OR UPDATE ON public.parent_children FOR EACH ROW EXECUTE FUNCTION public.enforce_parent_child_role();


--
-- Name: posts posts_set_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER posts_set_updated_at BEFORE UPDATE ON public.posts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: rooms rooms_set_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rooms_set_updated_at BEFORE UPDATE ON public.rooms FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: staff_rooms staff_rooms_enforce_role; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER staff_rooms_enforce_role BEFORE INSERT OR UPDATE ON public.staff_rooms FOR EACH ROW EXECUTE FUNCTION public.enforce_staff_room_role();


--
-- Name: users users_set_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER users_set_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: auth_tokens auth_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_tokens
    ADD CONSTRAINT auth_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: children children_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.children
    ADD CONSTRAINT children_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: children children_room_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.children
    ADD CONSTRAINT children_room_same_daycare FOREIGN KEY (daycare_id, room_id) REFERENCES public.rooms(daycare_id, id) ON DELETE RESTRICT;


--
-- Name: comments comments_author_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_author_same_daycare FOREIGN KEY (daycare_id, author_id) REFERENCES public.users(daycare_id, id) ON DELETE RESTRICT;


--
-- Name: comments comments_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: comments comments_post_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_same_daycare FOREIGN KEY (daycare_id, post_id) REFERENCES public.posts(daycare_id, id) ON DELETE CASCADE;


--
-- Name: daily_summaries daily_summaries_child_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_summaries
    ADD CONSTRAINT daily_summaries_child_same_daycare FOREIGN KEY (daycare_id, child_id) REFERENCES public.children(daycare_id, id) ON DELETE CASCADE;


--
-- Name: daily_summaries daily_summaries_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_summaries
    ADD CONSTRAINT daily_summaries_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: data_access_log data_access_log_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_access_log
    ADD CONSTRAINT data_access_log_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: data_access_log data_access_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_access_log
    ADD CONSTRAINT data_access_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: devices devices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: invitations invitations_accepted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_accepted_by_fkey FOREIGN KEY (accepted_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: invitations invitations_child_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_child_same_daycare FOREIGN KEY (daycare_id, child_id) REFERENCES public.children(daycare_id, id) ON DELETE CASCADE;


--
-- Name: invitations invitations_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: invitations invitations_inviter_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_inviter_same_daycare FOREIGN KEY (daycare_id, invited_by) REFERENCES public.users(daycare_id, id) ON DELETE RESTRICT;


--
-- Name: parent_children parent_children_child_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_children
    ADD CONSTRAINT parent_children_child_same_daycare FOREIGN KEY (daycare_id, child_id) REFERENCES public.children(daycare_id, id) ON DELETE CASCADE;


--
-- Name: parent_children parent_children_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_children
    ADD CONSTRAINT parent_children_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: parent_children parent_children_parent_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_children
    ADD CONSTRAINT parent_children_parent_same_daycare FOREIGN KEY (daycare_id, parent_id) REFERENCES public.users(daycare_id, id) ON DELETE CASCADE;


--
-- Name: post_children post_children_child_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_children
    ADD CONSTRAINT post_children_child_same_daycare FOREIGN KEY (daycare_id, child_id) REFERENCES public.children(daycare_id, id) ON DELETE CASCADE;


--
-- Name: post_children post_children_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_children
    ADD CONSTRAINT post_children_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: post_children post_children_post_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_children
    ADD CONSTRAINT post_children_post_same_daycare FOREIGN KEY (daycare_id, post_id) REFERENCES public.posts(daycare_id, id) ON DELETE CASCADE;


--
-- Name: post_photos post_photos_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_photos
    ADD CONSTRAINT post_photos_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: posts posts_author_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_author_same_daycare FOREIGN KEY (daycare_id, author_id) REFERENCES public.users(daycare_id, id) ON DELETE RESTRICT;


--
-- Name: posts posts_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: posts posts_room_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_room_same_daycare FOREIGN KEY (daycare_id, room_id) REFERENCES public.rooms(daycare_id, id) ON DELETE RESTRICT;


--
-- Name: reactions reactions_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: reactions reactions_post_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_post_same_daycare FOREIGN KEY (daycare_id, post_id) REFERENCES public.posts(daycare_id, id) ON DELETE CASCADE;


--
-- Name: reactions reactions_user_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_user_same_daycare FOREIGN KEY (daycare_id, user_id) REFERENCES public.users(daycare_id, id) ON DELETE CASCADE;


--
-- Name: rooms rooms_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: staff_rooms staff_rooms_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_rooms
    ADD CONSTRAINT staff_rooms_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- Name: staff_rooms staff_rooms_room_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_rooms
    ADD CONSTRAINT staff_rooms_room_same_daycare FOREIGN KEY (daycare_id, room_id) REFERENCES public.rooms(daycare_id, id) ON DELETE CASCADE;


--
-- Name: staff_rooms staff_rooms_user_same_daycare; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_rooms
    ADD CONSTRAINT staff_rooms_user_same_daycare FOREIGN KEY (daycare_id, user_id) REFERENCES public.users(daycare_id, id) ON DELETE CASCADE;


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_daycare_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_daycare_id_fkey FOREIGN KEY (daycare_id) REFERENCES public.daycares(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict dbmate


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20261104000000');
