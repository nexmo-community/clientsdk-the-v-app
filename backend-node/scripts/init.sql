CREATE TABLE users (
    id integer PRIMARY KEY,
    vonage_id character varying UNIQUE,
    name character varying NOT NULL,
    display_name character varying,
    password_digest character varying,
    is_active boolean DEFAULT true,
    sync_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE conversations (
    id BIGSERIAL PRIMARY KEY,
    vonage_id character varying UNIQUE,
    name character varying NOT NULL,
    display_name character varying,
    state character varying NOT NULL,
    vonage_created_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    vonage_id character varying NOT NULL UNIQUE,
    user_id character varying NOT NULL,
    conversation_id character varying NOT NULL,
    state text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    vonage_id character varying UNIQUE,
    vonage_type character varying NOT NULL,
    conversation_id character varying NOT NULL,
    from_member_id character varying NOT NULL,
    to_member_id character varying,
    content text,
    created_at timestamp without time zone NOT NULL
);
