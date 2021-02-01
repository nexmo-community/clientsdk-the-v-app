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

