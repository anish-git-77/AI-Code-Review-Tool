-- AI Code Review Tool — PostgreSQL schema

CREATE TABLE IF NOT EXISTS users (
    id                SERIAL PRIMARY KEY,
    github_id         BIGINT UNIQUE NOT NULL,
    username          VARCHAR(255) NOT NULL,
    avatar_url        TEXT,
    access_token_enc  TEXT NOT NULL,       -- encrypted GitHub OAuth token
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS repos (
    id               SERIAL PRIMARY KEY,
    user_id          INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    github_repo_id   BIGINT NOT NULL,
    full_name        VARCHAR(255) NOT NULL,   -- e.g. "octocat/hello-world"
    default_branch   VARCHAR(255) DEFAULT 'main',
    connected_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, github_repo_id)
);

CREATE TABLE IF NOT EXISTS reviews (
    id           SERIAL PRIMARY KEY,
    repo_id      INTEGER REFERENCES repos(id) ON DELETE CASCADE,
    user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    file_path    TEXT,                 -- null if user pasted raw code
    source       VARCHAR(20) NOT NULL DEFAULT 'paste', -- 'paste' | 'github'
    status       VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending | complete | failed
    raw_code     TEXT NOT NULL,
    summary      TEXT,                 -- short LLM-generated overview
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS issues (
    id              SERIAL PRIMARY KEY,
    review_id       INTEGER NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    line_number     INTEGER,
    severity        VARCHAR(20) NOT NULL,   -- 'bug' | 'smell' | 'style' | 'security'
    category        VARCHAR(100),
    description     TEXT NOT NULL,
    suggested_fix   TEXT,
    resolved        BOOLEAN NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reviews_user ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_issues_review ON issues(review_id);
CREATE INDEX IF NOT EXISTS idx_repos_user ON repos(user_id);
