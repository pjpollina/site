-- SQL Schema for blog posts table
-- Formatted for MySQL

CREATE TABLE posts (
  post_id         SMALLINT UNSIGNED   NOT NULL  PRIMARY KEY,  -- The primary key
  post_title      VARCHAR(255)        NOT NULL  UNIQUE,       -- Title of the post
  post_slug       VARCHAR(255)        NOT NULL  UNIQUE,       -- URL-safe version of post_title
  post_body       TEXT                NOT NULL,               -- The actual post content
  post_category   VARCHAR(255)        DEFAULT "Misc",         -- The post's category
  post_timestamp  DATETIME            DEFAULT NOW()           -- Timestamp of when the post was created (defaults to the moment it's added to the database)
);
