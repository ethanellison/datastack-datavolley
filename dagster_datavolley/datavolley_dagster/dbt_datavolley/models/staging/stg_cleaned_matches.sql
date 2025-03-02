with

source as (
    select
        match_id,
        match_date, 
        preferred_date_format,
        home_team_id,
        away_team_id,
        home_team_name,
        away_team_name
    from {{ source('raw', 'raw_matches') }}
)


select * from source
