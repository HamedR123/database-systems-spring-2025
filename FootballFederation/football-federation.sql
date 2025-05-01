CREATE TYPE  team_side AS ENUM ('win', 'lose', 'draw');
CREATE TYPE event_type AS ENUM ('goal', 'penalty', 'red_card', 'yellow_card', 'substitution', 'foul');
CREATE TYPE stadium_level AS ENUM ('A', 'B', 'C');

CREATE TABLE person (
    pid VARCHAR(20) PRIMARY KEY,
    english_first_name VARCHAR(50) NOT NULL,
    english_last_name VARCHAR(50) NOT NULL,
    persian_first_name VARCHAR(50) NOT NULL,
    persian_last_name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    address TEXT NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    member_since DATE NOT NULL
);

CREATE TABLE player (
    id SERIAL PRIMARY KEY,
    pid VARCHAR(20) NOT NULL REFERENCES person(pid) ON DELETE CASCADE
);

CREATE TABLE staff (
    id SERIAL PRIMARY KEY,
    pid VARCHAR(20) NOT NULL REFERENCES person(pid) ON DELETE CASCADE
);

CREATE TABLE referee (
    id SERIAL PRIMARY KEY,
    pid VARCHAR(20) NOT NULL REFERENCES person(pid) ON DELETE CASCADE
);

CREATE TABLE team (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    foundation_date DATE NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE football_match (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    time TIME NOT NULL,
    winner team_side
);

CREATE TABLE stadium (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    ticket_price DECIMAL NOT NULL,
    CHECK (ticket_price > 0),
    address TEXT NOT NULL,
    capacity INT NOT NULL,
    CHECK (capacity > 0),
    level stadium_level NOT NULL
);

CREATE TABLE transfer (
    id SERIAL PRIMARY KEY,
    from_country VARCHAR(50) NOT NULL DEFAULT 'Iran',
    to_country VARCHAR(50) NOT NULL DEFAULT 'Iran',
    from_team INT REFERENCES team(id) ON DELETE CASCADE,
    to_team INT REFERENCES team(id) ON DELETE CASCADE,
    from_team_name VARCHAR(50) NOT NULL,
    to_team_name VARCHAR(50) NOT NULL,
    transfer_date DATE NOT NULL,
    transfer_fee DECIMAL NOT NULL,
    CHECK (transfer_fee > 0)
);

CREATE TABLE league (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE match_event (
    match_id INT REFERENCES football_match(id) ON DELETE CASCADE,
    minute VARCHAR(10) NOT NULL,
    CHECK (minute ~ '^\d{1,3}(\+\d{1,2})?$'),
    PRIMARY KEY (match_id, minute),
    event event_type NOT NULL
);

CREATE TABLE season (
    league_id INT REFERENCES league(id) ON DELETE CASCADE,
    year INT NOT NULL,
    CHECK (year > 1900),
    PRIMARY KEY (league_id, year)
);

CREATE TABLE match_week (
    league_id INT REFERENCES league(id) ON DELETE CASCADE,
    year INT NOT NULL,
    week_number INT NOT NULL,
    CHECK (week_number > 0),
    PRIMARY KEY (league_id, year, week_number)
);