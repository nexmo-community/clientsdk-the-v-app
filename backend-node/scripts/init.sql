CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    vonage_id character varying,
    name character varying NOT NULL,
    display_name character varying,
    password_digest character varying,
    is_active boolean DEFAULT true,
    sync_at timestamp without time zone
);
CREATE UNIQUE INDEX users_pkey ON users(id int8_ops);


CREATE TABLE conversations (
    id BIGSERIAL PRIMARY KEY,
    vonage_id character varying,
    name character varying NOT NULL,
    display_name character varying,
    state character varying NOT NULL,
    created_at timestamp without time zone,
    deleted_at timestamp without time zone
);
CREATE UNIQUE INDEX conversations_pkey ON conversations(id int8_ops);


CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    vonage_id character varying NOT NULL
    user_id character varying NOT NULL,
    conversation_id character varying NOT NULL,
    state text NOT NULL
);
CREATE UNIQUE INDEX members_pkey ON members(id int4_ops);


CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    conversation_id character varying NOT NULL,
    from_member_id character varying NOT NULL,
    to_member_id character varying,
    vonage_id integer NOT NULL,
    vonage_type character varying NOT NULL,
    content text,
    created_at timestamp without time zone
);

-- Indices -------------------------------------------------------

CREATE UNIQUE INDEX events_pkey ON events(id int4_ops);