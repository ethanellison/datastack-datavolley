with

source as (
    select
        meta->>'$.match_id[0]' as match_id,
        meta->>'$.match[0].date' as match_date, 
        file_meta->>'$[0].preferred_date_format' as date_format,
        meta->'$.teams[0]' as home_team,
        meta->'$.teams[1]' as away_team
    from {{ source('raw', 'raw_output')}}
)


select * from source
