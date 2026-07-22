CREATE TABLE enemy_type (
    id TEXT PRIMARY KEY NOT NULL CHECK (LENGTH(id) = 36),
    enemy_type_name TEXT NOT NULL,
    max_hp REAL NOT NULL,
    speed REAL NOT NULL,
    cover REAL NOT NULL,
    discipline REAL NOT NULL,
    hardiness REAL NOT NULL,
    damage_min REAL NOT NULL,
    damage_max REAL NOT NULL,
    bounty INTEGER NOT NULL,
    lives_cost INTEGER NOT NULL DEFAULT 1,
    break_band_lo REAL NOT NULL,
    break_band_hi REAL NOT NULL,
    traits TEXT NOT NULL DEFAULT '[]'
);

CREATE TABLE tower_type (
    id TEXT PRIMARY KEY NOT NULL CHECK (LENGTH(id) = 36),
    tower_type_name TEXT NOT NULL
);

CREATE TABLE tower (
    id TEXT PRIMARY KEY NOT NULL CHECK (LENGTH(id) = 36),
    tower_level INTEGER NOT NULL,
    cost INTEGER NOT NULL,
    tower_range REAL NOT NULL,
    fire_interval REAL NOT NULL,
    shot_min REAL NOT NULL DEFAULT 0,
    shot_max REAL NOT NULL DEFAULT 0,
    terror_min REAL NOT NULL DEFAULT 0,
    terror_max REAL NOT NULL DEFAULT 0,
    aoe_radius REAL NOT NULL DEFAULT 0,
    contagion_chance REAL NOT NULL DEFAULT 0,
    targeting TEXT NOT NULL DEFAULT 'first'
);

CREATE TABLE campaign (
    id TEXT PRIMARY KEY NOT NULL CHECK (LENGTH(id) = 36),
    campaign_name TEXT NOT NULL,
    parent_campaign_id TEXT REFERENCES campaign (id)
);

CREATE TABLE level_info (
    id TEXT PRIMARY KEY NOT NULL CHECK (LENGTH(id) = 36),
    campaign_id TEXT NOT NULL REFERENCES campaign (id),
    level_name TEXT NOT NULL,
    world_map_x REAL NOT NULL,
    world_map_y REAL NOT NULL,
    started_at REAL NOT NULL,
    ended_at REAL NOT NULL,
    starting_money INTEGER NOT NULL CHECK (starting_money > 0),
    num_starting_lives INTEGER NOT NULL CHECK (num_starting_lives > 0)
);

-- A level's enemy path(s) as ordered polyline points in map (image-pixel) space,
-- one row per point. path_index groups points into a path (a level may have more
-- than one); point_index is the travel order, point 0 is the spawn, the last
-- point is the exit. Hand-authored per level.
CREATE TABLE level_path_point (
    id TEXT PRIMARY KEY NOT NULL CHECK (LENGTH(id) = 36),
    level_info_id TEXT NOT NULL REFERENCES level_info (id),
    path_index INTEGER NOT NULL DEFAULT 0,
    point_index INTEGER NOT NULL,
    map_position_x REAL NOT NULL,
    map_position_y REAL NOT NULL,
    UNIQUE (level_info_id, path_index, point_index)
);

CREATE TABLE tower_slot (
    id TEXT PRIMARY KEY NOT NULL CHECK (LENGTH(id) = 36),
    level_info_id TEXT NOT NULL REFERENCES level_info (id),
    map_position_x REAL NOT NULL,
    map_position_y REAL NOT NULL
);

-- CREATE TABLE wave (
--     id TEXT PRIMARY KEY NOT NULL CHECK (length(id) = 36),
--     wave_index INTEGER NOT NULL,
--     start_time REAL NOT NULL,
--     PRIMARY KEY (level_id, wave_index)
-- );

-- CREATE TABLE wave_spawn (
--     id TEXT PRIMARY KEY NOT NULL CHECK (length(id) = 36),
--     wave_index INTEGER NOT NULL,
--     spawn_index INTEGER NOT NULL,
--     enemy_type_id TEXT NOT NULL REFERENCES enemy_type(id),
--     count INTEGER NOT NULL,
--     interval REAL NOT NULL,
--     delay REAL NOT NULL DEFAULT 0,
--     path_index INTEGER NOT NULL DEFAULT 0
-- );

-- CREATE INDEX idx_wave_spawns_level ON wave_spawns(level_id);
-- CREATE INDEX idx_waves_level ON waves(level_id);
