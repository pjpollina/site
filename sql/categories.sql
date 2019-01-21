-- SQL Schema for blog post categories table
-- Formatted for MySQL

CREATE TABLE categories (
  cat_id    SMALLINT UNSIGNED  NOT NULL PRIMARY KEY,                    -- The primary key
  cat_name  VARCHAR(255)       NOT NULL UNIQUE,                         -- The name of the category
  cat_slug  VARCHAR(255)       AS (LOWER(REPLACE(cat_name, " ", "_"))), -- The slug for the category, automatically derived from the name
  cat_desc  VARCHAR(255)                                                -- The description of the category
);
