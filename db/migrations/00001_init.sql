-- +goose Up
-- everything that creates things goes here

CREATE TYPE game_outcome AS ENUM ('win', 'loss', 'tie');

CREATE TABLE users (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cognito_sub text NOT NULL UNIQUE
);

CREATE TABLE archetype_icons (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        text NOT NULL UNIQUE CONSTRAINT archetype_icons_name_not_empty CHECK (name <> ''),   -- pokemon name, ex: Dipplin, Mega Lucario
    image_url   text NOT NULL
);

CREATE TABLE archetypes (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id             bigint NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    name                text NOT NULL CONSTRAINT archetypes_name_not_empty CHECK (name <> ''),
    archetype_icon_id   bigint REFERENCES archetype_icons (id) ON DELETE SET NULL,
    archetype_icon2_id  bigint REFERENCES archetype_icons (id) ON DELETE SET NULL,
    CONSTRAINT archetypes_user_id_name_key UNIQUE (user_id, name)
);

CREATE TABLE decks (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id             bigint NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    name                text NOT NULL CONSTRAINT decks_name_not_empty CHECK (name <> ''),
    created_at          timestamptz NOT NULL DEFAULT now(),
    archetype_id        bigint REFERENCES archetypes (id) ON DELETE SET NULL,       -- nullable
    notes               text NOT NULL DEFAULT '',
    CONSTRAINT decks_user_id_name_key UNIQUE (user_id, name)
);
CREATE INDEX decks_user_id_idx ON decks (user_id);

CREATE TABLE deck_versions (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    deck_id             bigint NOT NULL REFERENCES decks (id) ON DELETE CASCADE,
    name                text NOT NULL CONSTRAINT deck_versions_name_not_empty CHECK (name <> ''),
    created_at          timestamptz NOT NULL DEFAULT now(),
    cards               text NOT NULL DEFAULT '',
    notes               text NOT NULL DEFAULT '',
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT deck_versions_deck_id_name_key UNIQUE (deck_id, name)
);
CREATE INDEX deck_versions_deck_id_idx ON deck_versions (deck_id);

CREATE TABLE environments (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id             bigint NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    name                text NOT NULL CONSTRAINT environments_name_not_empty CHECK (name <> ''),
    CONSTRAINT environments_user_id_name_key UNIQUE (user_id, name)
);

CREATE TABLE matches (
    id                      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    deck_version_id         bigint NOT NULL REFERENCES deck_versions (id) ON DELETE CASCADE,
    opponent_archetype_id   bigint REFERENCES archetypes (id) ON DELETE SET NULL,               -- nullable: means unknown
    environment_id          bigint REFERENCES environments (id) ON DELETE SET NULL,             -- nullable: means unknown
    played_at               timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX matches_deck_version_id_played_at_idx ON matches (deck_version_id, played_at);
CREATE INDEX matches_opponent_archetype_id_idx ON matches (opponent_archetype_id);
CREATE INDEX matches_environment_id_idx ON matches (environment_id);

CREATE TABLE games (
    id                      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    match_id                bigint NOT NULL REFERENCES matches (id) ON DELETE CASCADE,
    game_number             int NOT NULL DEFAULT 1 CONSTRAINT games_game_number_greater_zero CHECK (game_number > 0),
    outcome                 game_outcome NOT NULL,
    live_log                text,                                                               -- nullable: optional ptcg online battle log copy    
    went_first              bool,                                                               -- nullable: means unknown
    won_flip                bool,                                                               -- nullable: means unknown
    notes                   text NOT NULL DEFAULT '',
    my_prizes_left          int CONSTRAINT games_my_prizes_left_range CHECK (my_prizes_left BETWEEN 0 AND 6),                         -- nullable: means unknown
    opponent_prizes_left    int CONSTRAINT games_opponent_prizes_left_range CHECK (opponent_prizes_left BETWEEN 0 AND 6),                   -- nullable: means unknown
    CONSTRAINT games_match_id_game_number_key UNIQUE (match_id, game_number)
);

CREATE TABLE tags (
    id                      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                 bigint REFERENCES users (id) ON DELETE CASCADE,
    name                    text NOT NULL CONSTRAINT tags_name_not_empty CHECK (name <> ''),
    CONSTRAINT tags_user_id_name_key UNIQUE NULLS NOT DISTINCT (user_id, name)                                               -- nulls not distinct prevents non unique global tags
);

CREATE TABLE game_tags (
    game_id                 bigint NOT NULL REFERENCES games (id) ON DELETE CASCADE,
    tag_id                  bigint NOT NULL REFERENCES tags (id) ON DELETE CASCADE,
    PRIMARY KEY (game_id, tag_id)
);
CREATE INDEX game_tags_tag_id_idx ON game_tags (tag_id);

-- +goose Down
-- everything that undoes the Up section goes here

DROP TABLE IF EXISTS game_tags;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS environments;
DROP TABLE IF EXISTS deck_versions;
DROP TABLE IF EXISTS decks;
DROP TABLE IF EXISTS archetypes;
DROP TABLE IF EXISTS archetype_icons;
DROP TABLE IF EXISTS users;
DROP TYPE IF EXISTS game_outcome;