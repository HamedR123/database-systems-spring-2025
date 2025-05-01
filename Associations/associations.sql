DROP TABLE IF EXISTS memberships CASCADE;
DROP TABLE IF EXISTS votes CASCADE;
DROP TABLE IF EXISTS candidates CASCADE;
DROP TABLE IF EXISTS association_sessions CASCADE;
DROP TABLE IF EXISTS associations CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TYPE IF EXISTS candidate_status CASCADE;

CREATE TYPE candidate_status AS ENUM ('qualified', 'disqualified', 'withdrawn');

CREATE TABLE students (
    id CHAR(9) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    pid CHAR(10) NOT NULL UNIQUE
);

CREATE TABLE associations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    foundation_date DATE NOT NULL,
    member_count INT NOT NULL,
    bylaws TEXT NOT NULL,

    CHECK (member_count >= 0)
);

CREATE TABLE association_sessions (
    id SERIAL PRIMARY KEY,
    association_id INT NOT NULL,
    session_number INT NOT NULL,
    secretary_id CHAR(9),
    deputy_secretary_id CHAR(9),
    election_date DATE NOT NULL,

    CHECK (session_number > 0),
    UNIQUE (association_id, session_number),
    FOREIGN KEY (association_id) REFERENCES associations(id) ON DELETE CASCADE,
    FOREIGN KEY (secretary_id) REFERENCES students(id) ON DELETE SET NULL,
    FOREIGN KEY (deputy_secretary_id) REFERENCES students(id) ON DELETE SET NULL
);

CREATE TABLE candidates (
    id SERIAL PRIMARY KEY,
    student_id CHAR(9) NOT NULL,
    association_session_id INT NOT NULL,
    vote_count INT NOT NULL DEFAULT 0,
    status candidate_status NOT NULL,

    CHECK (vote_count >= 0),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (association_session_id) REFERENCES association_sessions(id) ON DELETE CASCADE
);

CREATE TABLE memberships (
    student_id CHAR(9) NOT NULL,
    association_session_id INT NOT NULL,
    alternative BOOLEAN NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,

    PRIMARY KEY (student_id, association_session_id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (association_session_id) REFERENCES association_sessions(id) ON DELETE CASCADE
);

CREATE TABLE votes (
    candidate_id INT NOT NULL,
    student_id CHAR(9) NOT NULL,

    PRIMARY KEY (candidate_id, student_id),
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);