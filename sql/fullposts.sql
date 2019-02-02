-- SQL Schema for fullposts view (used to clean up some prepared statements)
-- Formatted for MySQL

CREATE VIEW fullposts AS
  SELECT
    post_title,
    post_slug,
    post_body,
    cat_name,
    post_timestamp
  FROM posts INNER JOIN categories ON (post_category = cat_id);