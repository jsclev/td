DROP DATABASE IF EXISTS td;
CREATE DATABASE td;

CREATE TABLE map (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    width REAL NOT NULL,
    height REAL NOT NULL
);

create table enemy

CREATE TABLE waypoint (
    id INTEGER PRIMARY KEY,
    map_id INTEGER NOT NULL,
    x REAL NOT NULL,
    y REAL NOT NULL,
    sequence_num INTEGER NOT NULL
);
