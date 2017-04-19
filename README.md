# dbt-segment
This repository contains dbt models and macros to aid in common data modeling issues with Segment using DBT (The database build tool).

# Macros
Because some project span multiple schemas it may be neccassary to combine your pages/tracks (web) screens/tracks (mobile ) tables if you're interested in modeling user behavior accross devices. Because of this we've provided macros that do common table transformations instead of only providing configurable models that read from vars.

## add_universal_id
### Params
#### tracks_table
A table that contains events that include both an anonymous_id and a user_id that need to be universally identified.

## events_with_session
### Params

#### track_table
model name (uses ref(track_table) internally) of a table which
includes screens/pages/tracks (or any combination if you've decided to
UNION these tables together in a way that describes multi device
behavior for your use case) and a user identifier

#### session_limit_seconds
Events that happen less than this number of seconds apart will be
treated as a single session.

#### user_id_col
The column to use for identifying the user (note if this is anonymous_id or user_id you may need to use the add_universal_id macro)

### Output
The output of this macro will include all of the columns of the input table as well as

#### global_session_id
Integer index number of this session globally for all users

#### user_session_id
Which session number is this for this user

#### session_start
The date at which this session started

#### session_end
The date at which this session ended


