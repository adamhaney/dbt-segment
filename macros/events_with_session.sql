-- From https://blog.modeanalytics.com/finding-user-sessions-sql/
{% macro track_with_session(track_table, session_limit_seconds = 60 * 10, user_id_col = 'user_id') %}

WITH events_with_session AS (
SELECT *,
       SUM(is_new_session) OVER (ORDER BY {{ user_id_col }}, sent_at ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS global_session_id,
       SUM(is_new_session) OVER (PARTITION BY {{ user_id_col }} ORDER BY sent_at ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS user_session_id
  FROM (
       SELECT *,
              CASE WHEN EXTRACT('EPOCH' FROM sent_at) - EXTRACT('EPOCH' FROM last_event) >= ({{ session_limit_seconds }})
                     OR last_event IS NULL
                   THEN 1 ELSE 0 END AS is_new_session
         FROM (
              SELECT *,
                     LAG(sent_at,1) OVER (PARTITION BY user_id ORDER BY sent_at) AS last_event
                FROM {{ ref(track_table) }}
              ) last
       ) final), 
session_start_end AS (
SELECT *,(
     SELECT sent_at
     FROM session_identifier
     WHERE global_session_id = global_session_id
       ORDER BY sent_at DESC
       LIMIT 1
     ) as session_start,
     (
     SELECT sent_at
     FROM session_identifier
     WHERE global_session_id = global_session_id
       ORDER BY sent_at DESC
       LIMIT 1
     ) as session_end
FROM session_identifier
)

SELECT *, EXTRACT(epoch FROM (session_end - session_start))::int as session_length FROM session_start_end
{% endmacro %}
