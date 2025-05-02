DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

CREATE TYPE match_result AS ENUM ('win', 'lose', 'draw');
CREATE TYPE event_type AS ENUM ('goal', 'penalty', 'red_card', 'yellow_card', 'substitution', 'foul');
CREATE TYPE player_role AS ENUM ('starter', 'substitute');
CREATE TYPE staff_position AS ENUM ('head_coach', 'assistant_coach', 'fitness_coach', 'team_doctor', 'physiotherapist', 'analyst', 'manager');
CREATE TYPE stadium_level AS ENUM ('A', 'B', 'C');

CREATE TABLE person (
    pid VARCHAR(20) PRIMARY KEY,
    english_full_name VARCHAR(50) NOT NULL,
    persian_full_name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    address TEXT NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    member_since DATE NOT NULL
);

CREATE TABLE player (
    id SERIAL PRIMARY KEY,
    team_season_id INT NOT NULL,
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

CREATE TABLE league (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE season (
    id SERIAL PRIMARY KEY,
    league_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    foreign key (league_id) REFERENCES league(id) ON DELETE CASCADE
);

CREATE TABLE referee_committee (
    season_id INT PRIMARY KEY,
    committee_name VARCHAR(100) NOT NULL,

    foreign key (season_id) REFERENCES season(id)
);

CREATE TABLE referee_committee_member (
    season_id INT NOT NULL,
    referee_id INT NOT NULL,

    PRIMARY KEY (season_id, referee_id),
    FOREIGN KEY (season_id) REFERENCES referee_committee(season_id) ON DELETE CASCADE,
    FOREIGN KEY (referee_id) REFERENCES referee(id) ON DELETE CASCADE
);

CREATE TABLE match_week (
    season_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    PRIMARY KEY (season_id, start_date),
    FOREIGN KEY (season_id) REFERENCES season(id) ON DELETE CASCADE
);

CREATE TABLE stadium (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    ticket_price DECIMAL NOT NULL CHECK (ticket_price > 0),
    address TEXT NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    level stadium_level NOT NULL
);

CREATE TABLE match (
    id SERIAL PRIMARY KEY,
    stadium_id INT NOT NULL,
    date DATE NOT NULL,

    match_week_season_id INT NOT NULL,
    match_week_start_date DATE NOT NULL,

    observer_id INT NOT NULL,
    observer_comment TEXT NOT NULL,

    FOREIGN KEY (match_week_season_id, match_week_start_date) REFERENCES match_week(season_id, start_date) ON DELETE CASCADE,
    FOREIGN KEY (stadium_id) REFERENCES stadium(id) ON DELETE SET NULL,
    FOREIGN KEY (observer_id) REFERENCES referee(id) ON DELETE SET NULL
);

CREATE TABLE team (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    foundation_date DATE NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE play_match (
    match_id INT NOT NULL,
    team_id INT NOT NULL,
    is_host BOOLEAN NOT NULL,

    result match_result NOT NULL,
    shot_number SMALLINT NOT NULL DEFAULT 0,
    pass_number SMALLINT NOT NULL DEFAULT 0,
    foul_number SMALLINT NOT NULL DEFAULT 0,
    goal_number SMALLINT NOT NULL DEFAULT 0,
    corner_kick_number SMALLINT NOT NULL DEFAULT 0,

    PRIMARY KEY (match_id, is_host),
    FOREIGN KEY (match_id) REFERENCES match(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE CASCADE
);

CREATE TABLE team_season (
    season_id INT NOT NULL,
    team_id INT NOT NULL,
    score SMALLINT NOT NULL DEFAULT 0,
    rank SMALLINT NOT NULL DEFAULT 1,

    PRIMARY KEY (season_id, team_id),
    FOREIGN KEY (season_id) REFERENCES season(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE CASCADE
);

CREATE TABLE player_in_team_season (
    player_id INT NOT NULL,
    team_id INT NOT NULL,
    season_id INT NOT NULL,

    PRIMARY KEY (player_id, team_id, season_id),
    FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id, season_id) REFERENCES team_season(team_id, season_id) ON DELETE CASCADE
);

CREATE TABLE player_in_match (
    player_id INT NOT NULL,
    match_id INT NOT NULL,
    role player_role NOT NULL,

    PRIMARY KEY (player_id, match_id),
    FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE,
    FOREIGN KEY (match_id) REFERENCES match(id) ON DELETE CASCADE
);

CREATE TABLE staff_in_team_season (
    staff_id INT NOT NULL,
    team_id INT NOT NULL,
    season_id INT NOT NULL,

    PRIMARY KEY (staff_id, team_id, season_id),
    FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id, season_id) REFERENCES team_season(team_id, season_id) ON DELETE CASCADE
);

CREATE TABLE staff_in_match (
    staff_id INT NOT NULL,
    match_id INT NOT NULL,
    position staff_position NOT NULL,

    PRIMARY KEY (staff_id, match_id),
    FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE,
    FOREIGN KEY (match_id) REFERENCES match(id) ON DELETE CASCADE
);

CREATE TABLE judging (
    referee_id INT NOT NULL,
    match_id INT NOT NULL,
    referee_position INT CHECK (referee_position BETWEEN 1 AND 4),

    referee_committee_id INT NOT NULL,
    referee_committee_score INT CHECK (referee_position BETWEEN 1 AND 10),

    PRIMARY KEY (match_id, referee_id, referee_position),
    FOREIGN KEY (referee_id) REFERENCES referee(id) ON DELETE CASCADE,
    FOREIGN KEY (match_id) REFERENCES match(id) ON DELETE CASCADE,
    FOREIGN KEY (referee_committee_id) REFERENCES referee_committee(season_id) ON DELETE CASCADE
);

CREATE TABLE transfer (
    id SERIAL PRIMARY KEY,
    player_id INT NOT NULL,
    origin_country VARCHAR(50) NOT NULL DEFAULT 'Iran',
    destination_country VARCHAR(50) NOT NULL DEFAULT 'Iran',
    origin_team INT,
    destination_team INT,
    origin_team_name VARCHAR(50) NOT NULL,
    destination_team_name VARCHAR(50) NOT NULL,
    transfer_date DATE NOT NULL,
    transfer_fee DECIMAL NOT NULL CHECK (transfer_fee > 0),

    FOREIGN KEY (origin_team) REFERENCES team(id) ON DELETE CASCADE,
    FOREIGN KEY (destination_team) REFERENCES team(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE
);

CREATE TABLE match_event (
    event_id SERIAL PRIMARY KEY,
    match_id INT NOT NULL,
    happening_time TIME NOT NULL,
    event event_type NOT NULL,
    staff_id INT, -- it is null for player events

    FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES match(id) ON DELETE CASCADE
);

CREATE TABLE player_event (
    event_id INT NOT NULL,
    player_id INT NOT NULL,

    PRIMARY KEY (event_id, player_id),
    FOREIGN KEY (event_id) REFERENCES match_event(event_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE
);
