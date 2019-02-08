-- SQL Schema for blog post categories table
-- Formatted for MySQL

CREATE TABLE categories (
  cat_name  VARCHAR(255) NOT NULL PRIMARY KEY, -- The name of the category
  cat_desc  VARCHAR(255)                       -- The description of the category
);
