-- migrate:up
-- OpenDayCare — 20261104000000__init.sql
-- PostgreSQL 18. Aplicar con dbmate como app_migrator.
-- Orden: extensiones -> enums -> tablas (con FKs compuestas de tenant) -> triggers -> índices.

SET timezone = 'UTC';

CREATE EXTENSION IF NOT EXISTS citext;

-- ---------------------------------------------------------------------------
-- Enums (solo conjuntos pequeños y estables)
-- ---------------------------------------------------------------------------

CREATE TYPE user_role AS ENUM ('staff', 'parent', 'admin');
CREATE TYPE user_status AS ENUM ('pending', 'active', 'disabled');
CREATE TYPE auth_token_purpose AS ENUM ('email_verification', 'password_reset');
CREATE TYPE relationship_type AS ENUM ('father', 'mother', 'guardian');
CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'expired', 'cancelled');
CREATE TYPE post_type AS ENUM ('meal', 'nap', 'activity', 'achievement', 'mood', 'photo', 'announcement');
CREATE TYPE child_status AS ENUM ('active', 'archived');

-- ---------------------------------------------------------------------------
-- 1. daycares
-- ---------------------------------------------------------------------------

CREATE TABLE daycares (
    id         uuid PRIMARY KEY DEFAULT uuidv7(),
    name       text NOT NULL CHECK (char_length(name) BETWEEN 1 AND 120),
    timezone   text NOT NULL DEFAULT 'America/Mexico_City'
               CHECK (timezone ~ '^[A-Za-z_]+(/[A-Za-z0-9_+-]+)+$'),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 2. users
-- ---------------------------------------------------------------------------

CREATE TABLE users (
    id                    uuid PRIMARY KEY DEFAULT uuidv7(),
    daycare_id            uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    role                  user_role NOT NULL,
    status                user_status NOT NULL DEFAULT 'pending',
    email                 citext NOT NULL UNIQUE
                          CHECK (email ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
    password_hash         text
                          CHECK (password_hash IS NULL OR password_hash LIKE '$argon2id$%'),
    email_verified_at     timestamptz,
    full_name             text NOT NULL CHECK (char_length(full_name) BETWEEN 1 AND 120),
    avatar_key            text CHECK (avatar_key IS NULL OR char_length(avatar_key) <= 512),
    notify_on_post        boolean NOT NULL DEFAULT true,
    daily_summary_enabled boolean NOT NULL DEFAULT true,
    last_login_at         timestamptz,
    token_version         bigint NOT NULL DEFAULT 0 CHECK (token_version >= 0),
    created_at            timestamptz NOT NULL DEFAULT now(),
    updated_at            timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT users_active_requires_password
        CHECK (password_hash IS NOT NULL OR status <> 'active')
);

-- Target de las FKs compuestas de tenant
CREATE UNIQUE INDEX users_daycare_id_id_key ON users (daycare_id, id);
CREATE INDEX users_daycare_id_idx ON users (daycare_id);

-- ---------------------------------------------------------------------------
-- 3. user_sessions
-- ---------------------------------------------------------------------------

CREATE TABLE user_sessions (
    id                 uuid PRIMARY KEY DEFAULT uuidv7(),
    user_id            uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    refresh_token_hash bytea NOT NULL UNIQUE
                       CHECK (octet_length(refresh_token_hash) = 32),
    user_agent         text CHECK (user_agent IS NULL OR char_length(user_agent) <= 512),
    ip                 inet,
    expires_at         timestamptz NOT NULL,
    revoked_at         timestamptz,
    created_at         timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT user_sessions_expiry_after_creation CHECK (expires_at > created_at)
);

CREATE INDEX user_sessions_user_id_idx ON user_sessions (user_id);
CREATE INDEX user_sessions_active_expiry_idx ON user_sessions (expires_at)
    WHERE revoked_at IS NULL;

-- ---------------------------------------------------------------------------
-- 4. auth_tokens
-- ---------------------------------------------------------------------------

CREATE TABLE auth_tokens (
    id         uuid PRIMARY KEY DEFAULT uuidv7(),
    user_id    uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    purpose    auth_token_purpose NOT NULL,
    token_hash bytea NOT NULL UNIQUE CHECK (octet_length(token_hash) = 32),
    expires_at timestamptz NOT NULL,
    used_at    timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT auth_tokens_expiry_after_creation CHECK (expires_at > created_at)
);

-- Un solo token pendiente por usuario y propósito
CREATE UNIQUE INDEX auth_tokens_active_purpose_key ON auth_tokens (user_id, purpose)
    WHERE used_at IS NULL;
CREATE INDEX auth_tokens_active_expiry_idx ON auth_tokens (expires_at)
    WHERE used_at IS NULL;

-- ---------------------------------------------------------------------------
-- 5. rooms
-- ---------------------------------------------------------------------------

CREATE TABLE rooms (
    id         uuid PRIMARY KEY DEFAULT uuidv7(),
    daycare_id uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    name       text NOT NULL CHECK (char_length(name) BETWEEN 1 AND 80),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT rooms_daycare_name_key UNIQUE (daycare_id, name)
);

CREATE UNIQUE INDEX rooms_daycare_id_id_key ON rooms (daycare_id, id);

-- ---------------------------------------------------------------------------
-- 6. staff_rooms
-- ---------------------------------------------------------------------------

CREATE TABLE staff_rooms (
    daycare_id uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    user_id    uuid NOT NULL,
    room_id    uuid NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, room_id),
    CONSTRAINT staff_rooms_user_same_daycare
        FOREIGN KEY (daycare_id, user_id) REFERENCES users (daycare_id, id)
        ON DELETE CASCADE,
    CONSTRAINT staff_rooms_room_same_daycare
        FOREIGN KEY (daycare_id, room_id) REFERENCES rooms (daycare_id, id)
        ON DELETE CASCADE
);

CREATE INDEX staff_rooms_room_id_idx ON staff_rooms (room_id);

-- ---------------------------------------------------------------------------
-- 7. children
-- ---------------------------------------------------------------------------

CREATE TABLE children (
    id             uuid PRIMARY KEY DEFAULT uuidv7(),
    daycare_id     uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    room_id        uuid,
    full_name      text NOT NULL CHECK (char_length(full_name) BETWEEN 1 AND 120),
    birth_date     date NOT NULL CHECK (birth_date > DATE '1900-01-01'),
    enrolled_at    date NOT NULL,
    medical_notes  text CHECK (medical_notes IS NULL OR char_length(medical_notes) <= 4000),
    allergy_tags   text[] NOT NULL DEFAULT '{}'
                   CHECK (allergy_tags <@ ARRAY['peanut', 'lactose', 'gluten', 'egg', 'soy',
                                                'fish', 'shellfish', 'tree_nut', 'sesame']::text[]),
    photo_consent  boolean NOT NULL DEFAULT false,
    status         child_status NOT NULL DEFAULT 'active',
    archived_at    timestamptz,
    created_at     timestamptz NOT NULL DEFAULT now(),
    updated_at     timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT children_enrolled_after_birth CHECK (enrolled_at >= birth_date),
    CONSTRAINT children_room_same_daycare
        FOREIGN KEY (daycare_id, room_id) REFERENCES rooms (daycare_id, id)
        ON DELETE RESTRICT,
    CONSTRAINT children_archive_consistency
        CHECK ((status = 'archived') = (archived_at IS NOT NULL))
);

CREATE UNIQUE INDEX children_daycare_id_id_key ON children (daycare_id, id);
CREATE INDEX children_daycare_room_idx ON children (daycare_id, room_id);
CREATE INDEX children_active_idx ON children (daycare_id) WHERE status = 'active';

-- ---------------------------------------------------------------------------
-- 8. parent_children
-- ---------------------------------------------------------------------------

CREATE TABLE parent_children (
    daycare_id   uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    parent_id    uuid NOT NULL,
    child_id     uuid NOT NULL,
    relationship relationship_type NOT NULL,
    created_at   timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (parent_id, child_id),
    CONSTRAINT parent_children_parent_same_daycare
        FOREIGN KEY (daycare_id, parent_id) REFERENCES users (daycare_id, id)
        ON DELETE CASCADE,
    CONSTRAINT parent_children_child_same_daycare
        FOREIGN KEY (daycare_id, child_id) REFERENCES children (daycare_id, id)
        ON DELETE CASCADE
);

CREATE INDEX parent_children_child_id_idx ON parent_children (child_id);

-- ---------------------------------------------------------------------------
-- 9. invitations
-- ---------------------------------------------------------------------------

CREATE TABLE invitations (
    id            uuid PRIMARY KEY DEFAULT uuidv7(),
    daycare_id    uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    child_id      uuid NOT NULL,
    invited_by    uuid NOT NULL,
    full_name     text NOT NULL CHECK (char_length(full_name) BETWEEN 1 AND 120),
    email         citext NOT NULL,
    relationship  relationship_type NOT NULL,
    code          text NOT NULL UNIQUE CHECK (code ~ '^[A-Z0-9]{6,10}$'),
    status        invitation_status NOT NULL DEFAULT 'pending',
    expires_at    timestamptz NOT NULL,
    accepted_at   timestamptz,
    accepted_by   uuid REFERENCES users (id) ON DELETE SET NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT invitations_expiry_after_creation CHECK (expires_at > created_at),
    CONSTRAINT invitations_accepted_consistency
        CHECK ((status = 'accepted') = (accepted_at IS NOT NULL)
               AND (accepted_by IS NULL) = (accepted_at IS NULL)),
    CONSTRAINT invitations_child_same_daycare
        FOREIGN KEY (daycare_id, child_id) REFERENCES children (daycare_id, id)
        ON DELETE CASCADE,
    CONSTRAINT invitations_inviter_same_daycare
        FOREIGN KEY (daycare_id, invited_by) REFERENCES users (daycare_id, id)
        ON DELETE RESTRICT
);

-- Una sola invitación pendiente por niño y email
CREATE UNIQUE INDEX invitations_pending_key
    ON invitations (daycare_id, child_id, email) WHERE status = 'pending';
CREATE INDEX invitations_invited_by_idx ON invitations (invited_by);
CREATE INDEX invitations_pending_expiry_idx ON invitations (expires_at)
    WHERE status = 'pending';
CREATE INDEX invitations_accepted_by_idx ON invitations (accepted_by)
    WHERE accepted_by IS NOT NULL;

-- ---------------------------------------------------------------------------
-- 10. posts
-- ---------------------------------------------------------------------------

CREATE TABLE posts (
    id           uuid PRIMARY KEY DEFAULT uuidv7(),
    daycare_id   uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    author_id    uuid NOT NULL,
    room_id      uuid,
    type         post_type NOT NULL,
    title        text CHECK (title IS NULL OR char_length(title) <= 200),
    body         text NOT NULL CHECK (char_length(body) BETWEEN 1 AND 10000),
    published_at timestamptz NOT NULL DEFAULT now(),
    deleted_at   timestamptz,
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT posts_author_same_daycare
        FOREIGN KEY (daycare_id, author_id) REFERENCES users (daycare_id, id)
        ON DELETE RESTRICT,
    CONSTRAINT posts_room_same_daycare
        FOREIGN KEY (daycare_id, room_id) REFERENCES rooms (daycare_id, id)
        ON DELETE RESTRICT
);

CREATE UNIQUE INDEX posts_daycare_id_id_key ON posts (daycare_id, id);
CREATE INDEX posts_feed_idx ON posts (daycare_id, published_at DESC)
    WHERE deleted_at IS NULL;
CREATE INDEX posts_author_id_idx ON posts (author_id);
CREATE INDEX posts_room_id_idx ON posts (room_id);

-- ---------------------------------------------------------------------------
-- 11. post_children
-- ---------------------------------------------------------------------------

CREATE TABLE post_children (
    daycare_id uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    post_id    uuid NOT NULL,
    child_id   uuid NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (post_id, child_id),
    CONSTRAINT post_children_post_same_daycare
        FOREIGN KEY (daycare_id, post_id) REFERENCES posts (daycare_id, id)
        ON DELETE CASCADE,
    CONSTRAINT post_children_child_same_daycare
        FOREIGN KEY (daycare_id, child_id) REFERENCES children (daycare_id, id)
        ON DELETE CASCADE
);

CREATE INDEX post_children_child_id_idx ON post_children (child_id);

-- ---------------------------------------------------------------------------
-- 12. post_photos
-- ---------------------------------------------------------------------------

CREATE TABLE post_photos (
    id          uuid PRIMARY KEY DEFAULT uuidv7(),
    post_id     uuid NOT NULL REFERENCES posts (id) ON DELETE CASCADE,
    storage_key text NOT NULL UNIQUE CHECK (char_length(storage_key) <= 512),
    width       int CHECK (width IS NULL OR width > 0),
    height      int CHECK (height IS NULL OR height > 0),
    position    int NOT NULL DEFAULT 0 CHECK (position >= 0),
    created_at  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT post_photos_position_key UNIQUE (post_id, position)
);

-- ---------------------------------------------------------------------------
-- 13. reactions
-- ---------------------------------------------------------------------------

CREATE TABLE reactions (
    daycare_id uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    post_id    uuid NOT NULL,
    user_id    uuid NOT NULL,
    type       text NOT NULL DEFAULT 'love' CHECK (type IN ('love')),
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (post_id, user_id),
    CONSTRAINT reactions_post_same_daycare
        FOREIGN KEY (daycare_id, post_id) REFERENCES posts (daycare_id, id)
        ON DELETE CASCADE,
    CONSTRAINT reactions_user_same_daycare
        FOREIGN KEY (daycare_id, user_id) REFERENCES users (daycare_id, id)
        ON DELETE CASCADE
);

CREATE INDEX reactions_user_id_idx ON reactions (user_id);

-- ---------------------------------------------------------------------------
-- 14. comments
-- ---------------------------------------------------------------------------

CREATE TABLE comments (
    id         uuid PRIMARY KEY DEFAULT uuidv7(),
    daycare_id uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    post_id    uuid NOT NULL,
    author_id  uuid NOT NULL,
    body       text NOT NULL CHECK (char_length(body) BETWEEN 1 AND 2000),
    deleted_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT comments_post_same_daycare
        FOREIGN KEY (daycare_id, post_id) REFERENCES posts (daycare_id, id)
        ON DELETE CASCADE,
    CONSTRAINT comments_author_same_daycare
        FOREIGN KEY (daycare_id, author_id) REFERENCES users (daycare_id, id)
        ON DELETE RESTRICT
);

CREATE INDEX comments_post_created_idx ON comments (post_id, created_at)
    WHERE deleted_at IS NULL;
CREATE INDEX comments_author_id_idx ON comments (author_id);

-- ---------------------------------------------------------------------------
-- 15. daily_summaries
-- ---------------------------------------------------------------------------

CREATE TABLE daily_summaries (
    id               uuid PRIMARY KEY DEFAULT uuidv7(),
    daycare_id       uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    child_id         uuid NOT NULL,
    summary_date     date NOT NULL,
    meals_count      int NOT NULL DEFAULT 0 CHECK (meals_count >= 0),
    sleep_minutes    int NOT NULL DEFAULT 0 CHECK (sleep_minutes BETWEEN 0 AND 1440),
    activities_count int NOT NULL DEFAULT 0 CHECK (activities_count >= 0),
    mood             text CHECK (mood IS NULL OR char_length(mood) <= 200),
    highlight        text CHECK (highlight IS NULL OR char_length(highlight) <= 500),
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT daily_summaries_child_date_key UNIQUE (child_id, summary_date),
    CONSTRAINT daily_summaries_child_same_daycare
        FOREIGN KEY (daycare_id, child_id) REFERENCES children (daycare_id, id)
        ON DELETE CASCADE
);

CREATE INDEX daily_summaries_daycare_date_idx ON daily_summaries (daycare_id, summary_date);

-- ---------------------------------------------------------------------------
-- 16. devices (opcional — push notifications)
-- ---------------------------------------------------------------------------

CREATE TABLE devices (
    id           uuid PRIMARY KEY DEFAULT uuidv7(),
    user_id      uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token        text NOT NULL UNIQUE CHECK (char_length(token) <= 512),
    platform     text NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    last_seen_at timestamptz NOT NULL DEFAULT now(),
    created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX devices_user_id_idx ON devices (user_id);

-- ---------------------------------------------------------------------------
-- 17. data_access_log (opcional — auditoría)
-- ---------------------------------------------------------------------------

CREATE TABLE data_access_log (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    daycare_id uuid NOT NULL REFERENCES daycares (id) ON DELETE RESTRICT,
    user_id    uuid NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    entity     text NOT NULL
               CHECK (entity IN ('child', 'medical_notes', 'post', 'post_photo')),
    entity_id  uuid NOT NULL,
    action     text NOT NULL CHECK (action IN ('read', 'export', 'delete')),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX data_access_log_daycare_created_idx
    ON data_access_log (daycare_id, created_at DESC);

-- ---------------------------------------------------------------------------
-- Funciones y triggers
-- ---------------------------------------------------------------------------

CREATE FUNCTION set_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER daycares_set_updated_at
    BEFORE UPDATE ON daycares FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER users_set_updated_at
    BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER rooms_set_updated_at
    BEFORE UPDATE ON rooms FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER children_set_updated_at
    BEFORE UPDATE ON children FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER invitations_set_updated_at
    BEFORE UPDATE ON invitations FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER posts_set_updated_at
    BEFORE UPDATE ON posts FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER comments_set_updated_at
    BEFORE UPDATE ON comments FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER daily_summaries_set_updated_at
    BEFORE UPDATE ON daily_summaries FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- staff_rooms solo admite usuarios staff del mismo tenant
CREATE FUNCTION enforce_staff_room_role() RETURNS trigger
LANGUAGE plpgsql AS $$
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

CREATE TRIGGER staff_rooms_enforce_role
    BEFORE INSERT OR UPDATE ON staff_rooms
    FOR EACH ROW EXECUTE FUNCTION enforce_staff_room_role();

-- parent_children solo admite usuarios parent del mismo tenant
CREATE FUNCTION enforce_parent_child_role() RETURNS trigger
LANGUAGE plpgsql AS $$
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

CREATE TRIGGER parent_children_enforce_role
    BEFORE INSERT OR UPDATE ON parent_children
    FOR EACH ROW EXECUTE FUNCTION enforce_parent_child_role();

-- invitations.accepted_by debe pertenecer al mismo tenant
CREATE FUNCTION enforce_invitation_acceptor() RETURNS trigger
LANGUAGE plpgsql AS $$
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

CREATE TRIGGER invitations_enforce_acceptor
    BEFORE INSERT OR UPDATE ON invitations
    FOR EACH ROW EXECUTE FUNCTION enforce_invitation_acceptor();

-- ---------------------------------------------------------------------------
-- Notas de operación (fuera de la migración, requieren el rol de administrador)
-- ---------------------------------------------------------------------------
-- REVOKE CREATE ON SCHEMA public FROM PUBLIC;
-- GRANT USAGE ON SCHEMA public TO app_rw;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_rw;
-- GRANT INSERT ON data_access_log TO app_rw;  -- append-only

-- migrate:down
