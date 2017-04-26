{% macro add_universal_id(ref_tracks_table, tracks_table_schema) %}
WITH realiases AS (
  SELECT
    anonymous_id AS alias,
    user_id AS next_alias
  FROM {{tracks_table_schema}}.identifies
  UNION
  SELECT
    anonymous_id,
    user_id
  FROM {{ tracks_table_schema }}.identifies
), lookups AS (
SELECT DISTINCT
  r0.alias,
  COALESCE(
      r5.next_alias
    , r5.alias
    , r4.alias
    , r3.alias
    , r2.alias
    , r1.alias
    , r0.alias
  ) AS universal_user_id
  FROM realiases AS r0
  LEFT JOIN realiases r1 ON r0.next_alias = r1.alias
  LEFT JOIN realiases r2 ON r1.next_alias = r2.alias
  LEFT JOIN realiases r3 ON r2.next_alias = r3.alias
  LEFT JOIN realiases r4 ON r3.next_alias = r4.alias
  LEFT JOIN realiases r5 ON r4.next_alias = r5.alias
)

SELECT *
FROM (
     SELECT *, user_id || anonymous_id as merged_id
     FROM {{ ref_tracks_table }}
) t
LEFT JOIN lookups
ON lookups.alias = t.merged_id

{% endmacro %}
