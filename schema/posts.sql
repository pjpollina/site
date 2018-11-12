-- SQL Schema for blog posts table
-- Formatted for MariaDB

CREATE TABLE posts (
  post_id         SMALLINT UNSIGNED   NOT NULL  PRIMARY KEY,  -- The primary key
  post_title      VARCHAR(190)        NOT NULL  UNIQUE,       -- Title of the post
  post_slug       VARCHAR(190)        NOT NULL  UNIQUE,       -- URL-safe version of post_title
  post_body       TEXT                NOT NULL,               -- The actual post content
  post_timestamp  DATETIME            DEFAULT NOW()           -- Timestamp of when the post was created (defaults to the moment it's added to the database)
);